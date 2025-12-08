# Developer Guide - Dart AST Smart Merge CLI

This guide is for developers who want to understand, modify, or extend the Dart AST Smart Merge CLI.

## Architecture Overview

### High-Level Flow

```
User Input (CLI Args)
    ↓
File Reading & Validation
    ↓
AST Parsing (P1 & P2)
    ↓
Entity Collection (P1)
    ↓
Source Merging (P1 Priority)
    ↓
Code Formatting (dart_style)
    ↓
File Writing (P3)
```

### Core Components

1. **`bin/main.dart`** - CLI Entry Point
   - Argument parsing using `args` package
   - File validation
   - Error handling and user feedback
   - Execution timing

2. **`lib/merger.dart`** - Core Merge Logic
   - `DartAstMerger` - Main orchestration class
   - `P1EntityCollector` - Collects user modifications
   - `P2EntityCollector` - Collects generated entities
   - `SourceMerger` - Reconstructs merged source
   - `MergeException` - Custom error handling

## Code Walkthrough

### 1. CLI Argument Parsing

```dart
// bin/main.dart
final parser = ArgParser()
  ..addOption('current-file', abbr: 'c', mandatory: true)
  ..addOption('generated-file', abbr: 'g', mandatory: true)
  ..addOption('output-file', abbr: 'o', mandatory: true);
```

The CLI uses the `args` package with mandatory named options. This ensures all required inputs are provided before execution.

### 2. AST Parsing

```dart
// lib/merger.dart - DartAstMerger.merge()
CompilationUnit _parseFile(String source, String filePath) {
  final parseResult = parseString(content: source);
  
  if (parseResult.errors.isNotEmpty) {
    // Fail fast with detailed error reporting
    throw MergeException('Failed to parse $filePath', ...);
  }
  
  return parseResult.unit;
}
```

Uses the official Dart `analyzer` package's `parseString()` function. This gives us a fully-typed AST that matches the Dart language specification.

### 3. Entity Collection (P1 Analysis)

```dart
class P1EntityCollector extends RecursiveAstVisitor<void> {
  final Map<String, MethodDeclaration> methods = {};
  
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final signature = _createMethodSignature(node);
    methods[signature] = node;
    super.visitMethodDeclaration(node);
  }
}
```

**Key Design Decision:** We use `RecursiveAstVisitor` to traverse the entire AST tree. This pattern automatically handles nested structures.

**Signature-Based Keying:** Methods are keyed by name + parameters to handle overloading correctly.

### 4. Source Reconstruction

```dart
class SourceMerger {
  String merge() {
    final buffer = StringBuffer();
    
    // Merge imports
    final mergedImports = _mergeImports(p2Collector);
    for (final import in mergedImports) {
      buffer.writeln(_nodeToSource(import));
    }
    
    // Merge classes with P1 priority
    for (final declaration in p2Unit.declarations) {
      if (declaration is ClassDeclaration) {
        buffer.writeln(_mergeClassDeclaration(declaration, p2Collector));
      }
    }
    
    return buffer.toString();
  }
}
```

**Why Source Reconstruction?** AST nodes in the `analyzer` package are immutable. Instead of trying to modify nodes, we rebuild the source code with P1 entities taking priority.

### 5. Class Member Merging

```dart
String _mergeClassDeclaration(ClassDeclaration p2Class, P2EntityCollector p2Collector) {
  // For each P2 member
  for (final member in p2Class.members) {
    if (member is MethodDeclaration) {
      final signature = _createMethodSignature(member);
      
      // Check if P1 has this method
      if (p1Entities.methods.containsKey(signature)) {
        // Use P1 version (USER WINS)
        buffer.writeln(_nodeToSource(p1Entities.methods[signature]!));
        methodsReplaced++;
      } else {
        // Use P2 version (new generated code)
        buffer.writeln(_nodeToSource(member));
      }
    }
  }
  
  // Add P1-only members (user additions)
  for (final entry in p1Entities.methods.entries) {
    if (!handledP1Methods.contains(entry.key)) {
      buffer.writeln(_nodeToSource(entry.value));
      newMembersAdded++;
    }
  }
}
```

This is where the "P1 Priority" strategy is implemented:
1. Iterate through P2 members
2. Replace with P1 version if it exists
3. Add P1-only members that don't exist in P2

## AST Node Types Reference

### Import Directives

```dart
import 'package:flutter/material.dart';
       ↓
ImportDirective {
  uri: SimpleStringLiteral("package:flutter/material.dart")
}
```

### Field Declarations

```dart
final String name;
       ↓
FieldDeclaration {
  fields: VariableDeclarationList {
    type: NamedType("String")
    variables: [
      VariableDeclaration {
        name: SimpleIdentifier("name")
      }
    ]
  }
}
```

### Method Declarations

```dart
void myMethod(int value) { ... }
       ↓
MethodDeclaration {
  returnType: NamedType("void")
  name: SimpleIdentifier("myMethod")
  parameters: FormalParameterList {
    parameters: [
      SimpleFormalParameter {
        type: NamedType("int")
        name: SimpleIdentifier("value")
      }
    ]
  }
  body: BlockFunctionBody { ... }
}
```

### Constructor Declarations

```dart
MyClass(this.value);
       ↓
ConstructorDeclaration {
  name: null (unnamed constructor)
  parameters: FormalParameterList {
    parameters: [
      FieldFormalParameter {
        name: SimpleIdentifier("value")
      }
    ]
  }
}
```

## Extending the Tool

### Adding New Entity Types

To support a new entity type (e.g., enums, extensions):

1. **Add Collection in P1EntityCollector:**

```dart
class P1EntityCollector extends RecursiveAstVisitor<void> {
  final Map<String, EnumDeclaration> enums = {};
  
  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    enums[node.name.lexeme] = node;
    super.visitEnumDeclaration(node);
  }
}
```

2. **Add to P2EntityCollector** (same pattern)

3. **Add Merging Logic in SourceMerger:**

```dart
String merge() {
  // ... existing code ...
  
  // Merge enums
  for (final declaration in p2Unit.declarations) {
    if (declaration is EnumDeclaration) {
      buffer.writeln(_mergeEnumDeclaration(declaration));
    }
  }
}
```

### Adding Configuration Options

To add a configuration file:

1. **Create Config Class:**

```dart
class MergeConfig {
  final bool preserveComments;
  final bool addMergeHeaders;
  final ConflictStrategy conflictStrategy;
  
  MergeConfig.fromJson(Map<String, dynamic> json)
    : preserveComments = json['preserve_comments'] ?? true,
      addMergeHeaders = json['add_merge_headers'] ?? false,
      conflictStrategy = ConflictStrategy.values.byName(
          json['conflict_strategy'] ?? 'p1_priority');
}
```

2. **Update DartAstMerger:**

```dart
class DartAstMerger {
  final MergeConfig config;
  
  DartAstMerger({MergeConfig? config}) 
    : config = config ?? MergeConfig.defaults();
}
```

### Adding Annotation-Based Directives

Support directives like `@MergeIgnore` or `@MergeKeepGenerated`:

```dart
class P1EntityCollector extends RecursiveAstVisitor<void> {
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Check for merge directives
    final hasIgnore = node.metadata.any(
      (a) => a.name.name == 'MergeIgnore'
    );
    
    if (!hasIgnore) {
      final signature = _createMethodSignature(node);
      methods[signature] = node;
    }
    
    super.visitMethodDeclaration(node);
  }
}
```

## Performance Optimization

### Current Performance

- Typical file (< 1000 LOC): 100-150ms
- Large file (1000-5000 LOC): 150-300ms
- Very large file (> 5000 LOC): 300-1000ms

### Optimization Strategies

1. **Lazy Parsing:**

```dart
// Only parse regions that differ
final p1Changed = detectChangedRegions(p1Source);
final p2Changed = detectChangedRegions(p2Source);
```

2. **Parallel Collection:**

```dart
// Collect P1 and P2 entities in parallel
final results = await Future.wait([
  Future(() => collectP1Entities(p1Unit)),
  Future(() => collectP2Entities(p2Unit)),
]);
```

3. **Streaming Output:**

```dart
// Write output incrementally instead of buffering
class StreamingSourceMerger {
  Future<void> mergeToStream(IOSink sink) async {
    await for (final chunk in _generateChunks()) {
      sink.write(chunk);
    }
  }
}
```

## Testing Strategy

### Unit Tests

```dart
// test/merger_test.dart
import 'package:test/test.dart';
import 'package:dart_diff_cli/merger.dart';

void main() {
  group('P1EntityCollector', () {
    test('collects methods correctly', () {
      final source = '''
        class MyClass {
          void myMethod() {}
        }
      ''';
      
      final unit = parseString(content: source).unit;
      final collector = P1EntityCollector();
      unit.visitChildren(collector);
      
      expect(collector.methods, hasLength(1));
      expect(collector.methods.keys.first, contains('myMethod'));
    });
  });
}
```

### Integration Tests

```dart
test('end-to-end merge preserves user modifications', () async {
  final merger = DartAstMerger();
  
  await merger.merge(
    currentFilePath: 'test/fixtures/current.dart',
    generatedFilePath: 'test/fixtures/generated.dart',
    outputFilePath: 'test/output/merged.dart',
  );
  
  final output = await File('test/output/merged.dart').readAsString();
  
  expect(output, contains('userAddedMethod'));
  expect(output, contains('generatedNewField'));
});
```

## Debugging Tips

### Visualizing AST

```dart
void printAst(AstNode node, [int depth = 0]) {
  final indent = '  ' * depth;
  print('$indent${node.runtimeType}');
  node.visitChildren(_AstPrinter(depth + 1));
}

class _AstPrinter extends RecursiveAstVisitor<void> {
  final int depth;
  _AstPrinter(this.depth);
  
  @override
  void visitNode(AstNode node) {
    printAst(node, depth);
    super.visitNode(node);
  }
}
```

### Comparing ASTs

```dart
void compareAsts(CompilationUnit p1, CompilationUnit p2) {
  print('P1 imports: ${p1.directives.whereType<ImportDirective>().length}');
  print('P2 imports: ${p2.directives.whereType<ImportDirective>().length}');
  
  // Compare class members
  final p1Classes = p1.declarations.whereType<ClassDeclaration>();
  final p2Classes = p2.declarations.whereType<ClassDeclaration>();
  
  print('P1 classes: ${p1Classes.length}');
  print('P2 classes: ${p2Classes.length}');
}
```

### Logging Merge Decisions

```dart
class SourceMerger {
  final bool verbose;
  
  String _mergeClassDeclaration(...) {
    if (verbose) {
      print('Processing class: ${p2Class.name.lexeme}');
    }
    
    for (final member in p2Class.members) {
      if (shouldReplace(member)) {
        if (verbose) print('  Replacing: ${memberName(member)}');
      }
    }
  }
}
```

## Common Pitfalls

### 1. Indentation Issues

**Problem:** Merged code has inconsistent indentation.

**Solution:** Always use `dart_style` formatter as the final step:

```dart
final formatted = DartFormatter().format(mergedSource);
```

### 2. Signature Matching

**Problem:** Methods with same name but different parameters aren't matched correctly.

**Solution:** Include parameter types in signature:

```dart
String _createMethodSignature(MethodDeclaration node) {
  final name = node.name.lexeme;
  final params = node.parameters?.parameters
      .map((p) => '${p.type}:${p.name}')
      .join(',') ?? '';
  return '$name($params)';
}
```

### 3. Annotation Preservation

**Problem:** Annotations like `@override` are lost.

**Solution:** Include metadata in node-to-source conversion:

```dart
String _nodeToSource(AstNode node) {
  if (node is Declaration && node.metadata.isNotEmpty) {
    final annotations = node.metadata
        .map((a) => a.toSource())
        .join('\n');
    return '$annotations\n${node.toSource()}';
  }
  return node.toSource();
}
```

## Future Enhancements

### Planned Features

1. **Interactive Mode:** Prompt user for conflict resolution
2. **Diff Visualization:** Show what changed between P1 and P2
3. **Merge Strategies:** Support different merge modes (P1 priority, P2 priority, manual)
4. **Configuration Files:** Support `.mergeconfig.yaml` for project-specific rules
5. **Plugin System:** Allow custom merge handlers
6. **Watch Mode:** Automatically merge when files change
7. **IDE Integration:** VSCode/IntelliJ plugins

### Contribution Areas

- **Parser Enhancements:** Support for more Dart constructs
- **Performance:** Optimize for very large files
- **Error Recovery:** Better handling of partial syntax errors
- **Documentation:** More examples and use cases
- **Testing:** Comprehensive test suite

---

## Resources

- [Dart Analyzer Package Documentation](https://pub.dev/packages/analyzer)
- [Dart AST API Reference](https://pub.dev/documentation/analyzer/latest/dart_ast_ast/dart_ast_ast-library.html)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [RecursiveAstVisitor Pattern](https://pub.dev/documentation/analyzer/latest/dart_ast_visitor/RecursiveAstVisitor-class.html)

## Contact & Support

For questions, issues, or contributions:
- Open an issue on GitHub
- Submit a pull request
- Contact the maintainers

---

**Happy Coding!** 🎯

