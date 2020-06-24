ARCHS = arm64 arm64e
TARGET = iphone:clang:12.2:10.0
INSTALL_TARGET_PROCESSES = SpringBoard Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = killallapps

killallapps_FILES = $(wildcard *.xm *.m)
killallapps_EXTRA_FRAMEWORKS = libhdev
killallapps_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += pref

include $(THEOS_MAKE_PATH)/aggregate.mk
