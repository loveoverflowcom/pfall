import 'dart:convert' show LineSplitter;
import 'dart:io' show Directory, File, stdout, Process, stderr, SystemEncoding;

Future<void> runGetAll(List<String> args) async {
  for (final dir in _walkPubspecDirs()) {
    if (!_needGet(dir)) {
      stdout.writeln('🚀 Running flutter pub get in ${dir.path}...');
      final result = await Process.run(
        'dart',
        ['pub', 'get'],
        workingDirectory: dir.path,
      );
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    } else {
      stdout.writeln('✅ pubspec.lock is up to date in ${dir.path}.');
    }
  }
}

Future<void> runCleanAll(List<String> args) async {
  for (final dir in _walkPubspecDirs()) {
    stdout.writeln('🚀 Cleaning in ${dir.path}...');

    final pubspecFile = File('${dir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      if (await _isFlutterProject(pubspecFile)) {
        final result = await Process.run(
          'flutter',
          ['clean'],
          workingDirectory: dir.path,
        );

        stdout.write(result.stdout);
        stderr.write(result.stderr);
      } else {
        final lockFile = File('${dir.path}/pubspec.lock');
        if (lockFile.existsSync()) {
          lockFile.deleteSync();
        }

        final dartToolDir = Directory('${dir.path}/.dart_tool');
        if (dartToolDir.existsSync()) {
          dartToolDir.deleteSync(recursive: true);
        }

        final buildDir = Directory('${dir.path}/build');
        if (buildDir.existsSync()) {
          buildDir.deleteSync(recursive: true);
        }
      }
    }
  }
}


bool _needGet(Directory dir) {
  final pubspec = File('${dir.path}/pubspec.yaml');
  final lock = File('${dir.path}/pubspec.lock');
  final packageConfig = File('${dir.path}/.dart_tool/package_config.json');

  if (!lock.existsSync()) return false;
  if (!packageConfig.existsSync()) return true;

  final pubspecModified = pubspec.lastModifiedSync();
  final lockModified = lock.lastModifiedSync();

  return lockModified.isAfter(pubspecModified);
}

Iterable<Directory> _walkPubspecDirs() sync* {
  final root = Directory.current;

  final pubspecFiles = root
      .listSync(recursive: true)
      .where((e) => e is File && e.path.endsWith('pubspec.yaml'))
      .cast<File>()
      .where((file) => !_shouldIgnore(file.parent.path));

  for (final pubspec in pubspecFiles) {
    yield pubspec.parent;
  }
}

final _ignoreDirs = [
  '/flutter/ephemeral',
  '/.symlinks',
  '/.plugin_symlinks',
];

bool _shouldIgnore(String dirPath) {
  dirPath = dirPath.replaceAll('\\', '/');
  return _ignoreDirs.any((pattern) => dirPath.contains(pattern));
}

Future<bool> _isFlutterProject(File pubspecFile) async {
  final stream = pubspecFile.openRead()
      .transform(SystemEncoding().decoder)
      .transform(const LineSplitter());

  await for (final line in stream) {
    if (line.trim().startsWith('flutter:')) {
      return true;
    }
  }
  return false;
}
