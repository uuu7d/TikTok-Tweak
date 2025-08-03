#import "Headers/TikTok.h"

// نبدأ التعديل على الفئة المسؤولة عن خلايا الفيديو
%hook AWEFeedCellViewController

// سنقوم بإضافة الكود الخاص بنا داخل وظيفة viewDidLoad
// هذه الوظيفة يتم استدعاؤها مرة واحدة عند إنشاء خلية الفيديو
- (void)viewDidLoad {
    %orig; // مهم جدًا: هذا السطر يشغل الكود الأصلي لتيك توك أولاً

    // إنشاء زر التحميل
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];

    // تحديد أيقونة للزر (نستخدم أيقونات النظام SF Symbols)
    [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];

    // تغيير لون الأيقونة إلى الأبيض
    [downloadButton setTintColor:[UIColor whiteColor]];

    // تحديد مكان وحجم الزر (يمكنك تعديل الأرقام لتغيير مكانه)
    // سيكون على يمين الشاشة فوق زر اللايكات
    downloadButton.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 350, 50, 50);

    // ربط الزر بوظيفة جديدة سنقوم بإنشائها اسمها downloadButtonTapped
    [downloadButton addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    // إضافة الزر إلى واجهة خلية الفيديو
    [self.view addSubview:downloadButton];
}

// إنشاء وظيفة جديدة لتنفيذها عند الضغط على الزر
%new
- (void)downloadButtonTapped {
    // حاليًا، سنقوم فقط بطباعة رسالة للتأكد من أن الزر يعمل
    NSLog(@"[TikTokPro] Download button tapped!");
}

%end
