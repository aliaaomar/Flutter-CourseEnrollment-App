# Student Course Enrollment App

A cross-platform Flutter application integrated with Firebase that allows students to manage authentication, maintain a user profile, browse available courses, and enroll seamlessly.

---

## Features

* **User Authentication:** Secure user registration and login handled via Firebase Authentication.
* **Profile Management:** Stores and syncs student profile data within the Cloud Firestore `users` collection.
* **Course Catalog:** Displays an interactive list of available courses fetched from Firestore.
* **Course Enrollment:** Enables authenticated students to enroll in courses with real-time updates.

---

## Tech Stack

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Cloud Firestore)
* **Platforms Supported:** Android, iOS, Web, Windows, macOS, Linux

---

## Project Structure

```text
├── android/               # Android native configurations
├── ios/                   # iOS native configurations
├── lib/                   # Flutter source code & UI logic
├── test/                  # Unit and widget tests
├── web/                   # Web platform setup
├── windows/               # Windows desktop support
├── macos/                 # macOS desktop support
├── linux/                 # Linux desktop support
├── pubspec.yaml           # Dependencies and asset management
└── analysis_options.yaml  # Linting and analysis rules

```

---

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
* [Firebase CLI](https://firebase.google.com/docs/cli)
* An active Firebase project

### Installation & Setup

1. **Clone the repository:**
```bash
git clone [https://github.com/aliaaomar/Flutter-CourseEnrollment-App.git](https://github.com/aliaaomar/Flutter-CourseEnrollment-App.git)
cd Flutter-CourseEnrollment-App

```


2. **Install dependencies:**
```bash
flutter pub get

```


3. **Configure Firebase:**
* Configure FlutterFire via CLI:
```bash
flutterfire configure

```


* Alternatively, add your platform-specific configuration files manually:
* `google-services.json` in `android/app/`
* `GoogleService-Info.plist` in `ios/Runner/`




4. **Run the application:**
```bash
flutter run

```



---

## Database Architecture

* **`users` (Collection):** Stores student metadata (`uid`, `name`, `email`, `enrolledCourses`).
* **`courses` (Collection):** Contains course catalog items (`courseId`, `title`, `description`, `instructor`).

```

```
