#import "Headers/TikTok.h"

// --- تعديل رقم 1: زر التحميل في الـ Feed ---
%hook AWEFeedCellViewController

- (void)viewDidLoad {
    %orig; 

    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    downloadButton.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 350, 50, 50);
    [downloadButton addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadButton];
}

%new
- (void)downloadButtonTapped {
    NSLog(@"[TikTokPro] Download button tapped!");
}

%end


// --- تعديل رقم 2: زر التحميل في الستوري (الجزء الجديد) ---
%hook TTKStoryDetailTableViewCell

// سنستخدم هنا وظيفة `initWithStyle` لأن خلايا الجدول تستخدمها عند إنشائها
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    id self = %orig; // تشغيل الكود الأصلي أولاً

    if (self) {
        // إنشاء زر تحميل الستوري
        UIButton *downloadStoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadStoryButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
        [downloadStoryButton setTintColor:[UIColor whiteColor]];

        // تحديد مكان الزر في زاوية الشاشة العلوية اليمنى
        downloadStoryButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 60, 50, 50);

        // ربط الزر بوظيفة جديدة خاصة به
        [downloadStoryButton addTarget:self action:@selector(downloadStoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];

        // إضافة الزر إلى واجهة الخلية
        [self.contentView addSubview:downloadStoryButton];
    }

    return self;
}

%new
- (void)downloadStoryButtonTapped {
    NSLog(@"[TikTokPro] Download STORY button tapped!");
}

%end
