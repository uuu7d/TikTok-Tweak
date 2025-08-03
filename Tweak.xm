#import "Headers/TikTok.h"
#import "TikTokProHelper.h" // استدعاء الفئة المساعدة الجديدة

// Hook خاص بالـ Feed
%hook AWEFeedCellViewController
- (void)viewDidLoad { %orig;
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [downloadButton setTintColor:[UIColor whiteColor]];
    downloadButton.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 350, 50, 50);
    downloadButton.menu = [self createDownloadMenu];
    downloadButton.showsMenuAsPrimaryAction = YES;
    [self.view addSubview:downloadButton];
}
%new - (UIMenu *)createDownloadMenu {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    BOOL isVideo = (self.model.video != nil);
    BOOL isPhotos = (self.model.photoAlbum != nil);
    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الفيديو HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *videoURL = [NSURL URLWithString:self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject];
        [TikTokProHelper saveMediaFromURL:videoURL withExtension:@".mp4"]; // استدعاء من الفئة المساعدة
    }];
    UIAction *downloadImageHD = [UIAction actionWithTitle:@"تحميل الصور HD" image:[UIImage systemImageNamed:@"photo.on.rectangle.angled"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *imageURL = [NSURL URLWithString:self.model.photoAlbum.photos.firstObject.originPhotoURL.originURLList.firstObject];
        [TikTokProHelper saveMediaFromURL:imageURL withExtension:@".jpg"]; // استدعاء من الفئة المساعدة
    }];
    if (isVideo) { [actions addObject:downloadVideoHD]; downloadImageHD.attributes = UIMenuElementAttributesDisabled; [actions addObject:downloadImageHD];
    } else if (isPhotos) { downloadVideoHD.attributes = UIMenuElementAttributesDisabled; [actions addObject:downloadVideoHD]; [actions addObject:downloadImageHD]; }
    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}
%end

// Hook خاص بالإعلانات
%hook AWEAwemeModel
- (id)initWithDictionary:(NSDictionary *)dict error:(NSError **)error { id self = %orig; if (self && self.isAds) { return nil; } return self; }
%end

// Hook خاص بالتعليقات
%hook AWECommentListInputView
- (long long)getMaxInputCount { return 500; }
%end

// Hook خاص بالستوري
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
%new - (UIMenu *)createDownloadMenu {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    UIAction *downloadVideoHD = [UIAction actionWithTitle:@"تحميل الستوري HD" image:[UIImage systemImageNamed:@"4k.tv"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *videoURL = [NSURL URLWithString:self.model.video.hdPlayURL.originURLList.firstObject ?: self.model.video.playURL.originURLList.firstObject];
        [TikTokProHelper saveMediaFromURL:videoURL withExtension:@".mp4"]; // استدعاء من الفئة المساعدة
    }];
    [actions addObject:downloadVideoHD];
    return [UIMenu menuWithTitle:@"خيارات التحميل" children:actions];
}
%end
// اعدادات
%hook AWESettingsNormalSectionViewModel

// يتم استدعاؤها عند تحميل أي قسم في الإعدادات
- (void)viewDidLoad {
    %orig;

    // نتحقق مما إذا كنا في قسم "الحساب"
    if ([self.sectionIdentifier isEqualToString:@"account_and_privacy"]) {

        // إنشاء عنصر جديد في القائمة
        AWESettingItemModel *settingsItem = [[%c(AWESettingItemModel) alloc] init];
        [settingsItem setTitle:@"إعدادات TikTokPro"];

        // إنشاء الخلية التي ستعرض العنصر
        AWESettingTableViewCell *settingsCell = [[%c(AWESettingTableViewCell) alloc] initWithStyle:0 reuseIdentifier:nil];
        [settingsCell setItem:settingsItem];

        // إضافة الخلية إلى بداية قسم "الحساب"
        [self insertCell:settingsCell atRow:0];
    }
}

// يتم استدعاؤها عند الضغط على أي خلية
- (void)tableView:(id)tableView didSelectRowAtIndexPath:(id)indexPath {
    %orig;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:%c(AWESettingTableViewCell)]) {
        AWESettingTableViewCell *settingsCell = (AWESettingTableViewCell *)cell;
        if ([settingsCell.item.title isEqualToString:@"إعدادات TikTokPro"]) {

            // عند الضغط على الزر الخاص بنا، نقوم بفتح إعدادات النظام
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=TikTokProPrefs"];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

%end
