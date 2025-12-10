# 🌊 pfall

`pfall` is a simple Dart CLI tool that runs `flutter pub get` (or `dart pub get`) in **all subdirectories** that contain a `pubspec.yaml`.  
It can also **clean build artifacts** (`pubspec.lock`, `.dart_tool/`, `build/`) across all packages in your workspace.

It saves you from having to run the commands manually in every package of a monorepo.

---

## 🔧 Installation

Activate globally from [pub.dev](https://pub.dev):

```bash
dart pub global activate pfall
````

---

## 🚀 Usage

Run `pfall` inside the root of your monorepo/workspace.

### Show help

```bash
pfall help
```

### Run `flutter pub get` in all subdirectories

```bash
pfall get
```

### Force re-fetch Git dependencies

```bash
pfall get --force
# or
pfall get -f
```

### Clean `.dart_tool`, `build`, and `pubspec.lock` in all subdirectories

```bash
pfall clean
```

---

## ✨ Example

```bash
# Get all dependencies
pfall get

# Clean all packages
pfall clean

# Show usage information
pfall help
```
