# Vendor Integration Guide - IserToolkit

Complete step-by-step guide for integrating IserToolkit into your Android ROM as a vendor addon.

## 📋 Prerequisites

- AOSP/LineageOS source tree
- Kernel source matching your device
- SELinux policy editor experience
- Device tree repository

## 🏗️ Directory Structure Setup

Create this structure in your device tree:

```
device/vendor/hsr_toolkit/
├── hsr_daemon/
│   ├── hsr_daemon.cpp         (Your native daemon implementation)
│   ├── Android.mk
│   └── ...
├── init/
│   ├── hsr_daemon.rc
│   ├── hsr_props.rc
│   └── Android.mk
├── sepolicy/
│   ├── hsr_daemon.te
│   ├── file_contexts
│   └── Android.mk
├── app/
│   └── (IserToolkit Flutter APK)
└── Android.mk
```

## 🔧 Implementation Steps

### Step 1: Create Init Scripts

#### `device/vendor/hsr_toolkit/init/hsr_daemon.rc`

```ini
# HSR Daemon Service Definition
service hsr_daemon /system/bin/hsr_daemon
    class main
    user root
    group root system radio
    seclabel u:r:hsr_daemon:s0
    socket hsr_daemon stream 0660 root system
    
    # These properties control daemon state
    # Set to 1 to enable at boot, 0 to keep disabled initially
    disabled

# Start daemon when boot is completed
on property:sys.boot_completed=1
    start hsr_daemon

# Allow enable/disable via property
on property:persist.sys.hsr.daemon.enable=1
    start hsr_daemon

on property:persist.sys.hsr.daemon.enable=0
    stop hsr_daemon
```

#### `device/vendor/hsr_toolkit/init/hsr_props.rc`

```ini
# HSR System Properties Initialization
on boot
    # Device name (usually ro.product.device)
    setprop ro.aiotool.hsr.device_name "unknown"
    setprop ro.aiotool.hsr.chipset "unknown"
    setprop ro.aiotool.hsr.kernel_ver "unknown"

on property:sys.boot_completed=1
    # Read from actual device properties
    setprop ro.aiotool.hsr.device_name "${ro.product.device}"
    setprop ro.aiotool.hsr.chipset "${ro.chipname}"
    setprop ro.aiotool.hsr.kernel_ver "${ro.kernel.version}"
    
    # ROM Info
    setprop ro.aiotool.hsr.rom_name "your_rom"
    setprop ro.aiotool.hsr.android_ver 14
    setprop ro.aiotool.hsr.os_version 1
```

### Step 2: SELinux Policy Setup

#### `device/vendor/hsr_toolkit/sepolicy/hsr_daemon.te`

```te
################
# HSR Daemon Policies
################

# Define HSR daemon domain and executable type
type hsr_daemon, domain;
type hsr_daemon_exec, exec_type, vendor_file_type, file_type;

# Initialize daemon domain from init
init_daemon_domain(hsr_daemon)

#################
# System Properties
#################

# Allow daemon to read/write system properties
allow hsr_daemon self:capability { dac_override setgid setuid sys_admin };
allow hsr_daemon self:capability2 { block_suspend wake_alarm };

# Property socket access
allow hsr_daemon property_socket:sock_file w_file_perms;
allow hsr_daemon init:unix_stream_socket connectto;
allow hsr_daemon property_enum_service:service_manager find;

#################
# Socket Communication
#################

# Create and listen on Unix socket
allow hsr_daemon self:unix_stream_socket {
    create_stream_socket_perms
    listen
    accept
};

# Allow app to connect to daemon socket
type system_app; # Or your app domain
allow system_app hsr_daemon:unix_stream_socket connectto;
allow system_app hsr_daemon_exec:file { read open getattr };

# Socket file permissions
allow hsr_daemon self:unix_stream_socket { 
    bind 
    listen 
    accept 
    connect 
    read 
    write 
    getattr 
};

#################
# Sysfs Access (Performance/Thermal Control)
#################

# CPU frequency scaling
allow hsr_daemon sysfs_cpufreq:dir rw_dir_perms;
allow hsr_daemon sysfs_cpufreq:file rw_file_perms;

# GPU frequency
allow hsr_daemon sysfs_gpufreq:dir rw_dir_perms;
allow hsr_daemon sysfs_gpufreq:file rw_file_perms;

# Thermal management
allow hsr_daemon sysfs_thermal:dir rw_dir_perms;
allow hsr_daemon sysfs_thermal:file rw_file_perms;

# Battery and power stats
allow hsr_daemon sysfs_power:file rw_file_perms;

# Device tree
allow hsr_daemon sysfs_devicetree:dir r_dir_perms;
allow hsr_daemon sysfs_devicetree:file r_file_perms;

#################
# ProcFS Access
#################

# Read CPU stats
allow hsr_daemon proc_stat:file r_file_perms;

# Read memory info
allow hsr_daemon proc_meminfo:file r_file_perms;

#################
# /sys/class Access
#################

allow hsr_daemon sysfs_class_thermal:dir rw_dir_perms;
allow hsr_daemon sysfs_class_thermal:file rw_file_perms;

#################
# File System
#################

# Access /dev
allow hsr_daemon device:dir r_dir_perms;

# Create socket in /dev/socket
allow hsr_daemon socket_device:dir rw_dir_perms;
allow hsr_daemon socket_device:sock_file rw_file_perms;

# Access vendor files
allow hsr_daemon vendor_file:dir r_dir_perms;
allow hsr_daemon vendor_file:file r_file_perms;
```

#### `device/vendor/hsr_toolkit/sepolicy/file_contexts`

```te
# HSR Daemon executable
/system/bin/hsr_daemon              u:object_r:hsr_daemon_exec:s0

# HSR daemon socket
/dev/socket/hsr_daemon              u:object_r:hsr_daemon:s0

# Init scripts
/vendor/etc/init/hsr_daemon\.rc     u:object_r:vendor_file:s0
/vendor/etc/init/hsr_props\.rc      u:object_r:vendor_file:s0
```

#### `device/vendor/hsr_toolkit/sepolicy/hwservice_contexts` (if using HIDL)

```te
com.hsr.toolkit::IHSRToolkit       u:object_r:hsr_daemon:s0
```

### Step 3: Build Configuration

#### `device/vendor/hsr_toolkit/Android.mk`

```makefile
LOCAL_PATH := $(call my-dir)

# Build hsr_daemon binary
include $(CLEAR_VARS)
LOCAL_MODULE := hsr_daemon
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/bin
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_INIT_RC := init/hsr_daemon.rc init/hsr_props.rc
LOCAL_SRC_FILES := hsr_daemon/hsr_daemon.cpp
LOCAL_C_INCLUDES := \
    system/core/include \
    external/libcxx/include
LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    liblog
LOCAL_CFLAGS := \
    -Wall \
    -Wextra \
    -Werror \
    -Os
include $(BUILD_EXECUTABLE)

# SELinux Policy
include $(CLEAR_VARS)
LOCAL_MODULE := hsr_daemon
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/etc/selinux/precompiled_sepolicy.d
LOCAL_SRC_FILES := sepolicy/hsr_daemon.te
include $(BUILD_PREBUILT)
```

### Step 4: Device Tree Integration

#### In your device's main `Android.mk`:

```makefile
# Include HSR Toolkit
PRODUCT_PACKAGES += \
    hsr_daemon

# Copy init scripts
PRODUCT_COPY_FILES += \
    device/vendor/hsr_toolkit/init/hsr_daemon.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hsr_daemon.rc \
    device/vendor/hsr_toolkit/init/hsr_props.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hsr_props.rc

# SELinux Policy
BOARD_VENDOR_SEPOLICY_DIRS += \
    device/vendor/hsr_toolkit/sepolicy
```

### Step 5: build.prop Configuration

#### In `device/vendor/build.prop`:

```properties
# HSR Toolkit Properties
ro.aiotool.hsr.enabled=1
ro.aiotool.hsr.daemon.socket=/dev/socket/hsr_daemon
ro.aiotool.hsr.rom_name=your_rom_name
ro.aiotool.hsr.android_ver=14
ro.aiotool.hsr.os_version=1

# Device-specific (will be overridden at runtime)
ro.aiotool.hsr.device_name=cannon
ro.aiotool.hsr.chipset=MediaTek Helio G85
ro.aiotool.hsr.kernel_ver=5.15.104

# Spoof properties (example)
ro.aiotool.hsr.spoof.enabled=0
```

### Step 6: Install IserToolkit App

Option A: Pre-built APK

```makefile
# In your device Android.mk
PRODUCT_PACKAGES += IserToolkit

# Create directory structure
device/vendor/hsr_toolkit/app/Android.mk:

include $(CLEAR_VARS)
LOCAL_MODULE := IserToolkit
LOCAL_MODULE_CLASS := APPS
LOCAL_BUILT_MODULE_STEM := package.apk
LOCAL_CERTIFICATE := platform
LOCAL_SRC_FILES := isertoolkit-release.apk
include $(BUILD_PREBUILT)
```

Option B: Build from source (requires Flutter in build system - advanced)

## 🔨 Native Daemon Implementation Example

#### `hsr_daemon.cpp` (Minimal Example)

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <android/log.h>
#include <cutils/properties.h>

#define LOG_TAG "HSR_DAEMON"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

#define SOCKET_PATH "/dev/socket/hsr_daemon"
#define SOCKET_BACKLOG 4

static volatile int keep_running = 1;

void handle_signal(int sig) {
    if (sig == SIGTERM || sig == SIGINT) {
        keep_running = 0;
    }
}

void handle_client(int client_sock) {
    char buffer[256];
    ssize_t n = recv(client_sock, buffer, sizeof(buffer) - 1, 0);
    
    if (n > 0) {
        buffer[n] = '\0';
        LOGI("Received: %s", buffer);
        
        // Parse command:value format
        char *cmd = strtok(buffer, ":");
        char *value = strtok(NULL, ":");
        
        char response[256];
        
        if (cmd != NULL && strcmp(cmd, "SET_PROFILE") == 0) {
            // Handle profile setting
            LOGI("Setting profile: %s", value ? value : "default");
            sprintf(response, "OK:PROFILE_SET:%s", value);
        } else if (cmd != NULL && strcmp(cmd, "GET_THERMAL") == 0) {
            // Read thermal info from sysfs
            sprintf(response, "OK:THERMAL:38C");
        } else {
            sprintf(response, "ERROR:UNKNOWN_COMMAND");
        }
        
        send(client_sock, response, strlen(response), 0);
    }
    
    close(client_sock);
}

void *accept_connections(void *arg) {
    int server_sock = (intptr_t)arg;
    struct sockaddr_un addr;
    socklen_t addr_len = sizeof(addr);
    
    while (keep_running) {
        int client_sock = accept(server_sock, (struct sockaddr *)&addr, &addr_len);
        
        if (client_sock > 0) {
            pthread_t thread;
            pthread_create(&thread, NULL, (void* (*)(void*))handle_client, (void*)(intptr_t)client_sock);
            pthread_detach(thread);
        }
    }
    
    return NULL;
}

int main() {
    LOGI("HSR Daemon starting...");
    
    signal(SIGTERM, handle_signal);
    signal(SIGINT, handle_signal);
    
    // Create socket
    int server_sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (server_sock < 0) {
        LOGE("Failed to create socket");
        return 1;
    }
    
    // Remove old socket if exists
    unlink(SOCKET_PATH);
    
    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, SOCKET_PATH);
    
    // Bind socket
    if (bind(server_sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        LOGE("Failed to bind socket");
        close(server_sock);
        return 1;
    }
    
    // Set permissions
    chmod(SOCKET_PATH, 0660);
    
    // Listen
    if (listen(server_sock, SOCKET_BACKLOG) < 0) {
        LOGE("Failed to listen");
        close(server_sock);
        return 1;
    }
    
    LOGI("Listening on %s", SOCKET_PATH);
    
    pthread_t accept_thread;
    pthread_create(&accept_thread, NULL, accept_connections, (void*)(intptr_t)server_sock);
    
    // Main daemon loop
    while (keep_running) {
        sleep(1);
    }
    
    LOGI("HSR Daemon stopping...");
    close(server_sock);
    unlink(SOCKET_PATH);
    
    return 0;
}
```

## 📦 Building Your ROM

```bash
# Standard ROM build
. build/envsetup.sh
lunch your_device-user
m -j$(nproc)

# Verify daemon is included
grep -r "hsr_daemon" out/target/product/your_device/system.img

# Check SELinux policies
ls out/target/product/your_device/vendor/etc/selinux/
```

## ✅ Verification Checklist

After building and flashing:

```bash
# Check daemon is running
adb shell ps aux | grep hsr_daemon

# Check socket exists
adb shell ls -l /dev/socket/hsr_daemon

# Check init script ran
adb shell cat /proc/cmdline | grep hsr

# Check SELinux context
adb shell ls -lZ /system/bin/hsr_daemon
adb shell getenforce

# Check properties
adb shell getprop | grep hsr

# Test socket communication
adb shell echo "GET_THERMAL" | nc -U /dev/socket/hsr_daemon
```

## 🐛 Troubleshooting

### Daemon doesn't start
```bash
# Check init.rc syntax
adb shell dmesg | grep hsr

# Check permissions
adb shell ls -l /system/bin/hsr_daemon

# Check SELinux denials
adb shell dmesg | grep "avc: denied"
```

### SELinux Denials
```bash
# Temporarily permissive for testing
adb shell setenforce 0

# Check audit log
adb shell dmesg | grep "denied" | tail -20
```

### App can't connect to socket
```bash
# Verify socket permissions
adb shell stat /dev/socket/hsr_daemon

# Check app has read/write access
adb logcat | grep "isertoolkit"
```

## 📞 Support

- Check `adb logcat -s HSR_DAEMON` for daemon logs
- Review `adb dmesg | grep hsr` for kernel messages
- Enable SELinux audit mode: `adb shell setenforce 0`
