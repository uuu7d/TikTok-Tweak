# المعمارية المستهدفة (آيفون XS والأحدث)
ARCHS = arm64e

# إعدادات Theos
THEOS_DEVICE_IP =
THEOS_DEVICE_PORT = 22
GO_EASY_ON_ME = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

# اسم الأداة
TWEAK_NAME = TikTokPro

# قائمة ملفات الكود التي سيتم تجميعها (مع تعديل اسم الملف)
TikTokPro_FILES = Tweak.xm TikTokProHelper.mm

# إعدادات المترجم لإيجاد ملفات الـ header
TikTokPro_CFLAGS = -fobjc-arc -I.

# --- السطر الجديد والمهم ---
# إجبار المترجم على استخدام معيار C++11 الحديث
TikTokPro_CXXFLAGS = -std=c++11

# المكتبات التي يعتمد عليها الكود
TikTokPro_FRAMEWORKS = UIKit Foundation CoreGraphics Security Photos

include $(THEOS)/makefiles/tweak.mk
