# 🎯 Dart AST Smart Merge CLI

[![Build Status](https://github.com/taylsonmartinez/dart-diff-cli/actions/workflows/build.yml/badge.svg)](https://github.com/taylsonmartinez/dart-diff-cli/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A sophisticated Dart CLI application for intelligent, surgical code merging on Flutter/Dart source files using Abstract Syntax Tree (AST) analysis.

## ✨ Features

- 🔍 **AST-Based Merging** - Semantic code understanding using official Dart analyzer
- 🎯 **P1 Priority Strategy** - User modifications always take precedence
- ⚡ **Fast Performance** - 100-300ms typical execution time
- 🔧 **Java/Kotlin Ready** - Complete integration classes included
- 📦 **Single Binary** - No Dart SDK required for execution
- 🌐 **Multi-Platform** - macOS, Linux, and Windows support

## 🚀 Quick Start

### Download Pre-compiled Binaries

Download the binary for your platform from [Releases](https://github.com/taylsonmartinez/dart-diff-cli/releases):

- **macOS**: `dart-ast-merge-macos`
- **Linux**: `dart-ast-merge-linux`
- **Windows**: `dart-ast-merge.exe`

### Basic Usage

```bash
# macOS/Linux
chmod +x dart-ast-merge-macos
./dart-ast-merge-macos \
  --current-file your_modified.dart \
  --generated-file generated.dart \
  --output-file merged.dart

# Windows
dart-ast-merge.exe ^
  --current-file your_modified.dart ^
  --generated-file generated.dart ^
  --output-file merged.dart
```

## 💡 How It Works

### The Problem

When using code generators (like `build_runner`), you often lose manual customizations when regenerating code.

### The Solution

This tool intelligently merges:
- **P1 (Current)**: Your file with customizations
- **P2 (Generated)**: Newly generated code
- **P3 (Output)**: Merged result preserving your customizations + new features

### Example

**Your File (P1):**
```dart
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return CustomizedUI(); // Your custom UI
  }
  
  void customMethod() { } // Your custom logic
}
```

**Generated (P2):**
```dart
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return BasicUI(); // Basic generated UI
  }
  
  void newGeneratedMethod() { } // New feature
}
```

**Merged Result (P3):**
```dart
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return CustomizedUI(); // ✅ Your custom UI preserved!
  }
  
  void customMethod() { } // ✅ Your custom logic preserved!
  void newGeneratedMethod() { } // ✅ New feature added!
}
```

## 🔧 Integration with Java/Kotlin

### Kotlin Example

```kotlin
val merger = DartAstMerger("tools/dart-ast-merge-macos")
val result = merger.merge(
    currentFile = "lib/my_widget.dart",
    generatedFile = "lib/my_widget.generated.dart",
    outputFile = "lib/my_widget.dart"
)

println("✅ Merge: ${result.success} (${result.executionTime}ms)")
```

### Java Example

```java
DartAstMerger merger = new DartAstMerger("tools/dart-ast-merge-macos");
MergeResult result = merger.merge(
    "lib/my_widget.dart",
    "lib/my_widget.generated.dart",
    "lib/my_widget.dart"
);

System.out.println("✅ Merge: " + result.isSuccess());
```

Complete integration classes included in `integration/` directory.

## 📚 Documentation

### Essential

- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[LICENSE](LICENSE)** - MIT License

### For Users

- **[Quick Start Guide](docs/GET_STARTED.md)** - 5-minute tutorial
- **[Usage Guide](docs/USAGE.md)** - Detailed usage examples
- **[Integration Guide](docs/INTEGRATION_GUIDE.md)** - Java/Kotlin integration

### For Contributors

- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Technical implementation
- **[Build Guide](docs/BUILD_GUIDE.md)** - Multi-platform compilation

### Portuguese 🇧🇷

- **[Guia em Português](docs/RESPOSTA_PORTUGUES.md)** - Documentação completa em PT-BR
- **[Guia de Distribuição](docs/DISTRIBUICAO_PT.md)** - Como compilar para todas plataformas

[📖 View all documentation](docs/)

## 🛠️ Building from Source

### Prerequisites

- Dart SDK 3.0+
- Git

### Compile for Your Platform

```bash
# Clone repository
git clone https://github.com/taylsonmartinez/dart-diff-cli.git
cd dart-diff-cli

# Install dependencies
dart pub get

# Compile
dart compile exe bin/main.dart -o dart-ast-merge

# Test
./dart-ast-merge --help
```

### Multi-Platform Builds

See [docs/BUILD_GUIDE.md](docs/BUILD_GUIDE.md) for instructions on building for all platforms.

## 🎯 Use Cases

1. **Code Generation Pipelines** - Integrate with `build_runner`, custom generators
2. **CI/CD Workflows** - Automate merges in continuous integration
3. **Template-Based Development** - Update templates while preserving customizations
4. **External Tool Integration** - Call from Kotlin/Java build systems

## 📊 Performance

| File Size | Typical Time |
|-----------|--------------|
| < 1K LOC | 100-150ms |
| 1-5K LOC | 150-300ms |
| > 5K LOC | 300-1000ms |

## 🤝 Contributing

Contributions are welcome! Please read [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) for details.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Dart Analyzer](https://pub.dev/packages/analyzer)
- Formatted with [Dart Style](https://pub.dev/packages/dart_style)
- CLI powered by [Args](https://pub.dev/packages/args)

## 📞 Support

- 🐛 [Report Issues](https://github.com/taylsonmartinez/dart-diff-cli/issues)
- 💬 [Discussions](https://github.com/taylsonmartinez/dart-diff-cli/discussions)
- 📖 [Documentation](docs/)

---

**Made with ❤️ for the Dart & Flutter community**
