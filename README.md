# 🎯 Dart AST Smart Merge CLI

A sophisticated Dart CLI application that performs intelligent, surgical code merges on Flutter/Dart source files using Abstract Syntax Tree (AST) analysis. This tool preserves user customizations while incorporating new structural elements from generated code.

## 🚀 Overview

The Dart AST Smart Merge CLI is designed to solve a common problem in code generation workflows: how to merge user modifications with freshly generated code without losing custom logic or creating conflicts. 

**Key Principle: User Wins (P1 Priority)**

When a Dart entity (import, field, method, constructor) exists in both the user-modified file (P1) and the generated file (P2), the P1 version is preserved. New entities from P2 are added only if they don't exist in P1.

## 🛠️ Technology Stack

- **Language:** Dart 3.0+
- **Core Libraries:**
  - `analyzer` (^6.4.1) - Official Dart AST parsing and analysis
  - `dart_style` (^2.3.4) - Code formatting and pretty-printing
  - `args` (^2.4.2) - Command-line argument parsing
  - `path` (^1.9.0) - Path manipulation utilities

## 📦 Installation

### Option 1: Run from Source

```bash
# Clone or navigate to the project directory
cd dart-diff-cli

# Install dependencies
dart pub get

# Run the CLI
dart run bin/main.dart --help
```

### Option 2: Compile to Executable

```bash
# Compile to native executable
dart compile exe bin/main.dart -o dart-merge

# Run the compiled executable
./dart-merge --help
```

## 📖 Usage

### Basic Command

```bash
dart run bin/main.dart \
  --current-file <path-to-user-modified-file> \
  --generated-file <path-to-generated-file> \
  --output-file <path-to-output-file>
```

### Command-Line Arguments

| Argument | Short | Required | Description |
|----------|-------|----------|-------------|
| `--current-file` | `-c` | Yes | Path to the file with user modifications (P1) |
| `--generated-file` | `-g` | Yes | Path to the newly generated file (P2) |
| `--output-file` | `-o` | Yes | Path where the merged file will be written (P3) |
| `--help` | `-h` | No | Display usage information |

### Example

```bash
dart run bin/main.dart \
  --current-file example/current_file.dart \
  --generated-file example/generated_file.dart \
  --output-file example/merged_output.dart
```

## 🔍 How It Works

### Phase 1: Setup and AST Parsing
1. Validates command-line arguments
2. Reads both input files
3. Parses files into Abstract Syntax Trees using the Dart `analyzer` package
4. Fails fast with detailed error messages if syntax errors are found

### Phase 2: Entity Collection (P1 Analysis)
The tool traverses the P1 (user-modified) AST and collects:
- **Imports:** All import directives (keyed by URI)
- **Fields:** All class field declarations (keyed by name)
- **Methods:** All method declarations (keyed by name + parameter signature)
- **Constructors:** All constructor declarations (keyed by name)
- **Annotations:** Custom annotations and metadata

### Phase 3: Intelligent Merging (P2 Modification)
The tool processes the P2 (generated) AST:
- **Import Injection:** Adds P1 imports that don't exist in P2
- **Member Replacement:** Replaces P2 members with P1 versions when names match
- **New Member Addition:** Adds P1 members that don't exist in P2 (user additions)
- **Preservation:** Keeps new P2 members that don't conflict with P1

### Phase 4: Output and Formatting
1. Generates source code from the merged AST
2. Applies `dart_style` formatting for clean, consistent output
3. Writes the result to the output file
4. Provides detailed merge statistics

## 📊 Merge Strategy Examples

### Example 1: Field Preservation

**P1 (User Modified):**
```dart
// User added custom initialization
final TextEditingController _controller = TextEditingController();
bool _isLoading = false; // User added this field
```

**P2 (Generated):**
```dart
// Basic field
final TextEditingController _controller = TextEditingController();
final FocusNode _focusNode = FocusNode(); // New generated field
```

**Result (Merged):**
```dart
// User's version is preserved
final TextEditingController _controller = TextEditingController();
bool _isLoading = false; // Preserved from P1
final FocusNode _focusNode = FocusNode(); // Added from P2
```

### Example 2: Method Override

**P1 (User Modified):**
```dart
@override
void initState() {
  super.initState();
  _controller.addListener(_onTextChanged); // User customization
  _loadInitialData(); // User customization
}
```

**P2 (Generated):**
```dart
@override
void initState() {
  super.initState();
  // Basic generated initialization
}
```

**Result (Merged):**
```dart
@override
void initState() {
  super.initState();
  _controller.addListener(_onTextChanged); // P1 version wins
  _loadInitialData();
}
```

### Example 3: New Method Addition

**P1 (User Modified):**
```dart
// User added custom helper method
Future<void> _handleSubmit() async {
  // Custom submission logic
}
```

**P2 (Generated):**
```dart
// This method doesn't exist in P2
```

**Result (Merged):**
```dart
// User's custom method is preserved
Future<void> _handleSubmit() async {
  // Custom submission logic
}
```

## 🎯 Use Cases

1. **Code Generation Pipelines:** Integrate with Flutter/Dart code generators (like `build_runner`, custom generators)
2. **External Tool Integration:** Call from Kotlin/Java build systems or other external tools
3. **CI/CD Workflows:** Automate merge operations in continuous integration pipelines
4. **Template-Based Development:** Maintain custom logic while updating generated templates

## 🏗️ Project Structure

```
dart-diff-cli/
├── bin/
│   └── main.dart              # CLI entry point
├── lib/
│   └── merger.dart            # Core merge logic and AST manipulation
├── example/
│   ├── current_file.dart      # Example user-modified file (P1)
│   ├── generated_file.dart    # Example generated file (P2)
│   └── merged_output.dart     # Example merged output (P3)
├── pubspec.yaml               # Dependencies and package config
└── README.md                  # This file
```

## 🔧 Implementation Details

### AST Node Handling

The merger uses the official Dart `analyzer` package's AST visitor pattern:

```dart
// Collecting P1 entities
class P1EntityCollector extends RecursiveAstVisitor<void> {
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Collect method with signature-based key
    final signature = _createMethodSignature(node);
    methods[signature] = node;
    super.visitMethodDeclaration(node);
  }
}
```

### Source Reconstruction

Since AST nodes are immutable, the merger reconstructs source code:

```dart
class SourceMerger {
  String merge() {
    // Rebuild source with P1 priority
    final buffer = StringBuffer();
    // ... merge imports
    // ... merge class members with P1 priority
    return buffer.toString();
  }
}
```

### Error Handling

The tool includes comprehensive error handling:
- Syntax error detection with line numbers
- File existence validation
- Formatting error recovery
- Detailed error messages with context

## 📈 Output Example

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

## 🚦 Exit Codes

- `0` - Success
- `1` - Error (argument parsing, file not found, merge failure)

## 🤝 Contributing

This tool is designed to be extended. Key areas for contribution:
- Additional merge strategies (e.g., annotation-based merging)
- Support for more Dart constructs (mixins, extensions)
- Configuration file support
- Diff visualization
- Interactive merge mode

## 📄 License

This project is provided as-is for use in code generation workflows.

## 🎓 Technical Notes

### Why AST-Based Merging?

Traditional text-based or line-based merging fails with code generation because:
1. Code structure changes break line-based merges
2. Formatting differences cause false conflicts
3. No semantic understanding of code entities

AST-based merging solves these by:
1. Understanding code structure semantically
2. Matching entities by signature, not position
3. Preserving user intent regardless of formatting

### Performance Considerations

- Typical merge time: 100-300ms for medium-sized files
- Memory efficient: Streams file content
- Suitable for CI/CD pipelines
- Can be compiled to native executable for faster startup

---

**Built with ❤️ for the Dart & Flutter community**

