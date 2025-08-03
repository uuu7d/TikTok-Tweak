#import "TikTokProHelper.h"

@implementation TikTokProHelper

+ (void)saveMediaFromURL:(NSURL *)mediaURL withExtension:(NSString *)fileExtension {
    if (!mediaURL) {
        [self showAlertWithTitle:@"خطأ" message:@"لم يتم العثور على رابط صالح."];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *mediaData = [NSData dataWithContentsOfURL:mediaURL];
        if (!mediaData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"خطأ" message:@"فشل تحميل الملف."];
            });
            return;
        }

        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingString:fileExtension]];
        [mediaData writeToFile:tempPath atomically:YES];

        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    if ([fileExtension isEqualToString:@".mp4"]) {
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:tempPath]];
                    } else {
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:tempPath]];
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [self showAlertWithTitle:@"تم بنجاح" message:@"تم حفظ الملف في ألبوم الصور."];
                        } else {
                            [self showAlertWithTitle:@"خطأ" message:[NSString stringWithFormat:@"فشل الحفظ: %@", error.localizedDescription]];
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithTitle:@"خطأ" message:@"الرجاء السماح بالوصول إلى الصور من إعدادات الخصوصية."];
                });
            }
        }];
    });
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"حسنًا" style:UIAlertActionStyleDefault handler:nil]];

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

@end
