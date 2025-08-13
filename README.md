# HoRNDIS: USB Tethering Driver for macOS

**HoRNDIS** (pronounced *"horrendous"*) is a driver for macOS that enables native [USB tethering](http://en.wikipedia.org/wiki/Tethering) from your Android phone to your Mac, providing Internet access. This version has been updated to ensure compatibility with macOS Sequoia (15.0) and later.

For more information, visit the [HoRNDIS home page](http://www.joshuawise.com/horndis).

## Important Notes
- This project no longer supports installation via Homebrew due to compatibility and maintenance constraints.
- Pre-built releases are not provided. You must download the `Xcodeproj` and compile the driver yourself.

## Installation
### From Source
1. Clone the repository:
   ```sh
   git clone <repository-url>
   ```
2. Navigate to the project directory and build the kernel extension (kext) using Xcode:
   ```sh
   cd ~/HoRNDIS
   xcodebuild
   ```
3. To create an installation package, run:
   ```sh
   make
   ```
   The package will be generated in the `build/` directory.
4. Run the generated installation package to install the driver.

## Configuration
1. After successful installation, connect your Android phone to your Mac via USB.
2. On your phone, navigate to the settings menu.
3. In the connections section (typically under Wi-Fi or Bluetooth):
   - Select "More..." or "Connections."
   - Select "Tethering & portable hotspot."
4. Enable the "USB tethering" option. It should flash once and then remain checked.

## Uninstallation
1. Remove the `HoRNDIS.kext` from the following directories:
   ```sh
   sudo rm -rf /System/Library/Extensions/HoRNDIS.kext
   sudo rm -rf /Library/Extensions/HoRNDIS.kext
   ```
2. Restart your computer to complete the uninstallation.

## Building the Source
- Clone the repository using:
  ```sh
  git clone <repository-url>
  ```
- Run `xcodebuild` in the project directory to build the kernel extension.
- Optionally, run `make` to create an installation package in the `build/` directory.

## Debugging and Development Notes
This section provides tips for developing and debugging the HoRNDIS driver.

### USB Device Information
- **System Report**: Navigate to *Apple Menu* → *About This Mac* → *System Report* → *Hardware* → *USB* to view recognized USB devices. Note that this does not include USB descriptors.
- **lsusb**: To view detailed USB configuration (e.g., interface and endpoint descriptors), use:
  ```sh
  lsusb -v
  ```
  Install `usbutils` to use this command:
  - **Homebrew**: `brew install mikhailai/misc/usbutils` (Do **not** use the `lsusb` package from Homebrew Core, as it is a different utility.)
  - **MacPorts**: `sudo port install usbutils`

### IO Registry
- To inspect macOS IO Registry information for USB devices:
  ```sh
  ioreg -l -r -c IOUSBHostDevice
  ```
  This shows how macOS recognizes USB devices and matches drivers to interfaces. For the full IO Registry, use `ioreg -l`.

### OS Logging
- The `LOG(....)` statements in the HoRNDIS code use `IOLog` functions.
- On macOS El Capitan (10.11) and earlier, logs are written to `/var/log/system.log`.
- On macOS Sierra (10.12) and later, view logs via:
  - **GUI**: Open the *Console* app (in *Utilities*), and filter with `process:kernel` in the search bar.
  - **Command Line**:
    ```sh
    log show --predicate 'process=="kernel"' --start "$(date -v-3M +'%F %T')"
    ```
    This displays logs from the past 3 minutes. Adjust the time as needed (e.g., `--start "2025-08-12 18:00:00"`).
- **Note**: macOS logging (especially in Sierra) can be unreliable, with garbled or missing messages. Reloading the driver may resolve some issues.

## Compatibility
This version of HoRNDIS is designed for macOS Sequoia (15.0) and later. Older macOS versions may require earlier versions of the driver (not maintained in this repository).
