# Quick Reference Guide

## Installation & Setup

```bash
# Clone/navigate to project
cd dart-diff-cli

# Install dependencies
dart pub get

# Test with example
./run_example.sh
```

## Basic Usage

```bash
dart run bin/main.dart \
  --current-file <user-modified-file> \
  --generated-file <generated-file> \
  --output-file <output-file>
```

## Compile to Executable

```bash
# Compile
dart compile exe bin/main.dart -o dart-merge

# Run
./dart-merge -c current.dart -g generated.dart -o output.dart
```

## Merge Priority Rules

| Entity | P1 Exists | P2 Exists | Result |
|--------|-----------|-----------|--------|
| Import | ✅ | ❌ | P1 import added |
| Import | ❌ | ✅ | P2 import kept |
| Import | ✅ | ✅ | P2 import kept (same) |
| Field | ✅ | ✅ | **P1 version used** |
| Field | ✅ | ❌ | P1 field added |
| Field | ❌ | ✅ | P2 field kept |
| Method | ✅ | ✅ | **P1 version used** |
| Method | ✅ | ❌ | P1 method added |
| Method | ❌ | ✅ | P2 method kept |

## File Structure

```
dart-diff-cli/
├── bin/main.dart           # CLI entry point
├── lib/merger.dart         # Core merge logic
├── example/
│   ├── current_file.dart   # P1 example
│   ├── generated_file.dart # P2 example
│   └── merged_output.dart  # P3 output
├── README.md               # Full documentation
├── USAGE.md                # Usage examples
├── DEVELOPER_GUIDE.md      # Developer docs
└── pubspec.yaml            # Dependencies
```

## Key Classes

### DartAstMerger
Main orchestration class that coordinates the merge process.

### P1EntityCollector
Collects entities from user-modified file (imports, fields, methods, constructors).

### P2EntityCollector
Collects entities from generated file for comparison.

### SourceMerger
Reconstructs the merged source with P1 priority.

### MergeException
Custom exception for merge errors.

## CLI Options

| Option | Short | Description |
|--------|-------|-------------|
| `--current-file` | `-c` | User-modified file (P1) |
| `--generated-file` | `-g` | Generated file (P2) |
| `--output-file` | `-o` | Output file (P3) |
| `--help` | `-h` | Show help |

## Exit Codes

- `0` = Success
- `1` = Error

## Common Commands

### Run Example
```bash
./run_example.sh
```

### Run with Full Paths
```bash
dart run bin/main.dart \
  -c /full/path/to/current.dart \
  -g /full/path/to/generated.dart \
  -o /full/path/to/output.dart
```

### Show Help
```bash
dart run bin/main.dart --help
```

### Batch Process
```bash
for file in lib/*.dart; do
  dart run bin/main.dart \
    -c "$file" \
    -g "generated/${file##*/}" \
    -o "output/${file##*/}"
done
```

## Integration Examples

### Shell Script
```bash
dart run dart-diff-cli/bin/main.dart \
  -c lib/app.dart \
  -g lib/app.generated.dart \
  -o lib/app.dart
```

### Makefile
```makefile
merge:
	dart run dart-diff-cli/bin/main.dart \
		-c lib/app.dart \
		-g lib/app.generated.dart \
		-o lib/app.merged.dart
```

### Dart
```dart
final result = await Process.run('dart', [
  'run', 'bin/main.dart',
  '-c', 'lib/current.dart',
  '-g', 'lib/generated.dart',
  '-o', 'lib/output.dart',
]);
```

### Kotlin
```kotlin
ProcessBuilder(
  "dart", "run", "dart-diff-cli/bin/main.dart",
  "-c", "lib/current.dart",
  "-g", "lib/generated.dart",
  "-o", "lib/output.dart"
).start()
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `dart: command not found` | Install Dart SDK |
| Parse errors | Fix syntax in P1 file |
| Missing file | Check file paths |
| Format issues | Run `dart format output.dart` |

## Performance

| File Size | Typical Time |
|-----------|--------------|
| < 1K LOC | 100-150ms |
| 1-5K LOC | 150-300ms |
| > 5K LOC | 300-1000ms |

## Best Practices

1. ✅ Commit before merging
2. ✅ Review output manually
3. ✅ Keep backups
4. ✅ Test merged code
5. ✅ Run frequently
6. ❌ Don't skip review
7. ❌ Don't merge invalid syntax
8. ❌ Don't blindly accept output

## Entity Matching

### Imports
Matched by: URI
```dart
import 'package:flutter/material.dart';
```

### Fields
Matched by: Variable name
```dart
final String myField;
```

### Methods
Matched by: Name + parameter signature
```dart
void myMethod(int value) { }
```

### Constructors
Matched by: Constructor name
```dart
MyClass() : super();
MyClass.named() : super();
```

## Example Output

```
🔍 Analyzing files...
  P1 (User Modified): example/current_file.dart
  P2 (Generated): example/generated_file.dart
  P3 (Output): example/merged_output.dart

📊 Collected from P1 (User Modified):
   - 2 imports
   - 3 fields
   - 6 methods
   - 0 constructors

🔀 Merge Statistics:
   - Imports merged: 1
   - Fields replaced: 1
   - Methods replaced: 3
   - Constructors replaced: 0
   - New members added: 3

✅ Merge completed successfully!
⏱️  Time taken: 142ms
📄 Output written to: example/merged_output.dart
```

## Dependencies

```yaml
dependencies:
  analyzer: ^6.4.1      # AST parsing
  dart_style: ^2.3.4    # Code formatting
  args: ^2.4.2          # CLI arguments
  path: ^1.9.0          # Path utilities
```

## Links

- 📖 [Full Documentation](README.md)
- 🚀 [Usage Guide](USAGE.md)
- 🔧 [Developer Guide](DEVELOPER_GUIDE.md)
- 📝 [Changelog](CHANGELOG.md)

---

**Quick Start:** `./run_example.sh` → View `example/merged_output.dart`

