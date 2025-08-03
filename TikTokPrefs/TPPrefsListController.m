#import "TPPrefsListController.h"

@implementation TPPrefsListController

- (NSArray<NSString *> *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

// --- الوظيفة الجديدة لتنظيف الكاش ---
- (void)cleanCache {
    // تحديد مسارات مجلدات الكاش والملفات المؤقتة لتطبيق تيك توك
    // ملاحظة: قد تحتاج للتحقق من هذه المسارات باستخدام Filza وتعديلها إذا لزم الأمر
    NSString *bundleIdentifier = @"com.zhiliaoapp.musically";
    NSString *appContainerPath = [NSString stringWithFormat:@"/var/mobile/Containers/Data/Application/"];

    // البحث عن مجلد التطبيق الصحيح
    NSString *appPath = nil;
    NSArray *allAppDirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appContainerPath error:nil];
    for (NSString *dir in allAppDirs) {
        NSString *fullPath = [appContainerPath stringByAppendingPathComponent:dir];
        NSString *bundlePath = [fullPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
        if ([plist[@"MCMMetadataIdentifier"] isEqualToString:bundleIdentifier]) {
            appPath = fullPath;
            break;
        }
    }

    if (!appPath) {
        [self showAlertWithTitle:@"خطأ" message:@"لم يتم العثور على مجلد التطبيق."];
        return;
    }

    // تحديد المسارات المستهدفة داخل مجلد التطبيق
    NSArray *pathsToClean = @[
        [appPath stringByAppendingPathComponent:@"Library/Caches"],
        [appPath stringByAppendingPathComponent:@"tmp"]
    ];

    // بدء عملية الحذف وحساب الحجم
    __block double totalSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (NSString *path in pathsToClean) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString *file in files) {
            NSString *filePath = [path stringByAppendingPathComponent:file];
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
            totalSize += [attributes[NSFileSize] doubleValue];
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }

    // عرض رسالة للمستخدم
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
    NSString *message = [NSString stringWithFormat:@"تم تنظيف %@ بنجاح!", sizeString];
    [self showAlertWithTitle:@"تم التنظيف" message:message];
}

// --- وظيفة مساعدة لعرض التنبيهات ---
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"حسنًا" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
