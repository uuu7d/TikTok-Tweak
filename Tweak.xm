#import "Headers/TikTok.h"
#import <Photos/Photos.h> // لاستخدام مكتبة الصور

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

    // --- خيارات الفيديو ---
    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الفيديو HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        // نحاول الحصول على رابط HD، وإذا لم يكن موجودًا نستخدم الرابط العادي
        NSURL *videoURL = [NSURL URLWithString:self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject];
        [self saveMediaFromURL:videoURL withExtension:@".mp4"];
    }];

    // --- خيارات الصور ---
    UIAction *downloadImageHD = [UIAction actionWithTitle:@"تحميل الصور HD" image:[UIImage systemImageNamed:@"photo.on.rectangle.angled"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        // حاليًا نحمل أول صورة فقط كمثال
        NSURL *imageURL = [NSURL URLWithString:self.model.photoAlbum.photos.firstObject.originPhotoURL.originURLList.firstObject];
        [self saveMediaFromURL:imageURL withExtension:@".jpg"];
    }];

    // --- تطبيق الشرط ---
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

// --- وظيفة جديدة للتحميل والحفظ ---
%new
- (void)saveMediaFromURL:(NSURL *)mediaURL withExtension:(NSString *)fileExtension {
    if (!mediaURL) {
        [self showAlertWithTitle:@"خطأ" message:@"لم يتم العثور على رابط صالح."];
        return;
    }

    // بدء التحميل في الخلفية
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *mediaData = [NSData dataWithContentsOfURL:mediaURL];
        if (!mediaData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"خطأ" message:@"فشل تحميل الملف."];
            });
            return;
        }

        // كتابة الملف مؤقتًا على الجهاز
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingString:fileExtension]];
        [mediaData writeToFile:tempPath atomically:YES];

        // طلب صلاحية الوصول إلى الصور وحفظ الملف
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

// --- وظيفة مساعدة لعرض التنبيهات ---
%new
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"حسنًا" style:UIAlertActionStyleDefault handler:nil]];

    // البحث عن الواجهة الرئيسية لعرض التنبيه
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end
// --- تعديل رقم 3: إزالة الإعلانات ---
%hook AWEAwemeModel

// هذه الوظيفة يتم استدعاؤها عند إنشاء أي منشور (فيديو، صور، إعلان)
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError **)error {
    // نشغل الكود الأصلي أولاً للسماح بإنشاء المنشور
    id self = %orig;

    // نتحقق مما إذا كان المنشور إعلانًا
    if (self && self.isAds) {
        // إذا كان إعلانًا، نرجع "لا شيء" (nil) لمنعه من الظهور
        return nil;
    }

    // إذا لم يكن إعلانًا، نرجعه ليظهر بشكل طبيعي
    return self;
}

%end

