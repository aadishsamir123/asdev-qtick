# QTick - Smart QR Attendance Tracking 📱

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/aadishsamir123/asdev-qtick)
[![Flutter](https://img.shields.io/badge/Flutter-3.35.3+-02569B.svg?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://play.google.com/store)

QTick is a modern, intuitive QR code-based attendance tracking application built with Flutter. Designed for educational institutions, workplaces, and events, QTick provides a seamless way to track attendance with QR code scanning technology.

## ✨ Features

### 🎯 Core Functionality

- **QR Code Scanning**: Fast and accurate QR code detection using the device's camera
- **Dual Mode Tracking**: Support for both arrival and departure attendance
- **Real-time Processing**: Instant attendance recording with immediate feedback
- **Offline Only**: Works without internet connection. Currently no online features exist in the app.

### 🎨 User Experience

- **Modern UI Design**: Clean, intuitive interface with smooth animations
- **Audio Feedback**: Success and error sounds for better user interaction
- **Visual Feedback**: Lottie animations for enhanced user experience
- **Responsive Design**: Optimized for both phones and tablets

### 📊 Data Management

- **Local Database**: SQLite database for reliable data storage
- **Export Functionality**: Export attendance data to CSV format
- **Admin Panel**: Comprehensive view and management of attendance records

### ⚙️ Advanced Features

- **Customizable Settings**: Personalize app behavior and preferences
- **Battery Monitoring**: Built-in battery status indicator
- **Update System**: In-app update notifications and management
- **Permission Handling**: Camera permission management
- **Debug Tools**: Advanced debugging and troubleshooting options(only in debug mode)

## 🚀 Getting Started

### System Requirements

- **Android**: 7.0 (API level 24) or higher
- **RAM**: Minimum 1GB recommended
- **Storage**: App size around 5-15MB depending on device. Data may take another 10-15MB.
- **Camera**: Currently only front camera. Other camera/rear camera may work if there is no front camera.
- **Permissions**: Camera access required for QR scanning

### Installation

#### Option 1: Play Store (Recommended)

The app is currently in **closed testing** on Google Play Store. See the [Join Closed Testing](#-join-closed-testing) section below for instructions.

#### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/aadishsamir123/asdev-qtick.git
cd qr_attendance

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🧪 Join Closed Testing

QTick is currently available through Google Play Store's **Internal Testing Program**. Follow these steps to join:

### Step 1: Get Access

**Join the Google Group**: Go to [groups.google.com/asdev-testers](https://groups.google.com/asdev-testers) and join the group.

### Step 2: Download the App

**Download from Play Store**:

- Open the link: [play.google.com/store/apps/details?id=com.aadishsamir.qr_attendance](https://play.google.com/store/apps/details?id=com.aadishsamir.qr_attendance)
- Install the app (it will show as "Early Access")

### Step 3: Provide Feedback

- **Bug Reports**: Use the in-app feedback system or email
- **Feature Requests**: Share your suggestions for improvements
- **Performance Issues**: Report any crashes or slow performance

Feedback can be provided via [GitHub Issues](https://github.com/aadishsamir123/asdev-qtick/issues)

### Testing Guidelines

- ✅ Test core QR scanning functionality
- ✅ Try both arrival and departure modes
- ✅ Test export/delete functionality
- ✅ Verify data persistence across app restarts
- ✅ Check admin panel features
- ❗ Report any crashes immediately
- ❗ Note any UI/UX inconsistencies

## 📋 How to Use

### Basic Usage

1. **Launch the App**: Open QTick from your app drawer
2. **Choose Mode**: Select "Arrival" or "Departure"
3. **Scan QR Code**: Point camera at the QR code
4. **Confirm**: Wait for audio/visual confirmation
5. **View Records**: Access admin panel to view all records

### Admin Functions

- **View All Records**: See complete attendance history
- **Export Data**: Generate CSV reports
- **Delete Records**: Remove individual entries
- **Manage Settings**: Customize app behavior

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - Cross-platform UI framework
- **[SQLite](https://www.sqlite.org/)** - Local database storage
- **[Mobile Scanner](https://pub.dev/packages/mobile_scanner)** - QR code scanning
- **[Lottie](https://pub.dev/packages/lottie)** - Smooth animations
- **[Provider](https://pub.dev/packages/provider)** - State management
- **[AudioPlayers](https://pub.dev/packages/audioplayers)** - Audio feedback

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Email**: [asdev.feedback@gmail.com](mailto:asdev.feedback@gmail.com)
- **Issues**: [GitHub Issues](https://github.com/aadishsamir123/asdev-qtick/issues)

## 🎉 Acknowledgments

- Contributors and beta testers
- Open source community for the packages used

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/aadishsamir123">Aadish Samir</a></p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
