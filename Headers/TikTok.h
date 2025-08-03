#import <UIKit/UIKit.h>

// تعريف الكائنات التي تحتوي على بيانات الفيديو
@interface AWEURLModel : NSObject
@property (nonatomic, copy) NSArray *originURLList;
@end

@interface AWEVideoModel : NSObject
@property (nonatomic, strong) AWEURLModel *playURL;
@end

@interface AWEAwemeModel : NSObject
@property (nonatomic, strong) AWEVideoModel *video;
@property (nonatomic, strong) id photoAlbum; 
@end

// تعريف الفئة التي تعرض خلية الفيديو (الهدف الأول)
@interface AWEFeedCellViewController : UIViewController
@property (nonatomic, strong) AWEAwemeModel *model;
@end

// --- الجزء الجديد ---
// تعريف الفئة التي تعرض خلية الستوري (الهدف الثاني)
@interface TTKStoryDetailTableViewCell : UITableViewCell
@property (nonatomic, strong) AWEAwemeModel *model;
@end
