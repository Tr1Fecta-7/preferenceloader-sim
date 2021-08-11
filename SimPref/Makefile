# Replace the SDK version (14.5) in target to your SDK's version
export TARGET = simulator:clang:14.5:8.0

# Put the correct path for your patched simulator SDK! 
export SYSROOT = $(THEOS)/sdks/iPhoneSimulator14.5.sdk
export ARCHS = x86_64 arm64


include $(THEOS)/makefiles/common.mk
include ../locatesim.mk

TWEAK_NAME = SimPrefTweak
SimPrefTweak_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = SimPref
SimPref_FILES = SimPref.m
SimPref_INSTALL_PATH = /Library/PreferenceBundles
SimPref_PRIVATE_FRAMEWORKS = Preferences
SimPref_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

setup:: all
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
	@sudo cp -v $(PWD)/entry.plist $(PL_SIMULATOR_PLISTS_PATH)/$(BUNDLE_NAME).plist
	@sudo cp -vR $(THEOS_OBJ_DIR)/$(BUNDLE_NAME).bundle $(PL_SIMULATOR_BUNDLES_PATH)/

remove::
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).plist
	@sudo [ ! -d $(PL_SIMULATOR_BUNDLES_PATH)/$(BUNDLE_NAME).bundle ] || sudo rm -rf $(PL_SIMULATOR_BUNDLES_PATH)/$(BUNDLE_NAME).bundle
