import 'dart:io' show stdout, exit;

import 'package:args/args.dart' show ArgParser;
import 'package:pfall/pfall.dart' show runGetAll, runCleanAll;

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand('help')
    ..addCommand('clean')
    ..addCommand('get');

  parser.commands['get']!
    .addFlag(
      'force',
      abbr: 'f',
      negatable: false,
    );

  final argResults = parser.parse(args);

  if (argResults.command?.name == 'help') {
    stdout.writeln('Usage: pfall <command>\n');
    stdout.writeln('Available commands:');
    stdout.writeln(parser.commands.keys.join(', '));
    exit(0);
  }

  if (argResults.command?.name == 'clean') {
    await runCleanAll(args);
  }

  if (argResults.command?.name == 'get') {
    await runGetAll(args);
  }
}
