#import "Headers/TikTok.h"
#import "TikTokProHelper.h"

/*
    ============= الخطوة 1: تعريف الواجهات (Interfaces) =============
    تم إضافة API_AVAILABLE هنا أيضاً للمساعدة في تقليل التحذيرات.
*/
@interface AWEFeedCellViewController ()
- (UIMenu *)createDownloadMenu API_AVAILABLE(ios(13.0));
@end

@interface TTKStoryDetailTableViewCell ()
- (UIMenu *)createDownloadMenu API_AVAILABLE(ios(13.0));
@end

// =======================================================
//                Hook خاص بالـ Feed
// =======================================================
%hook AWEFeedCellViewController

- (void)viewDidLoad {
    %orig;

    if (@available(iOS 14.0, *)) {
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
        [downloadButton setTintColor:[UIColor whiteColor]];
        
        downloadButton.menu = [self createDownloadMenu];
        downloadButton.showsMenuAsPrimaryAction = YES;
        
        [self.view addSubview:downloadButton];

        downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-15],
            [downloadButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-80],
            [downloadButton.widthAnchor constraintEqualToConstant:50],
            [downloadButton.heightAnchor constraintEqualToConstant:50]
        ]];
    }
}

%new
- (UIMenu *)createDownloadMenu API_AVAILABLE(ios(13.0)) {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];

    BOOL isVideo = (self.model.video != nil);
    BOOL isPhotos = (self.model.photoAlbum.photos.count > 0);

    if (isVideo) {
        UIAction *downloadVideoAction = [UIAction actionWithTitle:@"تحميل الفيديو HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            NSString *urlString = self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject;
            if (urlString) {
                [TikTokProHelper saveMediaFromURL:[NSURL URLWithString:urlString] withExtension:@".mp4"];
            }
        }];
        [actions addObject:downloadVideoAction];
    }
    
    if (isPhotos) {
        UIAction *downloadImagesAction = [UIAction actionWithTitle:@"تحميل كل الصور HD" image:[UIImage systemImageNamed:@"photo.on.rectangle.angled"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            // ✅ الحل: تم تصحيح اسم الكلاس إلى AWEPhotoModel
            for (AWEPhotoModel *photo in self.model.photoAlbum.photos) {
                NSString *urlString = photo.originPhotoURL.originURLList.firstObject;
                if (urlString) {
                    [TikTokProHelper saveMediaFromURL:[NSURL URLWithString:urlString] withExtension:@".jpg"];
                }
            }
        }];
        [actions addObject:downloadImagesAction];
    }

    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}
%end

// =======================================================
//                Hook خاص بالإعلانات
// =======================================================
%hook AWEAwemeModel
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError **)error {
    id instance = %orig;
    if (instance && [instance isAds]) {
        return nil;
    }
    return instance;
}
%end

// =======================================================
//                Hook خاص بالتعليقات
// =======================================================
%hook AWECommentListInputView
- (long long)getMaxInputCount {
    return 500;
}
%end

// =======================================================
//                Hook خاص بالستوري
// =======================================================
%hook TTKStoryDetailTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    id instance = %orig;
    if (instance) {
        if (@available(iOS 14.0, *)) {
            UIButton *downloadStoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [downloadStoryButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
            [downloadStoryButton setTintColor:[UIColor whiteColor]];
            
            downloadStoryButton.menu = [instance createDownloadMenu];
            downloadStoryButton.showsMenuAsPrimaryAction = YES;
            
            [[instance contentView] addSubview:downloadStoryButton];
            
            downloadStoryButton.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[
                [downloadStoryButton.topAnchor constraintEqualToAnchor:[instance contentView].safeAreaLayoutGuide.topAnchor constant:15],
                [downloadStoryButton.trailingAnchor constraintEqualToAnchor:[instance contentView].safeAreaLayoutGuide.trailingAnchor constant:-15],
                [downloadStoryButton.widthAnchor constraintEqualToConstant:40],
                [downloadStoryButton.heightAnchor constraintEqualToConstant:40]
            ]];
        }
    }
    return instance;
}

%new
- (UIMenu *)createDownloadMenu API_AVAILABLE(ios(13.0)) {
    UIAction *downloadStoryAction = [UIAction actionWithTitle:@"تحميل الستوري HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSString *urlString = self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject;
        if (urlString) {
            [TikTokProHelper saveMediaFromURL:[NSURL URLWithString:urlString] withExtension:@".mp4"];
        }
    }];
    return [UIMenu menuWithTitle:@"خيارات التحميل" children:@[downloadStoryAction]];
}
%end

// =======================================================
//                Hook خاص بالإعدادات
// =======================================================
%hook AWESettingsNormalSectionViewModel

- (void)viewDidLoad {
    %orig;

    if ([self.sectionIdentifier isEqualToString:@"account_and_privacy"]) {
        AWESettingItemModel *settingsItem = [[%c(AWESettingItemModel) alloc] init];
        [settingsItem setTitle:@"إعدادات TikTokPro"];

        AWESettingTableViewCell *settingsCell = [[%c(AWESettingTableViewCell) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [settingsCell setItem:settingsItem];
        
        [self insertCell:settingsCell atRow:0];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    %orig;
    
    // ✅ الحل: الرجوع للطريقة الأصلية والأكثر أمانًا للتحقق من الخلية
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:%c(AWESettingTableViewCell)]) {
        AWESettingTableViewCell *settingsCell = (AWESettingTableViewCell *)cell;
        if ([settingsCell.item.title isEqualToString:@"إعدادات TikTokPro"]) {
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=TikTokProPrefs"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    }
}
%end
