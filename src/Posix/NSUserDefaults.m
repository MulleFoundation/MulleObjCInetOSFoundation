/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSUserDefaults.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSUserDefaults.h"


NSString   *NSGlobalDomain       = @"NSGlobalDomain";
NSString   *NSArgumentDomain     = @"NSArgumentDomain";
NSString   *NSRegistrationDomain = @"NSRegistrationDomain";
static NSString   *NSApplicationDomain  = @"NSApplicationDomain";


@implementation NSUserDefaults

+ (NSUserDefaults *)  standardUserDefaults
{
   return( [NSUserDefaults sharedInstance]);
}


- (id) init
{
   _domains    = [NSMutableDictionary new];
   _searchList = [[NSMutableArray alloc] initWithObjects:NSApplicationDomain, nil];
   
   return( self);
}


- (void) dealloc
{
   [_domains release];
   [_searchList release];
   [super dealloc];
}


- (id) objectForKey:(NSString *) key
{
   NSEnumerator   *rover;
   NSDictionary   *domain;
   NSString       *name;
   id             value;
   
   rover = [_searchList objectEnumerator];
   while( name = [rover nextObject])
   {
      domain = [_domains objectForKey:name];
      value  = [domain objectForKey:key];
      if( value)
         return( value);
   }
   return( nil);
}


static NSMutableDictionary   *applicationDomain( NSUserDefaults *self)
{  
   NSMutableDictionary   *domain;
   
   domain = [self->_domains objectForKey:NSApplicationDomain];
   if( ! domain)
   {
      domain = [NSMutableDictionary new];
      [self->_domains setObject:domain
                         forKey:NSApplicationDomain];
      [domain release];
   }
   return( domain);
}

- (void) setObject:(id) value 
            forKey:(NSString *) key
{
   [applicationDomain( self) setObject:value
                               forKey:key];
}

            
- (void) removeObjectForKey:(NSString *) key
{
   NSMutableDictionary  *domain;
   
   domain = [_domains objectForKey:NSApplicationDomain];
   [domain removeObjectForKey:key];
}


- (void) registerDefaults:(NSDictionary *) defaults
{ 
   NSMutableDictionary  *dict;

   NSParameterAssert( [defaults isKindOfClass:[NSDictionary class]]);

   dict = [_domains objectForKey:NSRegistrationDomain];
   if( ! dict)
   {
      dict = [NSMutableDictionary dictionary];
      [_searchList addObject:NSRegistrationDomain];
   }
   [dict addEntriesFromDictionary:defaults];
   
   [_domains setObject:dict
                 forKey:NSRegistrationDomain];
}


- (NSDictionary *) dictionaryRepresentation
{
   NSMutableDictionary   *dict;
   
   NSEnumerator   *rover;
   NSDictionary   *domain;
   NSString       *name;
   
   dict  = [NSMutableDictionary dictionary];
   
   rover = [_searchList objectEnumerator];
   while( name = [rover nextObject])
   {
      domain = [_domains objectForKey:name];
      [dict addEntriesFromDictionary:domain];
   }
   return( dict);
}


- (BOOL) synchronize
{
   return( NO);
}

@end


@implementation NSUserDefaults( Conveniences)

static id   objectValueOfClassForKey( NSUserDefaults *self, Class cls, NSString *key)
{
   id   value;
   
   value = [self objectForKey:key];
   if( ! [value isKindOfClass:cls])
      value = nil;
   return( value);
}


static id   objectValueOfSelectorForKey( NSUserDefaults *self, SEL sel, NSString *key)
{
   id   value;
   
   value = [self objectForKey:key];
   if( ! [value respondsToSelector:sel])
      value = nil;
   return( value);
}


- (NSInteger) integerForKey:(NSString *) key
{
   return( [objectValueOfSelectorForKey( self, @selector( integerValue), key) integerValue]);
}


- (float) floatForKey:(NSString *) key;
{
   return( [objectValueOfSelectorForKey( self, @selector( floatValue), key) floatValue]);
}


- (double) doubleForKey:(NSString *) key;
{
   return( [objectValueOfSelectorForKey( self, @selector( doubleValue), key) doubleValue]);
}



- (BOOL) boolForKey:(NSString *) key;
{
   return( [objectValueOfSelectorForKey( self, @selector( boolValue), key) boolValue]);
}



- (NSString *) stringForKey:(NSString *) key;
{
   return( objectValueOfClassForKey( self, [NSString class], key));
}


- (NSArray *) arrayForKey:(NSString *) key;
{
   return( objectValueOfClassForKey( self, [NSArray class], key));
}


- (NSDictionary *) dictionaryForKey:(NSString *) key;
{
   return( objectValueOfClassForKey( self, [NSDictionary class], key));
}


- (NSData *) dataForKey:(NSString *) key;
{
   return( objectValueOfClassForKey( self, [NSData class], key));
}


- (NSArray *) stringArrayForKey:(NSString *) key;
{
   NSArray        *array;
   NSEnumerator   *rover;
   NSString       *s;
   Class          cls;
   
   cls   = [NSString class];
   array = objectValueOfClassForKey( self, [NSArray class], key);
   rover = [array objectEnumerator];
   while( s = [rover nextObject])
      if( ! [s isKindOfClass:cls])
         return( nil);
   return( array);
}


- (void) setInteger:(NSInteger)value 
             forKey:(NSString *) key;
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setFloat:(float) value 
           forKey:(NSString *) key;
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setDouble:(double) value 
            forKey:(NSString *) key;
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setBool:(BOOL) value 
          forKey:(NSString *) key
{
   [self setObject:[NSNumber numberWithBool:value]
            forKey:key];
}

@end


