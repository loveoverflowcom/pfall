# 🌊 pfall

`pfall` is a simple Dart CLI tool that runs `flutter pub get` (or `dart pub get`) in **all subdirectories** that contain a `pubspec.yaml`.

It saves you from having to run the command manually in every package of a monorepo or workspace.

---

## 🔧 Installation

Activate globally from [pub.dev](https://pub.dev):

```bash
dart pub global activate pfall
```

🚀 Usage
Run pfall inside the root of your monorepo/workspace:
```bash
pfall
```
