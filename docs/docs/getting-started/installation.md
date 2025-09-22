---
sidebar_position: 1
title: Installation
description: How to download and install QTick on your Android device
---

# Installation Guide 📥

Get QTick up and running on your Android device in just a few simple steps.

## 📋 Before You Begin

### System Requirements

<div className="qtick-badge">Android 7.0+</div>
<div className="qtick-badge">1GB RAM</div>
<div className="qtick-badge">15MB Storage</div>
<div className="qtick-badge">Camera Access</div>

### What You'll Need

- **Android device** running Android 7.0 (API level 24) or higher
- **Camera permission** for QR code scanning
- **15MB of available storage** for the app, extra storage needed to store attendance data
- **Internet connection** for initial download (app works offline after installation)

## 🚀 Download Options

### Option 1: Play Store

    See [Installation Steps](/asdev-qtick/docs/getting-started/installation#-installation-steps)

### Option 2: Build from Source

If you're a developer, you can build QTick from source:

```bash
# Clone the repository
git clone https://github.com/aadishsamir123/asdev-qtick.git
cd asdev-qtick

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

## 📱 Installation Steps

### Step 1: Join Google Group

Since QTick is currently in the closed testing stage, you'll need to join the Google Group first:

1. **Open the Google Group** with link: [groups.google.com/asdev-testers](https://groups.google.com/asdev-testers)
2. **Press Join Button**

### Step 2: Install from Play Store

1. **Open the Play Store Link:** [play.google.com/store/apps/details?id=com.aadishsamir.qr_attendance](https://play.google.com/store/apps/details?id=com.aadishsamir.qr_attendance)
2. **Install the app** from the Play Store
3. **Wait for installation** to complete

### Step 3: Grant Permissions

When you first launch QTick:

1. **Camera Permission**: Required for QR code scanning

   - Tap "Allow" when prompted
   - This is essential for the app to function

## ✅ Verify Installation

### First Launch Checklist

After installation, verify everything is working:

- [ ] **App launches successfully** without crashes
- [ ] **Camera permission granted** (check in app settings)
- [ ] **Camera preview works** in scanning screen
- [ ] **QR code detection** responds to test codes
- [ ] **Audio feedback** plays success/error sounds

### Test QR Code

Use this test QR code to verify scanning works:

<div className="qtick-code-block">

**Test Data**: `QTick-Test-User-001`

</div>

<div className="qtick-screenshot-placeholder">
[![Test QR Code](images/test-qr-code.png)](http://localhost:3001/asdev-qtick/docs/getting-started/installation#test-qr-code)
</div>

## 🔧 Troubleshooting Installation

### Common Issues

#### APK Won't Install

- **Check Android version**: Ensure you're running Android 7.0+
- **Check storage space**: Need at least 50MB free space
- **Disable Play Protect**: Temporarily disable if blocking installation
- **Try different file manager**: Some work better than others

#### App Crashes on Launch

- **Restart device** and try again
- **Clear device cache** in Android settings
- **Check available RAM** (need at least 1GB)
- **Update Android WebView** if available

#### Camera Not Working

- **Check permissions**: Settings > Apps > QTick > Permissions
- **Test other camera apps** to verify camera hardware
- **Restart QTick** after granting permissions
- **Check for camera hardware issues**

### Getting Help

If you're still having issues:

1. **Check our [Troubleshooting Guide](../advanced/troubleshooting)**
2. **Search [GitHub Issues](https://github.com/aadishsamir123/asdev-qtick/issues)**
3. **Create a new issue** with your device details
4. **Join the [Discussion](https://github.com/aadishsamir123/asdev-qtick/discussions)**

## 🔄 Updating QTick

### Manual Updates

QTick doesn't auto-update, so check for updates regularly:

1. **Visit the releases page** periodically
2. **Download the latest version** when available
3. **Install over the existing app** (data will be preserved)
4. **Check release notes** for new features

### In-App Update Notifications

QTick may show update notifications:

- **Follow the prompts** to download updates
- **Backup your data** before major updates
- **Read changelog** to understand changes

---

**🎉 Congratulations! QTick is now installed and ready to use.**

**Next:** [First Launch Setup →](./first-launch)
