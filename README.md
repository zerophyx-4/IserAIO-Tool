# IserToolkit - System Tweaks & Device Spoof Manager

Advanced Android system toolkit for device tweaking, performance optimization, and device spoofing with vendor integration support.

## 🎯 Features

- **System Tweaks** - Customize system properties (blur, glass effect, thermal control, etc.)
- **Device Spoofing** - Spoof device info globally or per-app (Netflix, Google Photos, etc.)
- **Performance Profiles** - Gaming, Performance, Balanced, Daily, Battery, Cool Down modes
- **Per-App Settings** - Apply tweaks per individual application
- **ROM Detection** - Auto-detect HyperOS, ColorOS, Oxygen OS, AOSP, and more
- **Real-time Stats** - CPU, GPU, Temperature, RAM monitoring
- **Multi-theme Support** - 6 color themes available

## 📋 Requirements

- **Android**: 14+ (targetSdk 36)
- **Java**: JDK 17 (Temurin recommended)
- **Gradle**: 8.3+
- **Flutter**: Latest stable version

## 🚀 Quick Start

### 1. Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/isertoolkit.git
cd isertoolkit

# Get Flutter dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

### 2. Generated APK Location
```
android/app/build/outputs/apk/release/app-release.apk
android/app/build/outputs/flutter-apk/app-release.apk
```

### 3. Build Helper Script
```powershell
.\build_release.ps1
```

## 🔧 Vendor Integration Setup

### Overview
To integrate IserToolkit with your ROM/vendor build, you need to:
1. Create vendor init scripts
2. Set SELinux permissions
3. Setup daemon socket communication
4. Define system properties

### Step 1: Vendor Init Scripts (`vendor/etc/init/`)

Create `vendor/etc/init/hsr_daemon.rc`:
```ini
# HSR Daemon Service
service hsr_daemon /system/bin/hsr_daemon
    class main
    user root
    group root system
    seclabel u:r:hsr_daemon:s0
    socket hsr_daemon stream 0660 root system
    disabled

# Start service on boot (optional)
on property:persist.sys.hsr.enable=1
    start hsr_daemon

on property:persist.sys.hsr.enable=0
    stop hsr_daemon
```

Create `vendor/etc/init/hsr_props.rc`:
```ini
# HSR System Properties
on property:sys.boot_completed=1
    # Device detection (read from build.prop)
    setprop ro.aiotool.hsr.device_name "${ro.product.device}"
    setprop ro.aiotool.hsr.chipset "${ro.chipname}"
    setprop ro.aiotool.hsr.kernel_ver "${ro.kernel.version}"
    
    # ROM detection
    setprop ro.aiotool.hsr.rom_name "your_rom_name"
    setprop ro.aiotool.hsr.android_ver 14
    setprop ro.aiotool.hsr.os_version 1
```

### Step 2: SELinux Policy (`device/vendor/sepolicy/`)

Create `hsr_daemon.te`:
```te
# HSR Daemon Type
type hsr_daemon, domain;
type hsr_daemon_exec, exec_type, vendor_file_type, file_type;

# Allow daemon to run
init_daemon_domain(hsr_daemon)

# Allow system property access
allow hsr_daemon property_socket:sock_file w_file_perms;
allow hsr_daemon init:unix_stream_socket connectto;

# Allow setting properties
allow hsr_daemon vendor_init:unix_stream_socket connectto;
allow hsr_daemon property_enum_service:service_manager find;

# Allow socket communication
allow hsr_daemon self:capability { dac_override setgid setuid };
allow hsr_daemon self:unix_stream_socket create_stream_socket_perms;

# Allow access to /dev/socket/hsr_daemon
allow hsr_daemon self:unix_stream_socket { create_socket_perms };
allow hsr_daemon property_socket:sock_file { getattr open read write };

# Thermal & Performance
allow hsr_daemon sysfs_thermal:file rw_file_perms;
allow hsr_daemon sysfs_cpufreq:file rw_file_perms;
allow hsr_daemon sysfs_gpufreq:file rw_file_perms;

# Device tree
allow hsr_daemon sysfs_devicetree:file r_file_perms;
```

Create `file_contexts`:
```te
/system/bin/hsr_daemon              u:object_r:hsr_daemon_exec:s0
/dev/socket/hsr_daemon              u:object_r:hsr_daemon:s0
```

### Step 3: Daemon Binary Integration

Place your native daemon at:
```
device/vendor/bin/hsr_daemon
```

The daemon should:
1. Listen on Unix socket `/dev/socket/hsr_daemon`
2. Accept commands like:
   - `SET_PROFILE:gaming`
   - `SET_PROFILE:balanced`
   - `GET_THERMAL`
   - etc.
3. Have root privileges to modify system properties

### Step 4: Android.mk Integration

Add to your `device/vendor/Android.mk`:
```makefile
LOCAL_PATH := $(call my-dir)

# HSR Daemon
include $(CLEAR_VARS)
LOCAL_MODULE := hsr_daemon
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/bin
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES := hsr_daemon
LOCAL_POST_INSTALL_CMD := chmod +x $(LOCAL_BUILT_MODULE)
include $(BUILD_PREBUILT)

# HSR Init Scripts
include $(CLEAR_VARS)
LOCAL_MODULE := hsr_daemon.rc
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/etc/init
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := hsr_daemon.rc
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := hsr_props.rc
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/etc/init
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := hsr_props.rc
include $(BUILD_PREBUILT)
```

### Step 5: System Properties in build.prop

Add to `vendor/build.prop`:
```properties
# HSR Toolkit
ro.aiotool.hsr.rom_name=your_rom_name
ro.aiotool.hsr.android_ver=14
ro.aiotool.hsr.os_version=1

# Device Info
ro.aiotool.hsr.device_name=device_name
ro.aiotool.hsr.chipset=chipset_name
ro.aiotool.hsr.kernel_ver=kernel_version
```

## 📱 How It Works

### Data Flow
```
Flutter App (UI)
    ↓
MethodChannel (Android Native)
    ↓
SystemPropsHelper (Kotlin - SystemProperties reflection)
    ↓
getprop/setprop (Android System)
    ↓
Device System Properties
```

### Device Detection
The app reads real device info via system properties:
- `ro.product.device` → Device name
- `ro.chipname` → Chipset
- `ro.kernel.version` → Kernel version
- `ro.product.brand` → Brand
- `ro.product.model` → Model
- `ro.build.version.release` → Android version

Fallback to vendor custom properties:
- `ro.aiotool.hsr.device_name`
- `ro.aiotool.hsr.chipset`
- `ro.aiotool.hsr.kernel_ver`

## 🏗️ Project Structure

```
isertoolkit/
├── lib/
│   ├── main.dart                 # App entry
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── tweaks_screen.dart
│   │   ├── spoof_screen.dart
│   │   ├── perapp_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── banner_widget.dart
│   │   ├── profile_selector.dart
│   │   ├── toggle_card.dart
│   │   └── ...
│   ├── services/
│   │   ├── system_props.dart     # SystemProperties MethodChannel
│   │   ├── daemon_client.dart    # Daemon socket communication
│   │   └── ...
│   ├── utils/
│   │   ├── rom_detector.dart     # ROM detection
│   │   ├── device_detector.dart  # Device info reader
│   │   └── theme.dart
│   └── ...
├── android/
│   ├── app/
│   │   ├── src/main/kotlin/
│   │   │   ├── MainActivity.kt
│   │   │   ├── SystemPropsHelper.kt
│   │   │   ├── DaemonBridge.kt
│   │   │   └── LocalSocketClient.kt
│   │   └── build.gradle
│   └── settings.gradle
├── pubspec.yaml
├── build_release.ps1             # Helper build script
└── README.md
```

## 🔐 Permissions Required

### AndroidManifest.xml
```xml
<!-- System properties access -->
<uses-permission android:name="android.permission.READ_SETTINGS" />
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
```

## ⚙️ Build System Properties via Reflection

The app uses Java reflection to access `android.os.SystemProperties` (hidden API):

```kotlin
// In SystemPropsHelper.kt
private val systemPropertiesClass = Class.forName("android.os.SystemProperties")
systemPropertiesClass?.getMethod("get", String::class.java, String::class.java)
    ?.invoke(null, key, defaultVal)
```

## 📝 Important Notes

### Root Requirement
- **getprop (read)** - Works without root
- **setprop (write)** - **Requires root** OR vendor daemon with elevated privileges
- Daemon communication via `/dev/socket/hsr_daemon` needs vendor integration

### SELinux
- Must be Permissive or have proper policies
- Won't work with Enforcing SELinux without proper policies

### Vendor Integration
- For full functionality, integrate with your ROM's init system
- Daemon must run with root privileges
- SELinux policies must allow app → daemon communication

## 🛠️ Development

```bash
# Clean build
flutter clean
flutter pub get

# Run debug
flutter run

# Build release
flutter build apk --release
```

## 📦 Release APK

```powershell
.\build_release.ps1
```

## 📞 Support

- Check SELinux: `getenforce`
- Verify daemon: `ps aux | grep hsr_daemon`
- Check socket: `ls -l /dev/socket/hsr_daemon`
- View logs: `logcat | grep hsr`
