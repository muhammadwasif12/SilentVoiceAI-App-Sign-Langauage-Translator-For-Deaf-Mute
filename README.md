# 🤟 SilentVoice AI - Hand Gesture Translator for Deaf & Mute

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![TensorFlow](https://img.shields.io/badge/TensorFlow-Lite-FF6F00?logo=tensorflow)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)

> **Empowering the deaf-and-mute community through AI-powered real-time hand gesture recognition**

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 🎯 About the Project

**SilentVoice AI** is an AI-powered mobile application designed to break communication barriers for the deaf-and-mute community. Using advanced machine learning and computer vision, the app translates **American Sign Language (ASL)** hand gestures into real-time text and speech output.

### 🌟 Highlights

- ✅ **92%+ Accuracy** on real-time gesture detection
- ✅ **Fully Offline** - No internet required, ensuring privacy and instant response
- ✅ **26 Alphabets + Space + Delete** gesture recognition
- ✅ **Text-to-Speech** for audible output
- ✅ **Flutter + TensorFlow Lite** for cross-platform deployment
- ✅ **MVVM Clean Architecture** for scalable, maintainable code

This project was developed as an **AI Semester Capstone Project** at COMSATS University Islamabad.

---

## ✨ Key Features

| # | Feature | Description |
|---|---------|-------------|
| 1️⃣ | **Real-time Gesture Detection** | Live camera feed powered by TFLite CNN model for instant recognition |
| 2️⃣ | **Text-to-Speech Output** | Converts detected gestures into spoken words using native TTS |
| 3️⃣ | **Translation History** | SQLite-backed history log with export/share capabilities |
| 4️⃣ | **Customizable Settings** | Adjust confidence threshold, sound effects, vibration feedback |
| 5️⃣ | **Dark Mode UI** | Modern glassmorphism design with smooth animations |
| 6️⃣ | **Multi-language Support** | English & Urdu localization |
| 7️⃣ | **Secure Storage** | `flutter_secure_storage` for encrypted user preferences |
| 8️⃣ | **Export & Share** | Copy, save, or share translations via WhatsApp, Email, etc. |

---

## 🛠️ Tech Stack

### **Frontend**
- **Flutter 3.x** - Cross-platform UI framework
- **Dart 2.19+** - Programming language
- **Provider + Riverpod** - State management (MVVM pattern)
- **Google Fonts** - Typography
- **Animations** - Smooth micro-interactions

### **AI/ML**
- **TensorFlow Lite** - On-device inference engine
- **tflite_flutter** - TFLite plugin for Flutter
- **Google ML Kit** - Hand detection & landmark extraction
- **Custom CNN Model** - Trained on ASL dataset (96% training accuracy)

### **Local Storage**
- **sqflite** - SQLite for translation history
- **flutter_secure_storage** - Encrypted key-value storage
- **shared_preferences** - App settings

### **Testing**
- **flutter_test** - Unit & widget testing
- **mockito** - Mocking framework (85% code coverage)

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: `>=3.0.0 <4.0.0`
- **Dart SDK**: `>=2.19.0 <4.0.0`
- **Android Studio** / **Xcode** (for emulators)
- **Git**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/muhammadwasif12/SilentVoiceAI-App-Sign-Langauage-Translator-For-Deaf-Mute.git
   cd SilentVoiceAI-App-Sign-Langauage-Translator-For-Deaf-Mute
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (requires macOS & Xcode)
   flutter run -d ios
   ```

4. **Build APK** (Android)
   ```bash
   flutter build apk --split-per-abi
   ```

   Generated APKs:
   - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
   - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit)
   - `build/app/outputs/flutter-apk/app-x86_64-release.apk` (Emulator)

---

## 📁 Project Structure

```
lib/
├── core/                     # Shared utilities & constants
│   ├── routing/              # App navigation (GoRouter)
│   ├── providers/            # Shared Riverpod providers
│   ├── themes/               # App themes & colors
│   └── utils/                # Helper functions
├── features/                 # Feature modules (MVVM Clean Architecture)
│   ├── gesture_detection/    # Real-time gesture recognition
│   │   ├── data/             # Models, repositories
│   │   ├── domain/           # Business logic
│   │   └── presentation/     # UI screens & providers
│   ├── history/              # Translation history
│   ├── settings/             # App settings
│   └── auth/                 # User authentication (optional)
├── assets/                   # Images, fonts, models
│   ├── models/               
│   │   ├── gesture_model.tflite
│   │   └── gesture_labels.json
│   └── images/               # Hand sign reference images
└── main.dart                 # App entry point
```

For detailed architecture, see [PROJECT_STRUCTURE_GUIDE.md](PROJECT_STRUCTURE_GUIDE.md)

---

## 📸 Screenshots

> **Note:** Add your app screenshots here after uploading to an image hosting service or `/assets/screenshots/` folder

| Home Screen | Gesture Detection | History |
|-------------|-------------------|---------|
| ![Home](assets/screenshots/home.png) | ![Detection](assets/screenshots/detection.png) | ![History](assets/screenshots/history.png) |

---

## 🏗️ Architecture

This project follows **MVVM (Model-View-ViewModel) Clean Architecture** principles:

- **Presentation Layer**: Flutter widgets, screens, and providers
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Models, repositories, and data sources (SQLite, TFLite)

**State Management**: Provider + Riverpod for reactive UI updates

For complete workflow, see [TECHNICAL_WORKFLOW.md](TECHNICAL_WORKFLOW.md)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. Create a **feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. Open a **Pull Request**

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` file for details.

---

## 👤 Contact

**Muhammad Wasif**  
- 📧 Email: [your-email@example.com](mailto:your-email@example.com)  
- 💼 LinkedIn: [linkedin.com/in/your-profile](https://linkedin.com/in/your-profile)  
- 🐙 GitHub: [@muhammadwasif12](https://github.com/muhammadwasif12)

**Project Link**: [https://github.com/muhammadwasif12/SilentVoiceAI-App-Sign-Langauage-Translator-For-Deaf-Mute](https://github.com/muhammadwasif12/SilentVoiceAI-App-Sign-Langauage-Translator-For-Deaf-Mute)

---

## 🙏 Acknowledgments

- **Mentor**: Prof. [Name] - AI model guidance
- **Dataset**: ASL hand signs dataset
- **Flutter Community**: For amazing packages and support
- **TensorFlow Team**: For TFLite framework

---

<div align="center">

**⭐ If you found this project helpful, please consider giving it a star!**

Made with ❤️ by Muhammad Wasif

</div>
