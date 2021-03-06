
#import <Foundation/Foundation.h>


@interface DSArrayChangeCalculator : NSObject
/** Objects in arrays are compared with isEqual: method
* @return array of DSArrayChange objects
* */
- (NSArray *)calculateChangesFromArray:(NSArray *)initialArray toArray:(NSArray *)newArray;
@end
