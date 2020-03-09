//
//  NSRunLoop.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 20.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "NSRunLoop.h"

#import "NSFileHandle.h"
#import "NSTimer.h"

#include <errno.h>
#include <string.h>


NSString   *NSDefaultRunLoopMode = @"NSDefaultRunLoopMode";


# pragma mark - struct MulleRunLoopMessage
/*
 * struct MulleRunLoopMessage
 */

static inline void
   MulleRunLoopMessageInit( struct MulleRunLoopMessage *p,
                            id target,
                            SEL cmd,
                            id argument,
                            NSUInteger order)
{
   assert( p);

   p->target   = [target retain];
   p->selector = cmd;
   p->argument = [argument retain];
   p->order    = order;
}


// cancel just nils out the arguments
static void
   MulleRunLoopMessageCancel( struct MulleRunLoopMessage *p)
{
   assert( p);

   [p->target autorelease];
   p->target = nil;

   // don't kill the selector

   [p->argument autorelease];
   p->argument = nil;

   p->order    = NSIntegerMax;
}


static int   MulleRunLoopMessageCompare( struct MulleRunLoopMessage *p,
                                         struct MulleRunLoopMessage *q)
{
   assert( p);
   assert( q);

   if( p->order != q->order)
      return( p->order < q->order ? NSOrderedAscending : NSOrderedDescending);
   if( p->generation != q->generation)
      return( p->generation < q->generation ? NSOrderedAscending : NSOrderedDescending);
   return( NSOrderedSame);
}


static NSString  *MulleRunLoopMessageDebugDescription( struct MulleRunLoopMessage *p)
{
   return( [NSString stringWithFormat:@"[<%@ %p> %@ %p] (%ld)",
            [p->target class], p->target,
            NSStringFromSelector( p->selector),
            p->argument,
            p->order]);
}


# pragma mark - struct MulleRunLoopMessageArray

static void
   MulleRunLoopMessageArrayInit( struct MulleRunLoopMessageArray *array,
                                 struct mulle_allocator *allocator)
{
   assert( array);

   array->size      = 0;
   array->n         = 0;
   array->allocator = allocator;
   array->items     = NULL;
}


static void
   MulleRunLoopMessageAutoreleaseItems( struct MulleRunLoopMessageArray *array)
{
   struct MulleRunLoopMessage   *p;
   struct MulleRunLoopMessage   *sentinel;

   assert( array);

   p        = array->items;
   sentinel = &p[ array->n];
   while( p < sentinel)
   {
      [p->target autorelease];
      [p->argument autorelease];
      ++p;
   }
}


static void
   MulleRunLoopMessageArrayDone( struct MulleRunLoopMessageArray *array)
{
   assert( array);

   MulleRunLoopMessageAutoreleaseItems( array);
   mulle_allocator_free( array->allocator, array->items);

   // this is important
   array->items = NULL;
   array->n     = 0;
   array->size  = 0;
}


static NSUInteger
   MulleRunLoopMessageArrayGetCount( struct MulleRunLoopMessageArray *array)
{
   assert( array);

   return( array->n);
}


static void
   MulleRunLoopMessageArraySortItems( struct MulleRunLoopMessageArray *array)
{
   assert( array);

   qsort( array->items, array->n, sizeof( struct MulleRunLoopMessage),
          (int (*)(const void *, const void *)) MulleRunLoopMessageCompare);
}


static struct MulleRunLoopMessage   *
   MulleRunLoopMessageArrayNewItem( struct MulleRunLoopMessageArray *array)
{
   size_t                       bytes;
   struct MulleRunLoopMessage   *p;

   assert( array);

   if( array->n == array->size)
   {
      array->size += array->size;
      if( array->size < 4)
         array->size = 4;

      bytes        = sizeof( struct MulleRunLoopMessage) * array->size;
      array->items = mulle_allocator_realloc( array->allocator, array->items, bytes);
   }

   p = &array->items[ array->n++];
   memset( p, 0, sizeof( struct MulleRunLoopMessage));
   p->generation = array->n;
   return( p);
}


static NSUInteger
   MulleRunLoopMessageArrayIndexOfItem( struct MulleRunLoopMessageArray *array,
                                        NSUInteger offset,
                                        id target,
                                        SEL sel,
                                        id argument)
{
   struct MulleRunLoopMessage   *p;
   struct MulleRunLoopMessage   *sentinel;

   assert( array);

   p        = &array->items[ offset];
   sentinel = &array->items[ array->n];

   while( p < sentinel)
   {
      if( p->target   == target &&
          p->selector == sel &&
          p->argument == argument)
      {
         return( p - array->items);
      }
      ++p;
   }
   return( NSNotFound);
}


static NSUInteger
   MulleRunLoopMessageArrayIndexOfItemWithTarget( struct MulleRunLoopMessageArray *array,
                                                  NSUInteger offset,
                                                  id target)
{
   struct MulleRunLoopMessage   *p;
   struct MulleRunLoopMessage   *sentinel;

   assert( array);

   p        = &array->items[ offset];
   sentinel = &array->items[ array->n];

   while( p < sentinel)
   {
      if( p->target == target)
         return( p - array->items);
      ++p;
   }
   return( NSNotFound);
}


//
// the usual problem: callbacks can add to our array of performers
//                    so assume that the caller switched out the array and
//                    we can now do what we please with array. We don't
//                    free it though.
//
static BOOL
   MulleRunLoopMessageArraySendMessages( struct MulleRunLoopMessageArray *array)
{
   struct MulleRunLoopMessage   *p;
   struct MulleRunLoopMessage   *sentinel;

   assert( array);

   if( ! array->n)
      return( NO);

   MulleRunLoopMessageArraySortItems( array);

   p        = array->items;
   sentinel = &p[ array->n];

   while( p < sentinel)
   {
      MulleObjCObjectPerformSelector( p->target, p->selector, p->argument);
      ++p;
   }
   return( YES);
}


static NSString  *
   MulleRunLoopModeMessageArrayDebugDescription( struct MulleRunLoopMessageArray *array, NSString *indent)
{
   NSMutableString              *s;
   NSString                     *sep;
   NSUInteger                    n;
   struct MulleRunLoopMessage   *p;
   struct MulleRunLoopMessage   *sentinel;

   n = array->n;
   if( ! n)
      return( @"");

   s        = [NSMutableString string];
   sep      = nil;
   p        = array->items;
   sentinel = &p[ array->n];

   while( p < sentinel)
   {
      if( p->target)
      {
         [s appendString:sep];
         sep = @",\n";
         [s appendString:indent];
         [s appendString:MulleRunLoopMessageDebugDescription( p)];
      }
      ++p;
   }
   return( s);
}



# pragma mark - struct MulleRunLoopMode
/*
 * struct MulleRunLoopMode
 */
static struct MulleRunLoopMode *
   MulleRunLoopModeAlloc( struct mulle_allocator *allocator)
{
   return( mulle_allocator_malloc( allocator, sizeof( struct MulleRunLoopMode)));
}


static struct mulle_allocator *
   MulleRunLoopModeGetAllocator( struct MulleRunLoopMode *p)
{
   assert( p);

   return( p->messages.allocator);
}


static void
   MulleRunLoopModeInit( struct MulleRunLoopMode *p,
                         struct mulle_allocator *allocator,
                         NSString *name)
{
   assert( p);

   memset( p, 0, sizeof( struct MulleRunLoopMode));
   p->name = [name copy];
   MulleRunLoopMessageArrayInit( &p->messages, allocator);
}


static struct MulleRunLoopMode *
   MulleRunLoopModeCreate( struct mulle_allocator *allocator, NSString *name)
{
   struct MulleRunLoopMode  *p;

   p = MulleRunLoopModeAlloc( allocator);
   MulleRunLoopModeInit( p, allocator, name);
   return( p);
}


static void
   MulleRunLoopModeDone( struct MulleRunLoopMode *p)
{
   struct mulle_allocator  *allocator;

   assert( p);

   [p->name autorelease];
   p->name = nil;
   [p->timers autorelease];
   p->timers = nil;
   allocator = p->messages.allocator;
   MulleRunLoopMessageArrayDone( &p->messages);
}


static void
   MulleRunLoopModeEnqueueMessage( struct MulleRunLoopMode *p,
                                   id target, SEL cmd, id argument,
                                   NSUInteger order)
{
   struct MulleRunLoopMessage   *message;

   assert( p);

   message = MulleRunLoopMessageArrayNewItem( &p->messages);
   MulleRunLoopMessageInit( message, target, cmd, argument, order);
   _mulle_atomic_pointer_increment( &p->nInputsTimersMessages);
}


static void
   MulleRunLoopModeDequeueMessage( struct MulleRunLoopMode *p,
                                   id target, SEL cmd, id argument)
{
   NSUInteger   index;

   assert( p);

   index = MulleRunLoopMessageArrayIndexOfItem( &p->messages, 0, target, cmd, argument);
   if( index != NSNotFound)
   {
      MulleRunLoopMessageCancel( &p->messages.items[ index]);
      _mulle_atomic_pointer_decrement( &p->nInputsTimersMessages);
   }
}


static void
   MulleRunLoopModeDequeueMessagesWithTarget( struct MulleRunLoopMode *p,
                                              id target)
{
   NSUInteger   index;

   assert( p);

   index = 0;
   for(;;)
   {
      index = MulleRunLoopMessageArrayIndexOfItemWithTarget( &p->messages, index, target);
      if( index == NSNotFound)
         return;

      MulleRunLoopMessageCancel( &p->messages.items[ index]);
      _mulle_atomic_pointer_decrement( &p->nInputsTimersMessages);
   }
}


static BOOL
   MulleRunLoopModeIsIdle( struct MulleRunLoopMode *p)
{
   return( _mulle_atomic_pointer_read( &p->nInputsTimersMessages) == 0);
}


static void
   MulleRunLoopModeAddTimer( struct MulleRunLoopMode *p, NSTimer *timer)
{
   NSTimer          *other;
   NSTimeInterval   otherFireTimeInterval;
   NSTimeInterval   fireTimeInterval;
   NSUInteger       i;

   assert( p);

   if( ! p->timers)
      p->timers = [NSMutableArray new];

   fireTimeInterval = [timer mulleFireTimeInterval];

   //
   // place timer in order of fireDate, if same, keep order
   //
   i = 0;
   for( other in p->timers)
   {
      NSCParameterAssert( other != timer);

      ++i;
      otherFireTimeInterval = [other mulleFireTimeInterval];
      if( otherFireTimeInterval > fireTimeInterval)
      {
         [p->timers insertObject:timer
                         atIndex:i];
         _mulle_atomic_pointer_increment( &p->nInputsTimersMessages);
         return;
      }
   }
   [p->timers addObject:timer];
   _mulle_atomic_pointer_increment( &p->nInputsTimersMessages);
}

static void
   MulleRunLoopModeRemoveTimer( struct MulleRunLoopMode *p, NSTimer *timer)
{
   assert( p);
   [p->timers removeObject:timer];
   _mulle_atomic_pointer_decrement( &p->nInputsTimersMessages);
}


static void
   MulleRunLoopModeRemoveTimersInArray( struct MulleRunLoopMode *p, NSArray *array)
{
   NSInteger   n;

   n = [p->timers count];
   [p->timers removeObjectsInArray:array];
   _mulle_atomic_pointer_add( &p->nInputsTimersMessages, -n);
}

static void
   MulleRunLoopModeRemoveTimersInRange( struct MulleRunLoopMode *p, NSRange range)
{
   [p->timers removeObjectsInRange:range];

   // lame
   _mulle_atomic_pointer_add( &p->nInputsTimersMessages, - (NSInteger) range.length);
}


// return array of timers to fire
static NSArray *
   MulleRunLoopModeTimersToFire( struct MulleRunLoopMode *p, NSTimeInterval timeInterval)
{
   NSTimer          *timer;
   NSTimeInterval   otherFireTimeInterval;
   NSTimeInterval   fireTimeInterval;
   NSUInteger       n;
   NSRange          range;
   NSArray          *array;

   assert( p);

   n = 0;
   for( timer in p->timers)
   {
      otherFireTimeInterval = [timer mulleFireTimeInterval];
      if( otherFireTimeInterval > timeInterval)
         break;
      ++n;
   }

   if( ! n)
      return( nil);

   range = NSMakeRange( 0, n);
   array = [p->timers subarrayWithRange:range];

   MulleRunLoopModeRemoveTimersInRange( p, range);

   return( array);
}


static NSTimer  *
   MulleRunLoopModeGetNextTimerToFire( struct MulleRunLoopMode *p)
{
   assert( p);
   return( [p->timers mulleFirstObject]);
}



static void
   MulleRunLoopModeRemoveTimersWithTarget( struct MulleRunLoopMode *p, id target)
{
   NSMutableArray   *array;
   NSTimer          *timer;

   assert( p);

   array = nil;
   for( timer in p->timers)
   {
      if( [timer target] != target)
         continue;
      if( ! array)
         array = [NSMutableArray array];
      [array addObject:timer];
   }

   MulleRunLoopModeRemoveTimersInArray( p, array);
}


static void
   MulleRunLoopModeRemoveTimersWithPerformRequest( struct MulleRunLoopMode *p,
                                                   id target,
                                                   SEL sel,
                                                   id arg)
{
   NSMutableArray   *array;
   NSTimer          *timer;

   assert( p);

   array = nil;
   for( timer in p->timers)
   {
      if( ! [timer mulleFiresWithUserInfoAsArgument])
         continue;

      // TODO: could use one method to check all three
      if( [timer target] != target || [timer selector] != sel || [timer userInfo] != arg)
         continue;

      if( ! array)
         array = [NSMutableArray array];
      [array addObject:timer];
   }

   MulleRunLoopModeRemoveTimersInArray( p, array);
}



@implementation NSRunLoop

static struct
{
   BOOL   _isFinalizing;
} Self;


- (instancetype) init
{
   self = [super init];
   if( self)
   {
      assert( NSIntMapKeyCallBacks.notakey);  // zero must be allowed
      _modeTable       = NSCreateMapTable( NSObjectMapKeyCallBacks,
                                           NSOwnedPointerMapValueCallBacks,
                                           32);
      _fileHandleTable = NSCreateMapTable( NSIntMapKeyCallBacks,
                                           NSObjectMapValueCallBacks,
                                           32);
      _readyHandles    = [NSMutableArray new];
      if( mulle_thread_mutex_init( &_lock))
      {
         fprintf( stderr, "%s could not get a mutex\n", __FUNCTION__);
         abort();
      }
   }
   return( self);
}


- (void) finalize
{
   NSMapEnumerator           rover;
   NSRunLoopMode             *modeName;
   struct MulleRunLoopMode   *mode;

   rover = NSEnumerateMapTable( _modeTable);
   while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
   {
      if( mode->osspecificFinalize)
         MulleObjCObjectPerformSelector( self, mode->osspecificFinalize, mode->osspecific);
      MulleRunLoopModeDone( mode);
   }
   NSEndMapTableEnumeration( &rover);

   [super finalize];
}


- (void) dealloc
{
   if( _modeTable)
      NSFreeMapTable( _modeTable);
   if( _fileHandleTable)
      NSFreeMapTable( _fileHandleTable);
   [_readyHandles release];

   mulle_thread_mutex_done( &_lock);

   [super dealloc];
}


+ (void) willFinalize
{
   Self._isFinalizing = YES;  // don't lazily create runloops when finalizing
}

//
// There is a problem here if we use NSThreadDictionary: if some other thread
// asks for a foreign thread's currentRunLoop, it's not assured that the
// threadDictionary isn't mutated by another threads while reading.
//
// The solution is to not use the threadDictionary for this. Generally
// accessing the threadDictionary from anything but the currentThread is
// unsafe during "normal" operations
//
static NSRunLoop   *runLoopForThread( NSThread *thread)
{
   NSRunLoop   *runLoop;

   runLoop = [thread mulleRunLoop];
   if( ! runLoop && ! Self._isFinalizing)
   {
      assert( _mulle_objc_universe_is_initialized( _mulle_objc_object_get_universe( thread)));

      runLoop = [[NSRunLoop new] autorelease];
      runLoop = [thread mulleSetRunLoop:runLoop];
   }
   return( runLoop);
}


+ (NSRunLoop *) currentRunLoop
{
   return( runLoopForThread( [NSThread currentThread]));
}


+ (NSRunLoop *) mainRunLoop
{
   return( runLoopForThread( [NSThread mainThread]));
}


- (void) acceptInputForMode:(NSRunLoopMode) modeName
                 beforeDate:(NSDate *) date
{
   struct MulleRunLoopMode  *mode;

   if( _currentModeName)
      [NSException raise:NSInternalInconsistencyException
                  format:@"NSRunLoop is not re-entrant"];

   mode = [self mulleRunLoopModeForMode:modeName];
   if( mode)
   {
      _currentModeName = modeName;
      [self _acceptInputForRunLoopMode:mode
                            beforeDate:date];
      _currentModeName = nil;
   }
}


//
// i have no idea, why anyone would ever call this
// nor why it is specified, that it should fire timers
//
- (NSDate *) limitDateForMode:(NSRunLoopMode) modeName
{
   NSDate                   *date;
   struct MulleRunLoopMode  *mode;

   date = nil;
   mode = [self mulleRunLoopModeForMode:modeName];
   if( mode)
   {
      _currentModeName = modeName;
      date             = [self _limitDateForRunLoopMode:mode];
      _currentModeName = nil;
   }
   // should check for next timer here later
   return( date);
}


- (NSString *) currentMode
{
   return( _currentModeName);
}


//
// Runs the loop **once**, blocking for input in the specified mode until
// a given date.
//
- (BOOL) runMode:(NSRunLoopMode) modeName
      beforeDate:(NSDate *) limitDate
{
   NSTimeInterval               stop;
   struct MulleRunLoopMode      *mode;
   BOOL                         flag;
   enum MulleRunLoopInputState  state;

   if( _currentModeName)
      [NSException raise:NSInternalInconsistencyException
                  format:@"NSRunLoop is not re-entrant"];

   mode = [self mulleRunLoopModeForMode:modeName];
   if( ! mode)
      return( NO);

   //
   //
   //
   if( MulleRunLoopModeIsIdle( mode))
      return( NO);

   _currentModeName = modeName;
   state = [self _acceptInputForRunLoopMode:mode
                                 beforeDate:limitDate];
   _currentModeName = nil;
   fprintf( stderr, "state=%d\n", state);
   return( YES);
}


/*
 * https://developer.apple.com/documentation/foundation/nsrunloop/1415778-rununtildate
 * If no input sources or timers are attached to the run loop, this method
 * exits immediately; otherwise, it runs the receiver in the
 * NSDefaultRunLoopMode by repeatedly invoking runMode:beforeDate: until the
 * specified expiration date.
 */
- (void) runUntilDate:(NSDate *) date
{
   NSTimeInterval           until;
   NSTimeInterval           now;
   struct MulleRunLoopMode  *mode;

   NSParameterAssert( ! date || [date isKindOfClass:[NSDate class]]);

   // assume do/while instead of while/do
   until = [date timeIntervalSinceReferenceDate];
   do
   {
      if( ! [self runMode:NSDefaultRunLoopMode
               beforeDate:date])  // isn't this our date now ?
      {
         fprintf( stderr, "runUntilDate pre-empts\n");
         break;
      }
      now = [NSDate timeIntervalSinceReferenceDate];
      fprintf( stderr, "runUntilDate until: %.3f now: %.3f\n", now, until);
   }
   while( now < until);
}


- (void) run
{
   [self runMode:NSDefaultRunLoopMode
      beforeDate:[NSDate distantFuture]];
}


- (struct MulleRunLoopMode *) mulleRunLoopModeForMode:(NSRunLoopMode) modeName
{
   struct MulleRunLoopMode   *mode;

   mulle_thread_mutex_lock( &_lock);
   mode = NSMapGet( _modeTable, modeName);
   mulle_thread_mutex_unlock( &_lock);
   return( mode);
}


- (NSArray *) _modes
{
   NSMutableArray           *array;
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   array = [NSMutableArray array];
   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         [array addObject:modeName];
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
   return( array);
}


- (void) addTimer:(NSTimer *) timer
          forMode:(NSRunLoopMode) modeName
{
   struct MulleRunLoopMode   *mode;

   if( ! timer || ! modeName)
      return;

   mulle_thread_mutex_lock( &_lock);
   {
      mode = NSMapGet( _modeTable, modeName);
      if( ! mode)
      {
         // don't lock during "sure thing" malloc
         mulle_thread_mutex_unlock( &_lock);
         mode = MulleRunLoopModeCreate( MulleObjCInstanceGetAllocator( self),
                                        modeName);
         mulle_thread_mutex_lock( &_lock);

         NSMapInsertKnownAbsent( _modeTable, modeName, mode);
      }
      MulleRunLoopModeAddTimer( mode, timer);
   }
   mulle_thread_mutex_unlock( &_lock);
}



- (NSTimer *) _firstTimerToFireOfRunLoopMode:(struct MulleRunLoopMode *) mode
{
   NSTimer   *timer;

   NSParameterAssert( mode);

   mulle_thread_mutex_lock( &_lock);
   timer = MulleRunLoopModeGetNextTimerToFire( mode);
   mulle_thread_mutex_unlock( &_lock);
   return( timer);
}


- (void) _fireTimersOfRunLoopMode:(struct MulleRunLoopMode *) mode
                     timeInterval:(NSTimeInterval) timeInterval
{
   NSArray   *timers;
   NSTimer   *timer;

   NSParameterAssert( mode);

   mulle_thread_mutex_lock( &_lock);
   timers = MulleRunLoopModeTimersToFire( mode, timeInterval);
   mulle_thread_mutex_unlock( &_lock);

   for( timer in timers)
   {
      [timer fire];
      // TODO: repeat
   }
}


- (void) _removeTimer:(NSTimer *) timer
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         MulleRunLoopModeRemoveTimer( mode, timer);
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (void) _removeTimersWithTarget:(id) target
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         MulleRunLoopModeRemoveTimersWithTarget( mode, target);
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (void) _removeTimersWithTarget:(id) target
                        selector:(SEL) sel
                        argument:(id) argument
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         MulleRunLoopModeRemoveTimersWithPerformRequest( mode, target, sel, argument);
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (void) _sendMessagesOfRunLoopMode:(struct MulleRunLoopMode *) mode
{
   struct MulleRunLoopMessageArray   torun;
   struct mulle_allocator            *allocator;
   NSInteger                         n;

   allocator = MulleObjCInstanceGetAllocator( self);
   MulleRunLoopMessageArrayInit( &torun, allocator);

   mulle_thread_mutex_lock( &_lock);
   n = MulleRunLoopMessageArrayGetCount( &mode->messages);
   if( n)
   {
      memcpy( &torun, &mode->messages, sizeof( torun));
      //
      // clear messages so new messages can be added
      // tricky to reuse allocated items array here, so we don't
      //
      MulleRunLoopMessageArrayInit( &mode->messages, allocator);
      _mulle_atomic_pointer_add( &mode->nInputsTimersMessages, -n);
   }
   mulle_thread_mutex_unlock( &_lock);

   if( ! n)
      return;

   // send messages, but runloop must be unlocked
   MulleRunLoopMessageArraySendMessages( &torun);
   MulleRunLoopMessageArrayDone( &torun);
}


- (void) performSelector:(SEL) sel
                  target:(id) target
                argument:(id) argument
                   order:(NSUInteger) order
                   modes:(NSArray *) modeNames
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;

   if( ! target)
      return;

   NSParameterAssert( sel);
   NSParameterAssert( [modeNames count]);

   mulle_thread_mutex_lock( &_lock);
   {
      for( modeName in modeNames)
      {
         mode = NSMapGet( _modeTable, modeName);
         if( ! mode)
         {
            // don't lock during "sure thing" malloc
            mulle_thread_mutex_unlock( &_lock);
            mode = MulleRunLoopModeCreate( MulleObjCInstanceGetAllocator( self),
                                           modeName);
            mulle_thread_mutex_lock( &_lock);

            NSMapInsertKnownAbsent( _modeTable, modeName, mode);
         }

         MulleRunLoopModeEnqueueMessage( mode, target, sel, argument, order);
      }
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (void) cancelPerformSelectorsWithTarget:(id) target
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         MulleRunLoopModeDequeueMessagesWithTarget( mode, target);
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (void) cancelPerformSelector:(SEL) sel
                        target:(id) target
                      argument:(id) argument
{
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   mulle_thread_mutex_lock( &_lock);
   {
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
         MulleRunLoopModeDequeueMessage( mode, target, sel, argument);
      NSEndMapTableEnumeration( &rover);
   }
   mulle_thread_mutex_unlock( &_lock);
}


- (NSString *) _runLoopDebugDescription
{
   NSMutableString           *s;
   NSRunLoopMode             modeName;
   struct MulleRunLoopMode   *mode;
   NSMapEnumerator           rover;

   s = [NSMutableString string];
   // do this unlocked for debugging only
   {
      [s appendString:@"modes =\n{\n"];
      rover = NSEnumerateMapTable( _modeTable);
      while( NSNextMapEnumeratorPair( &rover, (void **) &modeName, (void **) &mode))
      {
         [s appendFormat:@"   \"%@\" = {\n      messages = [\n", modeName];
         [s appendString:MulleRunLoopModeMessageArrayDebugDescription( &mode->messages, @"         ")];
         [s appendFormat:@"\n      ]\n   }\n"];
      }
      NSEndMapTableEnumeration( &rover);
      [s appendString:@"}\n"];
   }
   return( s);
}

@end
