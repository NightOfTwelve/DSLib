
#import <Foundation/Foundation.h>
#import "DSFontManager.h"

struct GUIElements {
	NSString *homeTopNewsTitle;
};
typedef struct GUIElements GUIElements;
extern GUIElements guiElements;

@interface FontsDB : NSObject {
	DSFontManager *fontManager_;
}

+ (FontsDB *)sharedInstance;
- (UIFont *)fontForGUIElement:(NSString *)aGUIElement;

@end
