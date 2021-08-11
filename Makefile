DEBUG = 1
export TARGET = simulator:clang:14.5:8.0

# Put the correct path for your patched simulator sdk! 
export SYSROOT = $(THEOS)/sdks/iPhoneSimulator14.5.sdk
export ARCHS = arm64


include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libprefs
libprefs_LOGOSFLAGS = -c generator=internal
libprefs_FILES = prefs.xm
libprefs_FRAMEWORKS = UIKit
libprefs_PRIVATE_FRAMEWORKS = Preferences
libprefs_CFLAGS = -I.
libprefs_COMPATIBILITY_VERSION = 2.2.0
libprefs_LIBRARY_VERSION = $(shell echo "$(THEOS_PACKAGE_BASE_VERSION)" | cut -d'~' -f1)
libprefs_LDFLAGS = -compatibility_version $($(THEOS_CURRENT_INSTANCE)_COMPATIBILITY_VERSION)
#libprefs_LDFLAGS += -current_version $($(THEOS_CURRENT_INSTANCE)_LIBRARY_VERSION)

TWEAK_NAME = PreferenceLoader
PreferenceLoader_FILES = Tweak.xm
PreferenceLoader_FRAMEWORKS = UIKit
PreferenceLoader_PRIVATE_FRAMEWORKS = Preferences
PreferenceLoader_LIBRARIES = prefs
PreferenceLoader_CFLAGS = -I.
PreferenceLoader_LDFLAGS = -L$(THEOS_OBJ_DIR)

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

# Here, PreferenceLoader is expected to be linked against `$(THEOS_OBJ_DIR)/libprefs.dylib`,
# however a linker tries to use `$THEOS/vendor/lib/libprefs.tbd`,
# and it fails because `libprefs.tbd` in theos is not built for x86_64.
# This happens because theos internally set "$THEOS/vendor/lib" as a search dir,
# and `PreferenceLoader_LDFLAGS` has lower priority than that.
# In this hack, we force the linker to search `$THEOS_OBJ_DIR` first by setting `$TARGET_LD`.
TARGET_LD := $(TARGET_LD) -L$(THEOS_OBJ_DIR)

include locatesim.mk

setup:: all
	@sudo [ -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_BUNDLES_PATH)
	@sudo [ -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@sudo [ -d $(PL_SIMULATOR_ROOT)/usr/lib ] || sudo mkdir -p $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo rm -f /opt/simject/$(TWEAK_NAME).dylib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject
	@sudo cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject

remove::
	@sudo [ ! -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo rm -r $(PL_SIMULATOR_BUNDLES_PATH)
	@sudo [ ! -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo rm -r $(PL_SIMULATOR_PLISTS_PATH)
	@sudo rm -f $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@sudo rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).plist
