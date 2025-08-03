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
@end

// تعريف الفئة التي تعرض خلية الفيديو (هدفنا)
@interface AWEFeedCellViewController : UIViewController
@property (nonatomic, strong) AWEAwemeModel *model;
@end
