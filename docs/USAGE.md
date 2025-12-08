# Dart AST Smart Merge CLI - Usage Guide

## Quick Start

### 1. Install Dependencies

```bash
dart pub get
```

### 2. Run the Example

```bash
# Make the example script executable (Unix/Linux/Mac)
chmod +x run_example.sh

# Run the example
./run_example.sh
```

Or manually:

```bash
dart run bin/main.dart \
  --current-file example/current_file.dart \
  --generated-file example/generated_file.dart \
  --output-file example/merged_output.dart
```

### 3. View the Result

```bash
cat example/merged_output.dart
```

## Command-Line Interface

### Synopsis

```bash
dart run bin/main.dart [OPTIONS]
```

### Required Options

- `--current-file PATH` or `-c PATH`  
  Path to the current file containing user modifications (P1)

- `--generated-file PATH` or `-g PATH`  
  Path to the newly generated file (P2)

- `--output-file PATH` or `-o PATH`  
  Path where the merged output will be written (P3)

### Optional Flags

- `--help` or `-h`  
  Display usage information and exit

### Examples

#### Basic Usage

```bash
dart run bin/main.dart \
  -c lib/my_screen.dart \
  -g lib/my_screen.generated.dart \
  -o lib/my_screen.merged.dart
```

#### With Full Paths

```bash
dart run bin/main.dart \
  --current-file /path/to/project/lib/user_modified.dart \
  --generated-file /path/to/project/lib/generated.dart \
  --output-file /path/to/project/lib/output.dart
```

## Integration Examples

### 1. Shell Script Integration

```bash
#!/bin/bash

# merge_generated_code.sh
CURRENT="lib/screens/home_screen.dart"
GENERATED="lib/screens/home_screen.generated.dart"
OUTPUT="lib/screens/home_screen.dart"

dart run path/to/dart-diff-cli/bin/main.dart \
  --current-file "$CURRENT" \
  --generated-file "$GENERATED" \
  --output-file "$OUTPUT"
```

### 2. Makefile Integration

```makefile
.PHONY: merge-code

merge-code:
	@echo "Merging generated code..."
	@dart run dart-diff-cli/bin/main.dart \
		--current-file lib/app.dart \
		--generated-file lib/app.generated.dart \
		--output-file lib/app.merged.dart
	@echo "Merge complete!"
```

### 3. Dart Script Integration

```dart
import 'dart:io';

Future<void> main() async {
  final result = await Process.run(
    'dart',
    [
      'run',
      'dart-diff-cli/bin/main.dart',
      '--current-file', 'lib/current.dart',
      '--generated-file', 'lib/generated.dart',
      '--output-file', 'lib/merged.dart',
    ],
  );
  
  print(result.stdout);
  
  if (result.exitCode != 0) {
    print('Error: ${result.stderr}');
    exit(1);
  }
}
```

### 4. Kotlin/Java Integration

```kotlin
// Kotlin example
fun mergeGeneratedCode(
    currentFile: String,
    generatedFile: String,
    outputFile: String
): Boolean {
    val process = ProcessBuilder(
        "dart", "run", "dart-diff-cli/bin/main.dart",
        "--current-file", currentFile,
        "--generated-file", generatedFile,
        "--output-file", outputFile
    ).redirectErrorStream(true).start()
    
    val exitCode = process.waitFor()
    val output = process.inputStream.bufferedReader().readText()
    
    println(output)
    return exitCode == 0
}
```

### 5. CI/CD Pipeline Integration

#### GitHub Actions

```yaml
name: Merge Generated Code

on:
  push:
    branches: [ main ]

jobs:
  merge:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
      
      - name: Install dependencies
        run: dart pub get
        working-directory: dart-diff-cli
      
      - name: Run merge
        run: |
          dart run dart-diff-cli/bin/main.dart \
            --current-file lib/app.dart \
            --generated-file lib/app.generated.dart \
            --output-file lib/app.merged.dart
```

#### GitLab CI

```yaml
merge-code:
  stage: build
  image: dart:stable
  script:
    - cd dart-diff-cli
    - dart pub get
    - dart run bin/main.dart \
        --current-file ../lib/app.dart \
        --generated-file ../lib/app.generated.dart \
        --output-file ../lib/app.merged.dart
  artifacts:
    paths:
      - lib/app.merged.dart
```

## Advanced Usage

### Compiling to Native Executable

For faster startup times in production:

```bash
# Compile
dart compile exe bin/main.dart -o dart-merge

# Use the compiled executable
./dart-merge \
  --current-file lib/current.dart \
  --generated-file lib/generated.dart \
  --output-file lib/merged.dart
```

### Batch Processing

```bash
#!/bin/bash

# Process multiple files
for file in lib/screens/*.dart; do
  basename=$(basename "$file" .dart)
  echo "Processing $basename..."
  
  dart run bin/main.dart \
    --current-file "$file" \
    --generated-file "lib/generated/${basename}.generated.dart" \
    --output-file "lib/merged/${basename}.merged.dart"
done
```

## Understanding the Output

### Success Output

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

### Error Output

```
❌ Error: Current file does not exist: lib/nonexistent.dart
```

```
❌ Merge failed: Failed to parse lib/current.dart
   Details: Syntax errors found:
  Line 45: Expected ';' after expression
  Line 67: Unexpected token '}'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - merge completed without errors |
| 1 | Error - see stderr for details |

## Troubleshooting

### "dart: command not found"

**Solution:** Install Dart SDK from https://dart.dev/get-dart

### "Failed to parse" errors

**Solution:** Ensure your P1 (current) file has valid Dart syntax. The tool requires syntactically correct input.

### Unexpected merge results

**Solution:** Check that:
1. Entity names match exactly between P1 and P2
2. Method signatures are compatible
3. The files are structurally similar (same class names)

### Formatting issues

**Solution:** The tool automatically applies `dart_style` formatting. If you have custom formatting rules, apply them after the merge.

## Best Practices

1. **Version Control:** Always commit your current file before running the merge
2. **Review Output:** Manually review the merged output before using it
3. **Backup:** Keep backups of both input files
4. **Incremental Merging:** Run merges frequently rather than after large changes
5. **Testing:** Test the merged code thoroughly before deploying

## Tips and Tricks

### Preserving Custom Comments

Comments inside methods are preserved from P1:

```dart
// P1 (Current)
void myMethod() {
  // This important comment will be preserved
  doSomething();
}
```

### Handling Conflicts

If you want P2's version instead of P1's:
1. Remove the entity from P1 before merging
2. Run the merge
3. Manually add back any needed customizations

### Using with Code Generators

```bash
# Generate code
dart run build_runner build

# Merge with existing
dart run dart-diff-cli/bin/main.dart \
  --current-file lib/my_widget.dart \
  --generated-file lib/my_widget.g.dart \
  --output-file lib/my_widget.dart
```

---

For more information, see the [README](README.md) or run `dart run bin/main.dart --help`.

