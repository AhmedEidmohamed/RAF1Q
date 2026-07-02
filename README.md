# 🚀 Rafiq (رفيق) - Therapeutic Educational Companion App
> **A specialized educational and therapeutic companion app built with Flutter for children with social and communication difficulties.**
> **تطبيق تعليمي وعلاجي مساعد للأطفال ذوي الصعوبات الاجتماعية والتواصلية مبني باستخدام Flutter.**
## 📱 Splash Screen (RAFIQ)

The Splash Screen is the user's first interaction with the **RAFIQ** application. It features a clean, minimalist white background centered around the vibrant and playful brand identity.

### Key Visual Elements:
- **Playful Typography:** Bright, multi-colored lettering for the word "RAFIQ".
- **Friendly Mascot:** An animated kid character waving from behind the letter 'R' to create an inviting atmosphere.
- **Engaging Icons:** Features a paper airplane, star elements, and a heart-shaped puzzle piece symbolizing connection, growth, and joy.

### Technical Implementation Idea:
- Built using a clean `Scaffold` with a centered brand asset.
- Utilizes a brief delay (e.g., 3 seconds) using `Future.delayed` before smoothly navigating to the next screen (Onboarding or Authentication).
- 
<img width="720" height="1600" alt="WhatsApp Image 2026-06-25 at 3 34 24 AM" src="https://github.com/user-attachments/assets/4235cd00-5dcf-4eb4-b52c-749c5a04917c" />



## 🔐 Login Screen (RAFIQ)

The Login Screen provides a secure and user-friendly interface for authentication, keeping up with the playful yet modern tech theme of the **RAFIQ** app.

### Key Features & UI Components:
- **Header Illustration:** A circular graphic showing a kid shaking hands with an AI robot, visualizing the tagline: *"Your smart assistant for learning and development"*.
- **Form Card:** A clean, rounded card containing:
  - **Phone Number Field:** Includes a phone icon placeholder.
  - **Password Field:** Features a secure toggle (visibility eye icon) and a lock icon.
  - **Primary Action Button:** A prominent blue button for traditional "Login".
- **Alternative Authentication:** - A quick-access "Sign in with Google" button fixed at the bottom.
  - A navigation link reading "Don't have an account? Create a smart account" to redirect users to the registration screen.
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/92d4bfd9-1074-4da9-a835-fcc72b39c11b" />

## 🏠 Home Screen / Dashboard (RAFIQ)

The Home Screen acts as the main interactive dashboard for the child, displaying personalized greetings, current learning stages, and accessible activities.

### Key Features & UI Components:
- **Custom Header Bar:** Features a curved blue gradient layout, a navigation drawer icon `☰`, and a personalized welcome message (*"Welcome ahmed"* accompanied by the mascot).
- **Stage Progress Card:** - Displays the current stage title: *"Stage 1: Introduction"*.
  - Includes a playful visual banner showing children interacting with learning materials.
  - Features an overall progress tracker currently showing `3%` completion.
- **Activities List:** Clean, rounded list items for selecting learning topics (e.g., *"Identifying People"*, *"Identifying Places"*).
- **Interactive Navigation & AI Assistant:**
  - **Floating Action Button (FAB):** A dedicated shortcut featuring the AI robot icon for quick guidance or voice assistant interaction.
  - **Modern Bottom Navigation Bar:** An ergonomic bottom bar highlighting the active "Home" (الرئيسية) tab alongside alternative navigation icons (Messages, Goals, Profile).



<img width="720" height="1600" alt="WhatsApp Image 2026-05-21 at 3 10 09 PM" src="https://github.com/user-attachments/assets/c30977f5-2140-4a00-a8b9-f64e140b5e24" />

## 🎯 Interaction & Daily Training Screen (RAFIQ)

This screen focuses on the core daily educational tasks and interactive modules designed to develop the child's social and emotional skills.

### Key Features & UI Components:
- **Daily Training Banner:** A prominent blue card with a lightbulb icon highlighting the day's core focus: *"Understanding Emotions and Feelings"*.
- **Interactive Lesson Card (Scrollable List):** - Dynamic visual header tailored to the topic.
  - **Topic Title:** *"Social Cues"*.
  - **Short Description:** Explains the lesson's goal (*"The child learns to understand cues such as gestures and body language in a fun way"*).
  - **Call to Action (CTA):** A solid blue *"Start Now"* (ابدأ الآن) button to initiate the lesson.
- **Bottom Navigation Status:** Shows the navigation bar with the second tab **"Interaction"** (التفاعل) currently selected and highlighted.
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/59d31247-5b27-4b57-920c-900dcb73fe7b" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/d015e685-94b4-4ce2-a0ca-b2b4a4ddd231" />


<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/4f339a0a-8a87-40b4-800c-b593650bcf5c" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/83d4c10c-eb8a-4fde-8342-7495cf2e3817" />


---

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![TensorFlow Lite](https://img.shields.io/badge/Tensorflow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://tensorflow.org/lite)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

---

## 🌟 Overview / نظرة عامة

**Rafiq (رفيق)** is a mobile application designed to assist children with communication and social challenges (such as autism spectrum conditions or speech delays) in learning and navigating their daily lives. The application blends interactive educational stages, AI-powered recognition, and speech technologies into a child-friendly, engaging, and premium interface.

**رفيق (Rafiq)** هو تطبيق للهاتف المحمول مصمم لمساعدة الأطفال الذين يواجهون تحديات تواصلية واجتماعية (مثل اضطرابات طيف التوحد أو تأخر النطق) على التعلم والتفاعل مع بيئتهم. يجمع التطبيق بين المراحل التعليمية التفاعلية، التعرف المدعوم بالذكاء الاصطناعي، وتقنيات تحويل الكلام، في واجهة وتصميم متميز يناسب احتياجات الطفل.

---

## ✨ Key Features / الميزات الرئيسية

### 1. 🤖 AI-Powered Object & Facial Recognition
* **TensorFlow Lite Integration:** Utilizes local machine learning models for real-time object and facial recognition.
* **Interactive Educational Stages:** Stage-based tasks to help children recognize daily objects, emotions, and environmental cues.
* **التعرف بالذكاء الاصطناعي (TFLite):** استخدام نماذج التعلم الآلي المحلية للتعرف على الأشياء وتعبيرات الوجه مباشرة على الهاتف.

### 2. 🗣️ Smart Speech Assistance (STT & TTS)
* **Speech-to-Text (STT):** Allows children to practice pronunciation and express themselves through interactive speech features.
* **Text-to-Speech (TTS):** Vocalizes items, categories, and instructions in clear, supportive Arabic and English.
* **المساعد الصوتي التفاعلي:** تحويل النطق والكلام إلى نصوص لتسهيل التواصل والتعلم اللغوي.

### 3. 🎨 Child-Friendly Interactive UI
* **Micro-animations & Audio Feedback:** Outfitted with Lottie animations, celebratory confetti, and satisfying sound effects.
* **Tailored Themes:** High-contrast, premium color schemes designed to reduce sensory overload and enhance focus.
* **واجهة تفاعلية جذابة:** حركات ورسومات تفاعلية (Lottie) وتأثيرات صوتية مصممة خصيصاً لجذب انتباه الطفل.

### 4. 🔗 Hybrid REST API & Firebase Architecture
* **Unified Data Service:** Smooth integration with local Node.js backends via custom API services, with Firebase authentication, firestore and storage options.
* **امن البيانات:** حماية معلومات الأطفال ونتائج تقدمهم وتوفير مزامنة سحابية.

### 5. ⏰ Therapeutic Reminders & Notifications
* **Daily Routines:** Keeps children engaged with structured learning paths, notifications, and reminders.
* **الإشعارات الذكية:** تنبيهات يومية وتذكير مستمر لمساعدة الطفل على إكمال مهامه التعليمية بشكل منتظم.

---

## 🛠️ Technology Stack / التقنيات المستخدمة

* **Frontend:** Flutter & Dart
* **State Management:** Provider & GetIt (Service Locator)
* **Machine Learning:** TensorFlow Lite (`tflite_flutter`)
* **Database & Auth:** Firebase Core, Auth, Cloud Firestore, Storage
* **AI APIs:** Google Generative AI (Gemini SDK integration)
* **Media & Sound:** Audio Players, Video Player, Chewie, Camera, Image Picker
* **Voice Services:** Speech to Text, Flutter TTS, Record MP3

---

## 📁 Project Structure / هيكل المشروع

```text
lib/
├── main.dart                 # Application entry point
├── services/                 # Firebase, API, TTS/STT, and database services
├── screens/                  # Application screens (educational stages, dashboard)
├── models/                   # Data transfer models
├── providers/                # App state and progress providers
└── theme/                    # Color configurations and custom styling system
```

---

## 🚀 Quick Start / دليل التشغيل السريع

### Prerequisites
* Flutter SDK (>=3.0.0 <4.0.0)
* Android Studio / Xcode (for emulation/testing)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/AhmedEidmohamed/RAF1Q.git
   cd RAF1Q
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure environment:**
   * Create a `.env` file in the root directory.
   * Add your backend API URL and key settings:
     ```env
     API_URL=http://your-local-api:5000/api
     ```
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📄 License / الترخيص
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
هذا المشروع مرخص بموجب رخصة MIT.
