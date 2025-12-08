import 'dart:io';
import 'package:args/args.dart';
import 'package:dart_diff_cli/merger.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'current-file',
      abbr: 'c',
      help: 'Path to the current file with user modifications (P1)',
      mandatory: true,
    )
    ..addOption(
      'generated-file',
      abbr: 'g',
      help: 'Path to the newly generated file (P2)',
      mandatory: true,
    )
    ..addOption(
      'output-file',
      abbr: 'o',
      help: 'Path to the output merged file (P3)',
      mandatory: true,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Display usage information',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    final currentFile = results['current-file'] as String;
    final generatedFile = results['generated-file'] as String;
    final outputFile = results['output-file'] as String;

    // Validate file existence
    if (!File(currentFile).existsSync()) {
      stderr.writeln('❌ Error: Current file does not exist: $currentFile');
      exit(1);
    }

    if (!File(generatedFile).existsSync()) {
      stderr.writeln('❌ Error: Generated file does not exist: $generatedFile');
      exit(1);
    }

    // Execute merge
    final stopwatch = Stopwatch()..start();
    
    stdout.writeln('🔍 Analyzing files...');
    stdout.writeln('  P1 (User Modified): $currentFile');
    stdout.writeln('  P2 (Generated): $generatedFile');
    stdout.writeln('  P3 (Output): $outputFile');
    stdout.writeln('');

    final merger = DartAstMerger();
    await merger.merge(
      currentFilePath: currentFile,
      generatedFilePath: generatedFile,
      outputFilePath: outputFile,
    );

    stopwatch.stop();
    
    stdout.writeln('');
    stdout.writeln('✅ Merge completed successfully!');
    stdout.writeln('⏱️  Time taken: ${stopwatch.elapsedMilliseconds}ms');
    stdout.writeln('📄 Output written to: $outputFile');
    
    exit(0);
  } on FormatException catch (e) {
    stderr.writeln('❌ Error parsing arguments: ${e.message}');
    stderr.writeln('');
    _printUsage(parser);
    exit(1);
  } on MergeException catch (e) {
    stderr.writeln('❌ Merge failed: ${e.message}');
    if (e.details != null) {
      stderr.writeln('   Details: ${e.details}');
    }
    exit(1);
  } catch (e, stackTrace) {
    stderr.writeln('❌ Unexpected error: $e');
    stderr.writeln(stackTrace);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln('🎯 Dart AST Smart Merge CLI');
  stdout.writeln('');
  stdout.writeln('A sophisticated tool for merging user modifications with generated Dart code.');
  stdout.writeln('');
  stdout.writeln('Usage: dart run bin/main.dart [options]');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(parser.usage);
  stdout.writeln('');
  stdout.writeln('Example:');
  stdout.writeln('  dart run bin/main.dart \\');
  stdout.writeln('    --current-file lib/user_modified.dart \\');
  stdout.writeln('    --generated-file lib/generated.dart \\');
  stdout.writeln('    --output-file lib/merged.dart');
}

