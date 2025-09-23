import 'dart:io' show Directory, File, stdout, Process, stderr;

Future<void> runGetAll(List<String> args) async {
  for (final dir in _walkPubspecDirs()) {
    if (!_isLockUpToDate(dir)) {
      stdout.writeln('Running flutter pub get in ${dir.path}');
      final result = await Process.run(
        'dart',
        ['pub', 'get'],
        workingDirectory: dir.path,
      );
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    } else {
      stdout.writeln('pubspec.lock is up to date in ${dir.path}, skipping.');
    }
  }
}

Future<void> runCleanAll(List<String> args) async {
  for (final dir in _walkPubspecDirs()) {
    stdout.writeln('Cleaning in ${dir.path}');

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


bool _isLockUpToDate(Directory dir) {
  final pubspec = File('${dir.path}/pubspec.yaml');
  final lock = File('${dir.path}/pubspec.lock');

  if (!lock.existsSync()) return false;

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
