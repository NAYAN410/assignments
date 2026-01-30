# Assignment Auth & Profile 🚀

A modern, high-performance Flutter application featuring seamless Firebase Authentication (Google & Email) and a dynamic User Profile system.

## ✨ Key Features

*   **Premium UI/UX**: Clean, attractive interface with smooth gradients and interactive elements.
*   **Dual Authentication**:
    *   **Google Sign-In**: Quick, one-tap authentication.
    *   **Manual Signup/Login**: Comprehensive registration flow with full validation.
*   **Interactive Swipe Button**: "Swipe to Confirm" action for a unique and secure user experience.
*   **Firebase Integration**:
    *   **Auth**: Secure user management.
    *   **Realtime Database**: Instant data sync and persistence of user metadata (DOB, Gender, Socials).
*   **Smart Validation**: Inline error messaging and age verification (13+ years).
*   **Detailed Profile**: Elegant user profile page displaying all captured metadata.

---

## 📲 Download the App

[![Android Download](https://img.shields.io/badge/Download-Android%20APK-green?style=for-the-badge&logo=android)](https://github.com/shiva/assignments/releases/download/v1.0.0/app-release.apk)
[![iOS Download](https://img.shields.io/badge/Download-iOS%20IPA-blue?style=for-the-badge&logo=apple)](https://github.com/shiva/assignments/releases/download/v1.0.0/FlutterIpaExport.ipa)

---

## 📸 Screenshots

| Welcome Screen | Manual Signup | User Profile |
| :---: | :---: | :---: |
| ![Welcome](lib/ss/welcome.png) | ![Signup](lib/ss/signup.png) | ![Profile](lib/ss/profile.png) |

---

## 🛠️ Built With

*   [Flutter](https://flutter.dev/) - Framework
*   [Firebase](https://firebase.google.com/) - Backend (Auth & Database)
*   [Google Sign-In](https://pub.dev/packages/google_sign_in) - Social Auth
*   [Swipeable Button View](https://pub.dev/packages/swipeable_button_view) - Interactive UI

---

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK: `^3.10.7`
*   Dart SDK: `^3.10.7`

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/shiva/assignments.git
    cd assignments
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    *   Place your `google-services.json` in `android/app/`.
    *   Place your `GoogleService-Info.plist` in `ios/Runner/`.

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
