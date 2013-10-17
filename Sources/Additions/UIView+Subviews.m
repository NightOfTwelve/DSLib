
#import "UIView+Subviews.h"

@implementation UIView (Subviews)
- (void)enumerateSubviewsUsingBlock:(proccedView_block_t)theBlock
{
  for (UIView *subview in [self subviews]) {
    theBlock(subview);
    [subview enumerateSubviewsUsingBlock:theBlock];
  }
}

- (UIImage *)getSnapshot {
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
  
  [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}
@end
