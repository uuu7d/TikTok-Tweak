#import "Headers/TikTok.h"
#import <Photos/Photos.h>

// #############################################
// ## تعديل رقم 1: زر التحميل في الـ Feed ##
// #############################################
%hook AWEFeedCellViewController

- (void)viewDidLoad {
    %orig;

    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    downloadButton.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 350, 50, 50);

    downloadButton.menu = [self createDownloadMenu];
    downloadButton.showsMenuAsPrimaryAction = YES;

    [self.view addSubview:downloadButton];
}

%new
- (UIMenu *)createDownloadMenu {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    BOOL isVideo = (self.model.video != nil);
    BOOL isPhotos = (self.model.photoAlbum != nil);

    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الفيديو HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *videoURL = [NSURL URLWithString:self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject];
        [self saveMediaFromURL:videoURL withExtension:@".mp4"];
    }];

    UIAction *downloadImageHD = [UIAction actionWithTitle:@"تحميل الصور HD" image:[UIImage systemImageNamed:@"photo.on.rectangle.angled"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *imageURL = [NSURL URLWithString:self.model.photoAlbum.photos.firstObject.originPhotoURL.originURLList.firstObject];
        [self saveMediaFromURL:imageURL withExtension:@".jpg"];
    }];

    if (isVideo) {
        [actions addObject:downloadVideoHD];
        downloadImageHD.attributes = UIMenuElementAttributesDisabled;
        [actions addObject:downloadImageHD];
    } else if (isPhotos) {
        downloadVideoHD.attributes = UIMenuElementAttributesDisabled;
        [actions addObject:downloadVideoHD];
        [actions addObject:downloadImageHD];
    }

    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}

%new
- (void)saveMediaFromURL:(NSURL *)mediaURL withExtension:(NSString *)fileExtension {
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

%new
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"حسنًا" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end

// #####################################
// ## تعديل رقم 2: إزالة الإعلانات ##
// #####################################
%hook AWEAwemeModel
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError **)error {
    id self = %orig;
    if (self && self.isAds) {
        return nil;
    }
    return self;
}
%end

// ##################################################
// ## تعديل رقم 3: زيادة حد الأحرف في التعليقات ##
// ##################################################
%hook AWECommentListInputView
- (long long)getMaxInputCount {
    return 500;
}
%end

// #############################################
// ## تعديل رقم 4: زر التحميل في الستوري   ##
// #############################################
%hook TTKStoryDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    id self = %orig;
    if (self) {
        UIButton *downloadStoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadStoryButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
        [downloadStoryButton setTintColor:[UIColor whiteColor]];
        downloadStoryButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 60, 50, 50);
        downloadStoryButton.menu = [self createDownloadMenu];
        downloadStoryButton.showsMenuAsPrimaryAction = YES;
        [self.contentView addSubview:downloadStoryButton];
    }
    return self;
}

%new
- (UIMenu *)createDownloadMenu {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الستوري HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *videoURL = [NSURL URLWithString:self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject];
        [self saveMediaFromURL:videoURL withExtension:@".mp4"];
    }];
    [actions addObject:downloadVideoHD];
    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}

%new
- (void)saveMediaFromURL:(NSURL *)mediaURL withExtension:(NSString *)fileExtension {
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

%new
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"حسنًا" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end
