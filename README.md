# 👗 Closet Mate

Closet Mate is a stylish and user-friendly **digital closet and outfit planner app** built with **Flutter**. It allows users to manage their wardrobe, add clothing items with details, and create outfits from saved clothes. Designed for fashion lovers and everyday users alike!

---

## ✨ Features

- 📸 **Add Items**  
  Upload clothing images from your gallery or camera and fill in details like category, color, brand, size, tags, and date of purchase.

- 🧥 **Organized Wardrobe**  
  View your clothes sorted by category (Tops, Bottoms, Footwear, Accessories).

- 👗 **Outfit Builder**  
  Mix and match items to create your own outfits with visual previews.

- 🔐 **Firebase Authentication**  
  Secure login and signup with Firebase Auth.

- ☁️ **Firebase for Profiles**  
  Profile data is synced and stored using Firestore.

- 💾 **SQLite for Wardrobe**  
  All items and outfits are stored locally using SQLite for offline access.

---

## 🛠 Tech Stack

| Layer         | Technology               |
|---------------|--------------------------|
| Frontend      | Flutter (Dart)           |
| Auth & Cloud  | Firebase Authentication, Firestore |
| Local Storage | SQLite (`sqflite`)       |
| Image Picker  | `image_picker` plugin    |

---

## 📸 Screenshots

> _Add your screenshots here_  
> _Example: Home page, Add Item form, Outfit preview_

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or newer)
- Dart
- Android Studio / VS Code
- Firebase project set up

### Installation

```bash
git clone https://github.com/your-username/closet_mate.git
cd closet_mate
flutter pub get
flutter run
