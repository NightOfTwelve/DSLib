#import <Foundation/Foundation.h>
#import "DSCFunctions.h"

#define DS_SAVE_RELEASE(obj) [obj release]; obj = nil;

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;

#define iOS7orHigher ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7)
#define isScreenSizeHigherThanIPhone4 ([[UIScreen mainScreen] preferredMode].size.height > 480 * [[UIScreen mainScreen] scale] && !isIPadIdiom())

#define ASSERT_MAIN_THREAD NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"%@:%@ should run main thread.", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

#define CASSERT_MAIN_THREAD NSCAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"This block should run main thread.")

#define DS_DESIGNATED_INIT

#define DISPATCH_AFTER_SECONDS_Q(TIME_IN_SECONDS, BLOCK, queue) {double delayInSeconds = TIME_IN_SECONDS;dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));dispatch_after(popTime, queue, BLOCK);}
#define DISPATCH_AFTER_SECONDS(TIME_IN_SECONDS, BLOCK) {DISPATCH_AFTER_SECONDS_Q(TIME_IN_SECONDS, BLOCK, dispatch_get_main_queue())}


#define ASSERT_ABSTRACT_METHOD NSAssert(@"%@ is abstract in class '%@'. Overwrite in subclasses", NSStringFromSelector(_cmd), NSStringFromClass([self class]))
#define UNHANDLED_IF else{NSAssert(NO,@"Check last else statement in class: %@; method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));}
#define UNHANDLED_SWITCH NSAssert(NO,@"Check switch statement in class: %@; method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

#define SWAP_METHODS(ORIGINAL_SELECTOR, NEW_SELECTOR) {Method originalMethod = class_getInstanceMethod(self, ORIGINAL_SELECTOR); Method overrideMethod = class_getInstanceMethod(self, NEW_SELECTOR); if (class_addMethod(self, ORIGINAL_SELECTOR, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {class_replaceMethod(self, NEW_SELECTOR, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));} else {  method_exchangeImplementations(originalMethod, overrideMethod);}}

#define DSRGBA(r,g,b,a) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a/255.]
#define DSRGB(r,g,b) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1.0]
#define DSRGB_CG(r,g,b) [DSRGB(r,g,b) CGColor]
#define DSRGBA_CG(r,g,b,a) [DSRGBA(r,g,b,a) CGColor]

#define DSWEAK_SELF(variable_name) __weak typeof(self) variable_name = self
