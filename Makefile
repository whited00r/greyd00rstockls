GO_EASY_ON_ME = 1
THEOS_DEVICE_IP = 192.168.1.19
include $(THEOS)/makefiles/common.mk
ARCHS = armv7

BUNDLE_NAME = Greyd00rStockLS
Greyd00rStockLS_FILES = Greyd00rStockLockscreen.mm NSData+Base64.m Greyd00rStockLSViewController.m Greyd00rStockLSView.m UIImage+StackBlur.m GDBannerListController.m GDBannerCell.m GDScrollUnlockView.m UIImage+AverageColor.m UIImage+Resize.m UIImage+LiveBlur.m
Greyd00rStockLS_INSTALL_PATH = /Library/liblockscreen/Lockscreens/
Greyd00rStockLS_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore CoreText MediaPlayer Security

include $(THEOS_MAKE_PATH)/bundle.mk
after-install::
	install.exec "killall -9 SpringBoard"