#import <UIKit/UIKit.h>

// تعريفات أساسية للروابط
@interface AWEURLModel : NSObject
@property (nonatomic, copy) NSArray *originURLList;
@end

// تعريف موديل الفيديو مع خيارات الجودة
@interface AWEVideoModel : NSObject
@property (nonatomic, strong) AWEURLModel *playURL; // جودة عادية
@property (nonatomic, strong) AWEURLModel *hdPlayURL; // جودة عالية (إذا توفرت)
@end

// تعريف موديل الصور
@interface AWEPhotoModel : NSObject
@property (nonatomic, strong) AWEURLModel *originPhotoURL;
@end

// تعريف موديل ألبوم الصور
@interface AWEPhotoAlbumModel : NSObject
@property (nonatomic, copy) NSArray<AWEPhotoModel *> *photos;
@end

// تعريف الموديل الرئيسي للمنشور
@interface AWEAwemeModel : NSObject
@property (nonatomic, strong) AWEVideoModel *video;
@property (nonatomic, strong) AWEPhotoAlbumModel *photoAlbum;
@property (nonatomic, assign) BOOL isAds;
@end

// تعريف الفئات التي سنقوم بتعديلها
@interface AWEFeedCellViewController : UIViewController
@property (nonatomic, strong) AWEAwemeModel *model;
@end

@interface TTKStoryDetailTableViewCell : UITableViewCell
@property (nonatomic, strong) AWEAwemeModel *model;
@end
