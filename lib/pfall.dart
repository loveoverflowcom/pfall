import 'dart:io' show Directory, File, stdout, Process, stderr;

Future<void> runPFall(List<String> args) async {
  final root = Directory.current;

  final pubspecFiles = root
      .listSync(recursive: true)
      .where((e) => e is File && e.path.endsWith('pubspec.yaml'))
      .cast<File>();

  for (final pubspec in pubspecFiles) {
    final dir = pubspec.parent;

    if (!_isLockUpToDate(dir)) {
      stdout.writeln('Running flutter pub get in ${dir.path}');
      final result = await Process.run(
        'flutter',
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

bool _isLockUpToDate(Directory dir) {
  final pubspec = File('${dir.path}/pubspec.yaml');
  final lock = File('${dir.path}/pubspec.lock');

  if (!lock.existsSync()) return false;

  final pubspecModified = pubspec.lastModifiedSync();
  final lockModified = lock.lastModifiedSync();

  return lockModified.isAfter(pubspecModified);
}
