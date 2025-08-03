#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface TikTokProHelper : NSObject

+ (void)saveMediaFromURL:(NSURL *)mediaURL withExtension:(NSString *)fileExtension;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

