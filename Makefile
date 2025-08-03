# المعمارية المستهدفة (آيفون XS والأحدث)
ARCHS = arm64e

# إعدادات Theos
THEOS_DEVICE_IP = # أدخل IP جهازك هنا عند البناء المحلي
THEOS_DEVICE_PORT = 22
GO_EASY_ON_ME = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

# اسم الأداة
TWEAK_NAME = TikTokPro

# قائمة ملفات الكود التي سيتم تجميعها
TikTokPro_FILES = Tweak.xm TikTokProHelper.m

# إعدادات المترجم لإيجاد ملفات الـ header
TikTokPro_CFLAGS = -fobjc-arc -I.

# المكتبات التي يعتمد عليها الكود
TikTokPro_FRAMEWORKS = UIKit Foundation CoreGraphics Security Photos

include $(THEOS)/makefiles/tweak.mk
