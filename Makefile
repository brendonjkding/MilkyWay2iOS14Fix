TARGET = iphone:clang:11.2:7.0
ARCHS= arm64 arm64e


INSTALL_TARGET_PROCESSES = SpringBoard



TWEAK_NAME = MilkyWay2iOS14Fix

MilkyWay2iOS14Fix_FILES = Tweak.xm
MilkyWay2iOS14Fix_CFLAGS = -fobjc-arc -Wno-error=unused-variable -Wno-error=unused-function -include Prefix.pch

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
