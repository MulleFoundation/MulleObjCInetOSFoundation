#
# The following includes include definitions generated
# during `mulle-sde update`. Don't edit those files. They are
# overwritten frequently.
#
# === MULLE-SDE START ===

include( _Headers)
include( _Sources)

# === MULLE-SDE END ===
#

# add ignored headers back in
set( PUBLIC_HEADERS
"./_MulleObjCDarwinFoundation-import.h"
"./_MulleObjCDarwinFoundation-include.h"
${PUBLIC_HEADERS}
)

set( PRIVATE_HEADERS
"./_MulleObjCDarwinFoundation-import-private.h"
"./_MulleObjCDarwinFoundation-include-private.h"
${PRIVATE_HEADERS}
)

#
# You can put more source and resource file definitions here.
#
