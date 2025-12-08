# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-12-08

### Added
- Initial release of Dart AST Smart Merge CLI
- AST-based intelligent code merging with P1 priority strategy
- Support for merging imports, fields, methods, and constructors
- Command-line interface with robust argument parsing
- Automatic code formatting using `dart_style`
- Comprehensive error handling and validation
- Detailed merge statistics and reporting
- Example files demonstrating merge capabilities
- Full documentation with usage examples

### Features
- **P1 Priority Merging**: User modifications always take precedence
- **Structural Preservation**: New generated code elements are intelligently added
- **AST-Based Analysis**: Semantic understanding using official Dart analyzer
- **Format Preservation**: Automatic formatting with `dart_style`
- **Error Reporting**: Clear, actionable error messages with line numbers
- **Performance**: Fast merging (100-300ms for typical files)
- **External Tool Integration**: Designed for use in CI/CD and code generation pipelines

### Technical Details
- Built with Dart 3.0+ compatibility
- Uses `analyzer` package (^6.4.1) for AST parsing
- Uses `dart_style` package (^2.3.4) for formatting
- Uses `args` package (^2.4.2) for CLI argument parsing
- Immutable AST node handling with source reconstruction
- RecursiveAstVisitor pattern for entity collection
- Signature-based entity matching for accurate merging

