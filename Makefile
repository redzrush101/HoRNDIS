# For building the driver for macOS 15.0+, use the latest Xcode version
# available on your system.
#
# The driver is compatible with modern macOS versions including Sequoia 15+

-include localconfig.mk

# Can be set from the environment:
HORNDIS_XCODE ?= /Applications/Xcode.app

XCODEBUILD ?= $(wildcard $(HORNDIS_XCODE)/Contents/Developer/usr/bin/xcodebuild)

ifeq (,$(XCODEBUILD))
    $(error Cannot find xcodebuild under $(HORNDIS_XCODE). Please install \
    	Xcode from the Mac App Store or point HORNDIS_XCODE \
    	to your preferred Xcode app path)
endif

# The package signing certificate must either be set or explicitly disabled:
ifeq (,$(CODESIGN_INST))
    $(error Please set CODESIGN_INST variable to your Mac Installer \
      certificate or 'none' if you don't have any. \
      E.g. "export CODESIGN_INST=G3H8VBSL7A")
else ifeq (none,$(CODESIGN_INST))
    # Clear the 'none' vaulue: easier to test in 'if' condition.
    CODESIGN_INST :=
endif

all: build/Release/HoRNDIS.kext build/pkg/_complete

clean:
	rm -rf build

# We now sign as part of the xcodebuild process.
build/Release/HoRNDIS.kext: $(wildcard *.cpp *.h *.plist HoRNDIS.xcodeproj/* *.lproj/*)
	$(XCODEBUILD) -project HoRNDIS.xcodeproj

build/pkg/root: build/Release/HoRNDIS.kext
	rm -rf build/pkg/
	mkdir -p build/pkg/root/Library/Extensions
	cp -R build/Release/HoRNDIS.kext build/pkg/root/Library/Extensions/

build/pkg/HoRNDIS-kext.pkg: build/pkg/root
	pkgbuild --identifier com.joshuawise.kexts.HoRNDIS --scripts package/scripts --root $< $@

# The variable is to be resolved first time it's used:
VERSION = $(shell defaults read $(PWD)/build/Release/HoRNDIS.kext/Contents/Info.plist CFBundleVersion)

build/pkg/_complete: build/pkg/HoRNDIS-kext.pkg $(wildcard package/*)
	productbuild --distribution package/Distribution.xml --package-path build/pkg --resources package --version $(VERSION) $(if $(CODESIGN_INST),--sign $(CODESIGN_INST)) build/HoRNDIS-$(VERSION).pkg && touch build/pkg/_complete
