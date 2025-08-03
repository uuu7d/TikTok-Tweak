#import "Headers/TikTok.h"

// --- تعديل رقم 1: زر التحميل القائمة في الـ Feed ---
%hook AWEFeedCellViewController

- (void)viewDidLoad {
    %orig;

    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    downloadButton.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 350, 50, 50);

    // --- التغيير الرئيسي هنا ---
    // بدلاً من ربط الزر بوظيفة واحدة، نربطه بقائمة من الخيارات
    downloadButton.menu = [self createDownloadMenu];
    downloadButton.showsMenuAsPrimaryAction = YES; // لجعل القائمة تظهر بضغطة زر عادية

    [self.view addSubview:downloadButton];
}

// --- وظيفة جديدة لإنشاء القائمة ---
%new
- (UIMenu *)createDownloadMenu {
    // مصفوفة لتخزين الخيارات التي ستظهر في القائمة
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];

    // التحقق من نوع المحتوى: هل هو فيديو أم صور؟
    BOOL isVideo = (self.model.video != nil);
    BOOL isPhotos = (self.model.photoAlbum != nil);

    // --- إنشاء خيارات الفيديو ---
    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الفيديو HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"[TikTokPro] User selected: Download Video HD");
    }];

    UIAction *downloadVideoNormal = [UIAction actionWithTitle:@"تحميل الفيديو (جودة عادية)" image:[UIImage systemImageNamed:@"sd.video"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"[TikTokPro] User selected: Download Video Normal");
    }];

    // --- إنشاء خيارات الصور ---
    UIAction *downloadImageHD = [UIAction actionWithTitle:@"تحميل الصورة HD" image:[UIImage systemImageNamed:@"photo.on.rectangle.angled"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"[TikTokPro] User selected: Download Image HD");
    }];

    UIAction *downloadImageAsVideo = [UIAction actionWithTitle:@"تحميل الصور كفيديو" image:[UIImage systemImageNamed:@"film"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"[TikTokPro] User selected: Download Images as Video");
    }];

    // --- تطبيق الشرط: تفعيل أو تعطيل الخيارات ---
    if (isVideo) {
        // إذا كان المحتوى فيديو، فعّل خيارات الفيديو وعطّل خيارات الصور
        [actions addObject:downloadVideoHD];
        [actions addObject:downloadVideoNormal];
        downloadImageHD.attributes = UIMenuElementAttributesDisabled;
        downloadImageAsVideo.attributes = UIMenuElementAttributesDisabled;
        [actions addObject:downloadImageHD];
        [actions addObject:downloadImageAsVideo];
    } else if (isPhotos) {
        // إذا كان المحتوى صورًا، فعّل خيارات الصور وعطّل خيارات الفيديو
        downloadVideoHD.attributes = UIMenuElementAttributesDisabled;
        downloadVideoNormal.attributes = UIMenuElementAttributesDisabled;
        [actions addObject:downloadVideoHD];
        [actions addObject:downloadVideoNormal];
        [actions addObject:downloadImageHD];
        [actions addObject:downloadImageAsVideo];
    }

    // إنشاء وإرجاع القائمة النهائية
    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}

%end


// ملاحظة: سنقوم بتطبيق نفس المنطق لاحقًا على شاشة الستوري
// ولكن لنركز على الـ Feed أولاً حتى نتقن الفكرة.
