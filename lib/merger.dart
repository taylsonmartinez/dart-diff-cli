import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_style/dart_style.dart';

/// Custom exception for merge operations
class MergeException implements Exception {
  final String message;
  final String? details;

  MergeException(this.message, [this.details]);

  @override
  String toString() => 'MergeException: $message${details != null ? ' - $details' : ''}';
}

/// Main AST-based merger class
class DartAstMerger {
  final DartFormatter _formatter = DartFormatter();

  /// Performs the merge operation
  Future<void> merge({
    required String currentFilePath,
    required String generatedFilePath,
    required String outputFilePath,
  }) async {
    // Phase 1: Read and parse files
    final currentSource = await File(currentFilePath).readAsString();
    final generatedSource = await File(generatedFilePath).readAsString();

    final currentUnit = _parseFile(currentSource, currentFilePath);
    final generatedUnit = _parseFile(generatedSource, generatedFilePath);

    // Phase 2: Collect P1 entities (user modifications)
    final p1Collector = P1EntityCollector();
    currentUnit.visitChildren(p1Collector);

    stdout.writeln('📊 Collected from P1 (User Modified):');
    stdout.writeln('   - ${p1Collector.imports.length} imports');
    stdout.writeln('   - ${p1Collector.topLevelFunctions.length} top-level functions');
    stdout.writeln('   - ${p1Collector.topLevelVariables.length} top-level variables');
    stdout.writeln('   - ${p1Collector.topLevelEnums.length} enums');
    stdout.writeln('   - ${p1Collector.topLevelExtensions.length} extensions');
    stdout.writeln('   - ${p1Collector.fields.length} class fields');
    stdout.writeln('   - ${p1Collector.methods.length} class methods');
    stdout.writeln('   - ${p1Collector.constructors.length} constructors');

    // Phase 3: Merge P1 entities into P2
    final merger = SourceMerger(
      p1Entities: p1Collector,
      p2Unit: generatedUnit,
      p2Source: generatedSource,
    );

    // Phase 4: Generate merged source code
    final mergedSource = merger.merge();

    // Phase 5: Format the output
    String formattedSource;
    try {
      formattedSource = _formatter.format(mergedSource);
    } catch (e) {
      throw MergeException(
        'Failed to format merged code',
        'Formatter error: $e',
      );
    }

    // Phase 6: Write to output file
    final outputDir = File(outputFilePath).parent;
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    
    await File(outputFilePath).writeAsString(formattedSource);

    stdout.writeln('');
    stdout.writeln('🔀 Merge Statistics:');
    stdout.writeln('   - Imports merged: ${merger.importsMerged}');
    stdout.writeln('   - Fields replaced: ${merger.fieldsReplaced}');
    stdout.writeln('   - Methods replaced: ${merger.methodsReplaced}');
    stdout.writeln('   - Constructors replaced: ${merger.constructorsReplaced}');
    stdout.writeln('   - New members added: ${merger.newMembersAdded}');
  }

  /// Parse Dart source with error handling
  CompilationUnit _parseFile(String source, String filePath) {
    final parseResult = parseString(content: source);
    
    if (parseResult.errors.isNotEmpty) {
      final errorDetails = parseResult.errors
          .map((e) => '  Line ${e.offset}: ${e.message}')
          .join('\n');
      
      throw MergeException(
        'Failed to parse $filePath',
        'Syntax errors found:\n$errorDetails',
      );
    }

    return parseResult.unit;
  }
}

/// Collects all entities from P1 (user-modified file)
class P1EntityCollector extends RecursiveAstVisitor<void> {
  // Map of import URIs to their directive nodes
  final Map<String, ImportDirective> imports = {};
  
  // Top-level declarations (functions, variables, enums, etc.)
  final Map<String, FunctionDeclaration> topLevelFunctions = {};
  final Map<String, TopLevelVariableDeclaration> topLevelVariables = {};
  final Map<String, EnumDeclaration> topLevelEnums = {};
  final Map<String, ExtensionDeclaration> topLevelExtensions = {};
  
  // Map of class name to its members
  final Map<String, Map<String, FieldDeclaration>> fieldsByClass = {};
  final Map<String, Map<String, MethodDeclaration>> methodsByClass = {};
  final Map<String, Map<String, ConstructorDeclaration>> constructorsByClass = {};
  
  // Flatten maps for backward compatibility
  Map<String, FieldDeclaration> get fields {
    final result = <String, FieldDeclaration>{};
    for (final classFields in fieldsByClass.values) {
      result.addAll(classFields);
    }
    return result;
  }
  
  Map<String, MethodDeclaration> get methods {
    final result = <String, MethodDeclaration>{};
    for (final classMethods in methodsByClass.values) {
      result.addAll(classMethods);
    }
    return result;
  }
  
  Map<String, ConstructorDeclaration> get constructors {
    final result = <String, ConstructorDeclaration>{};
    for (final classConstructors in constructorsByClass.values) {
      result.addAll(classConstructors);
    }
    return result;
  }
  
  // Store annotations for preservation
  final Map<String, List<Annotation>> memberAnnotations = {};
  
  // Track current class context
  String? _currentClassName;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null) {
      imports[uri] = node;
    }
    super.visitImportDirective(node);
  }
  
  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Only collect top-level functions (not methods inside classes)
    if (_currentClassName == null) {
      final functionName = node.name.lexeme;
      topLevelFunctions[functionName] = node;
    }
    super.visitFunctionDeclaration(node);
  }
  
  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      topLevelVariables[variable.name.lexeme] = node;
    }
    super.visitTopLevelVariableDeclaration(node);
  }
  
  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    // Only collect top-level enums (should always be top-level anyway)
    if (_currentClassName == null) {
      topLevelEnums[node.name.lexeme] = node;
    }
    super.visitEnumDeclaration(node);
  }
  
  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    if (_currentClassName == null) {
      final extensionName = node.name?.lexeme ?? node.extendedType.toString();
      topLevelExtensions[extensionName] = node;
    }
    super.visitExtensionDeclaration(node);
  }
  
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _currentClassName = node.name.lexeme;
    super.visitClassDeclaration(node);
    _currentClassName = null;
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (_currentClassName != null) {
      fieldsByClass.putIfAbsent(_currentClassName!, () => {});
      for (final variable in node.fields.variables) {
        final fieldName = variable.name.lexeme;
        fieldsByClass[_currentClassName!]![fieldName] = node;
        
        // Store annotations
        if (node.metadata.isNotEmpty) {
          memberAnnotations[fieldName] = node.metadata.toList();
        }
      }
    }
    super.visitFieldDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_currentClassName != null) {
      methodsByClass.putIfAbsent(_currentClassName!, () => {});
      
      final signature = _createMethodSignature(node);
      methodsByClass[_currentClassName!]![signature] = node;
      
      // Store annotations (like @override)
      if (node.metadata.isNotEmpty) {
        memberAnnotations[signature] = node.metadata.toList();
      }
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (_currentClassName != null) {
      constructorsByClass.putIfAbsent(_currentClassName!, () => {});
      
      final constructorName = node.name?.lexeme ?? '';
      final signature = 'constructor:$constructorName';
      constructorsByClass[_currentClassName!]![signature] = node;
      
      if (node.metadata.isNotEmpty) {
        memberAnnotations[signature] = node.metadata.toList();
      }
    }
    super.visitConstructorDeclaration(node);
  }

  /// Creates a unique signature for a method
  /// Note: Dart doesn't support method overloading, so we use only the method name
  /// as the key to ensure P1 always wins when there's a name conflict
  String _createMethodSignature(MethodDeclaration node) {
    // Use only the method name (not parameters) because Dart doesn't support overloading
    return node.name.lexeme;
  }
  
  /// Get members for a specific class
  Map<String, FieldDeclaration> getFieldsForClass(String className) {
    return fieldsByClass[className] ?? {};
  }
  
  Map<String, MethodDeclaration> getMethodsForClass(String className) {
    return methodsByClass[className] ?? {};
  }
  
  Map<String, ConstructorDeclaration> getConstructorsForClass(String className) {
    return constructorsByClass[className] ?? {};
  }
}

/// Collects entities from P2 for comparison
class P2EntityCollector extends RecursiveAstVisitor<void> {
  final Map<String, ImportDirective> imports = {};
  
  // Track current class context
  String? _currentClassName;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri != null) {
      imports[uri] = node;
    }
    super.visitImportDirective(node);
  }
  
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _currentClassName = node.name.lexeme;
    super.visitClassDeclaration(node);
    _currentClassName = null;
  }

  String _createMethodSignature(MethodDeclaration node) {
    // Use only the method name (not parameters) because Dart doesn't support overloading
    return node.name.lexeme;
  }
}

/// Source-based merger that reconstructs the merged file
class SourceMerger {
  final P1EntityCollector p1Entities;
  final CompilationUnit p2Unit;
  final String p2Source;
  
  int importsMerged = 0;
  int fieldsReplaced = 0;
  int methodsReplaced = 0;
  int constructorsReplaced = 0;
  int newMembersAdded = 0;

  SourceMerger({
    required this.p1Entities,
    required this.p2Unit,
    required this.p2Source,
  });

  String merge() {
    final buffer = StringBuffer();
    
    // Step 1: Merge imports
    final p2Collector = P2EntityCollector();
    p2Unit.visitChildren(p2Collector);
    
    final mergedImports = _mergeImports(p2Collector);
    for (final import in mergedImports) {
      buffer.writeln(_nodeToSource(import));
    }
    
    if (mergedImports.isNotEmpty) {
      buffer.writeln();
    }
    
    // Step 2: Process other directives (exports, parts)
    for (final directive in p2Unit.directives) {
      if (directive is! ImportDirective) {
        buffer.writeln(_nodeToSource(directive));
      }
    }
    
    // Step 3: Merge top-level declarations (functions, variables, enums, extensions, classes)
    final handledP1TopLevel = <String>{};
    
    for (final declaration in p2Unit.declarations) {
      if (declaration is FunctionDeclaration) {
        final functionName = declaration.name.lexeme;
        if (p1Entities.topLevelFunctions.containsKey(functionName)) {
          // Use P1 version
          buffer.writeln(_nodeToSource(p1Entities.topLevelFunctions[functionName]!));
          handledP1TopLevel.add('function:$functionName');
          newMembersAdded++;
        } else {
          buffer.writeln(_nodeToSource(declaration));
        }
      } else if (declaration is TopLevelVariableDeclaration) {
        // Check if any variable in this declaration exists in P1
        bool replaced = false;
        for (final variable in declaration.variables.variables) {
          final varName = variable.name.lexeme;
          if (p1Entities.topLevelVariables.containsKey(varName)) {
            buffer.writeln(_nodeToSource(p1Entities.topLevelVariables[varName]!));
            handledP1TopLevel.add('variable:$varName');
            replaced = true;
            break;
          }
        }
        if (!replaced) {
          buffer.writeln(_nodeToSource(declaration));
        }
      } else if (declaration is EnumDeclaration) {
        final enumName = declaration.name.lexeme;
        if (p1Entities.topLevelEnums.containsKey(enumName)) {
          buffer.writeln(_nodeToSource(p1Entities.topLevelEnums[enumName]!));
          handledP1TopLevel.add('enum:$enumName');
        } else {
          buffer.writeln(_nodeToSource(declaration));
        }
      } else if (declaration is ExtensionDeclaration) {
        final extensionName = declaration.name?.lexeme ?? declaration.extendedType.toString();
        if (p1Entities.topLevelExtensions.containsKey(extensionName)) {
          buffer.writeln(_nodeToSource(p1Entities.topLevelExtensions[extensionName]!));
          handledP1TopLevel.add('extension:$extensionName');
        } else {
          buffer.writeln(_nodeToSource(declaration));
        }
      } else if (declaration is ClassDeclaration) {
        buffer.writeln(_mergeClassDeclaration(declaration, p2Collector));
      } else {
        // Other declarations (mixin, typedef, etc.)
        buffer.writeln(_nodeToSource(declaration));
      }
    }
    
    // Add P1-only top-level declarations that don't exist in P2
    for (final entry in p1Entities.topLevelFunctions.entries) {
      if (!handledP1TopLevel.contains('function:${entry.key}')) {
        buffer.writeln(_nodeToSource(entry.value));
        newMembersAdded++;
      }
    }
    
    for (final entry in p1Entities.topLevelVariables.entries) {
      if (!handledP1TopLevel.contains('variable:${entry.key}')) {
        buffer.writeln(_nodeToSource(entry.value));
        newMembersAdded++;
      }
    }
    
    for (final entry in p1Entities.topLevelEnums.entries) {
      if (!handledP1TopLevel.contains('enum:${entry.key}')) {
        buffer.writeln(_nodeToSource(entry.value));
        newMembersAdded++;
      }
    }
    
    for (final entry in p1Entities.topLevelExtensions.entries) {
      if (!handledP1TopLevel.contains('extension:${entry.key}')) {
        buffer.writeln(_nodeToSource(entry.value));
        newMembersAdded++;
      }
    }
    
    return buffer.toString();
  }

  List<ImportDirective> _mergeImports(P2EntityCollector p2Collector) {
    final result = <ImportDirective>[];
    final addedUris = <String>{};
    
    // First, add all P2 imports
    for (final import in p2Collector.imports.values) {
      final uri = import.uri.stringValue;
      if (uri != null) {
        result.add(import);
        addedUris.add(uri);
      }
    }
    
    // Then, add P1 imports that don't exist in P2
    for (final entry in p1Entities.imports.entries) {
      if (!addedUris.contains(entry.key)) {
        result.add(entry.value);
        importsMerged++;
      }
    }
    
    return result;
  }

  String _mergeClassDeclaration(
    ClassDeclaration p2Class,
    P2EntityCollector p2Collector,
  ) {
    final buffer = StringBuffer();
    final className = p2Class.name.lexeme;
    
    // Get P1 members for this specific class
    final p1Fields = p1Entities.getFieldsForClass(className);
    final p1Methods = p1Entities.getMethodsForClass(className);
    final p1Constructors = p1Entities.getConstructorsForClass(className);
    
    // Write class header (annotations, abstract, class name, extends, implements, etc.)
    if (p2Class.metadata.isNotEmpty) {
      for (final annotation in p2Class.metadata) {
        buffer.writeln(_nodeToSource(annotation));
      }
    }
    
    if (p2Class.abstractKeyword != null) {
      buffer.write('abstract ');
    }
    
    buffer.write('class $className');
    
    if (p2Class.typeParameters != null) {
      buffer.write(_nodeToSource(p2Class.typeParameters!));
    }
    
    if (p2Class.extendsClause != null) {
      buffer.write(' ${_nodeToSource(p2Class.extendsClause!)}');
    }
    
    if (p2Class.withClause != null) {
      buffer.write(' ${_nodeToSource(p2Class.withClause!)}');
    }
    
    if (p2Class.implementsClause != null) {
      buffer.write(' ${_nodeToSource(p2Class.implementsClause!)}');
    }
    
    buffer.writeln(' {');
    
    // Track which P1 entities have been merged
    final handledP1Fields = <String>{};
    final handledP1Methods = <String>{};
    final handledP1Constructors = <String>{};
    
    // Process P2 members and replace with P1 if they exist in the same class
    for (final member in p2Class.members) {
      if (member is FieldDeclaration) {
        bool replaced = false;
        for (final variable in member.fields.variables) {
          final fieldName = variable.name.lexeme;
          if (p1Fields.containsKey(fieldName)) {
            // Use P1 version
            buffer.writeln(_indent(_nodeToSource(p1Fields[fieldName]!)));
            handledP1Fields.add(fieldName);
            fieldsReplaced++;
            replaced = true;
            break;
          }
        }
        if (!replaced) {
          buffer.writeln(_indent(_nodeToSource(member)));
        }
      } else if (member is MethodDeclaration) {
        final methodName = member.name.lexeme;
        if (p1Methods.containsKey(methodName)) {
          final p1Method = p1Methods[methodName]!;
          
          // Strategy: Intelligent merge based on signature AND body changes
          // 1. If signature changed → Use P2 (API was updated)
          // 2. If signature is same BUT body changed → Use P2 (new structural changes like added widgets)
          // 3. If both signature and body are identical → Use P1 (preserve user customizations)
          
          final hasSignatureChange = _hasMethodSignatureChanged(p1Method, member);
          final hasBodyChange = _hasMethodBodyChanged(p1Method, member);
          
          if (hasSignatureChange) {
            // SCENARIO 1: Method signature changed in P2 (API update)
            // Use P2 to stay compatible with new API
            buffer.writeln(_indent(_nodeToSource(member)));
            stdout.writeln('   ⚠️  Method "$methodName" signature changed - using P2 (generated)');
          } else if (hasBodyChange) {
            // SCENARIO 2: Signature is same but body changed (structural updates like new widgets)
            // Use P2 to incorporate new structural elements
            buffer.writeln(_indent(_nodeToSource(member)));
            stdout.writeln('   📝  Method "$methodName" body changed - using P2 (generated)');
          } else {
            // SCENARIO 3: Both signature and body are identical
            // Use P1 to preserve user customizations (though they're the same)
            buffer.writeln(_indent(_nodeToSource(p1Method)));
            methodsReplaced++;
          }
          handledP1Methods.add(methodName);
        } else {
          // Method only exists in P2 - add it
          buffer.writeln(_indent(_nodeToSource(member)));
        }
      } else if (member is ConstructorDeclaration) {
        final constructorName = member.name?.lexeme ?? '';
        final signature = 'constructor:$constructorName';
        if (p1Constructors.containsKey(signature)) {
          // Use P1 version
          buffer.writeln(_indent(_nodeToSource(p1Constructors[signature]!)));
          handledP1Constructors.add(signature);
          constructorsReplaced++;
        } else {
          buffer.writeln(_indent(_nodeToSource(member)));
        }
      } else {
        buffer.writeln(_indent(_nodeToSource(member)));
      }
    }
    
    // Add new P1 members that don't exist in P2 (user-added members)
    for (final entry in p1Fields.entries) {
      if (!handledP1Fields.contains(entry.key)) {
        buffer.writeln(_indent(_nodeToSource(entry.value)));
        newMembersAdded++;
      }
    }
    
    for (final entry in p1Methods.entries) {
      if (!handledP1Methods.contains(entry.key)) {
        buffer.writeln(_indent(_nodeToSource(entry.value)));
        newMembersAdded++;
      }
    }
    
    for (final entry in p1Constructors.entries) {
      if (!handledP1Constructors.contains(entry.key)) {
        buffer.writeln(_indent(_nodeToSource(entry.value)));
        newMembersAdded++;
      }
    }
    
    buffer.writeln('}');
    
    return buffer.toString();
  }

  String _createMethodSignature(MethodDeclaration node) {
    // Use only the method name (not parameters) because Dart doesn't support overloading
    return node.name.lexeme;
  }
  
  /// Get list of parameter names from a method
  List<String> _getMethodParameters(MethodDeclaration node) {
    if (node.parameters == null) return [];
    return node.parameters!.parameters
        .map((p) => p.name?.lexeme ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
  
  /// Check if method signature has changed between P1 and P2
  /// Returns true if there are differences in parameters (count or names)
  bool _hasMethodSignatureChanged(MethodDeclaration p1Method, MethodDeclaration p2Method) {
    final p1Params = _getMethodParameters(p1Method);
    final p2Params = _getMethodParameters(p2Method);
    
    // Different number of parameters = signature changed
    if (p1Params.length != p2Params.length) {
      return true;
    }
    
    // Different parameter names = signature changed
    for (var i = 0; i < p1Params.length; i++) {
      if (p1Params[i] != p2Params[i]) {
        return true;
      }
    }
    
    // Same signature
    return false;
  }
  
  /// Check if method body has changed between P1 and P2
  /// Returns true if the implementation differs
  bool _hasMethodBodyChanged(MethodDeclaration p1Method, MethodDeclaration p2Method) {
    // Compare the body/implementation
    final p1Body = p1Method.body.toSource().trim();
    final p2Body = p2Method.body.toSource().trim();
    
    return p1Body != p2Body;
  }

  String _nodeToSource(AstNode node) {
    return node.toSource();
  }

  String _indent(String source) {
    return source.split('\n').map((line) => '  $line').join('\n');
  }
}

