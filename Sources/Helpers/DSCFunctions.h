
#import <Foundation/Foundation.h>

#pragma mark - macros
#define ASSERT_ABSTRACT_METHOD NSAssert(@"%@ is abstract in class '%@'. Overwrite in subclasses", NSStringFromSelector(_cmd), NSStringFromClass([self class]))
#define UNHANDLED_IF else{NSAssert(NO,@"Check last else statement in class: %@; method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));}
#define UNHANDLED_SWITCH NSAssert(NO,@"Check switch statement in class: %@; method: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define SWAP_METHODS(ORIGINAL_SELECTOR, NEW_SELECTOR) {Method originalMethod = class_getInstanceMethod(self, ORIGINAL_SELECTOR); Method overrideMethod = class_getInstanceMethod(self, NEW_SELECTOR); if (class_addMethod(self, ORIGINAL_SELECTOR, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {class_replaceMethod(self, NEW_SELECTOR, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));} else {  method_exchangeImplementations(originalMethod, overrideMethod);}}

#if TARGET_OS_IPHONE
BOOL isIPadIdiom(void);
#endif

#pragma mark - paths
NSString *DSApplicationDocumentDirectoryPath(void);
NSURL *DSApplicationDocumentDirectoryURL(void);

NSUInteger DSNumberOfParamsInSelector(SEL theSelector);
