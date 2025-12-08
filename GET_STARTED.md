# 🚀 Get Started with Dart AST Smart Merge CLI

Welcome! This guide will get you up and running in 5 minutes.

## ⚡ Quick Start (3 Steps)

### Step 1: Install Dependencies

```bash
cd /Users/taylson/developer/dart-diff-cli
dart pub get
```

### Step 2: Run the Example

```bash
./run_example.sh
```

### Step 3: View the Result

```bash
cat example/merged_output.dart
```

That's it! You've successfully merged user modifications with generated code. ✨

## 🎯 What Just Happened?

The tool merged two files:

1. **`example/current_file.dart`** (P1) - Contains user customizations:
   - Custom error handling
   - Loading states
   - Form submission logic
   - Custom UI elements

2. **`example/generated_file.dart`** (P2) - Contains new generated features:
   - Focus management
   - Character counting
   - New utility methods

3. **`example/merged_output.dart`** (P3) - The result:
   - ✅ All user customizations preserved
   - ✅ New generated features added
   - ✅ No conflicts
   - ✅ Properly formatted

## 📖 Your First Real Merge

Now try it with your own files:

```bash
dart run bin/main.dart \
  --current-file path/to/your/modified.dart \
  --generated-file path/to/your/generated.dart \
  --output-file path/to/output.dart
```

## 🎓 Understanding the Output

When you run a merge, you'll see:

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

**What this means:**
- **Imports merged:** P1 imports not in P2 were added
- **Fields replaced:** P2 fields were replaced with P1 versions
- **Methods replaced:** P2 methods were replaced with P1 versions
- **New members added:** P1-only members were added to output

## 🔑 Key Principle: User Wins

The merge follows one simple rule: **If it exists in your file (P1), your version is used.**

| Entity | P1 (Your File) | P2 (Generated) | Result |
|--------|----------------|----------------|--------|
| `myMethod()` | ✅ Custom logic | ✅ Basic version | P1 wins! |
| `newField` | ❌ Doesn't exist | ✅ New feature | P2 added! |
| `userField` | ✅ Your field | ❌ Doesn't exist | P1 kept! |

## 📚 Next Steps

### Read the Documentation

1. **[README.md](README.md)** - Full project documentation
2. **[USAGE.md](USAGE.md)** - Detailed usage guide with examples
3. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command reference
4. **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - For extending the tool

### Try Different Scenarios

1. **Modify the example:** Edit `example/current_file.dart` and run merge again
2. **Add new features:** Add a method to `example/generated_file.dart`
3. **Test conflicts:** Change the same method in both files

### Integrate into Your Workflow

1. **Shell script:**
```bash
#!/bin/bash
dart run dart-diff-cli/bin/main.dart \
  -c lib/my_widget.dart \
  -g lib/my_widget.generated.dart \
  -o lib/my_widget.dart
```

2. **Makefile:**
```makefile
merge:
	@dart run dart-diff-cli/bin/main.dart \
		-c lib/app.dart -g lib/app.g.dart -o lib/app.dart
```

3. **CI/CD:** See [USAGE.md](USAGE.md) for GitHub Actions and GitLab CI examples

### Compile for Production

For faster execution, compile to native executable:

```bash
# Compile
dart compile exe bin/main.dart -o dart-merge

# Run compiled version
./dart-merge -c current.dart -g generated.dart -o output.dart
```

## 🆘 Troubleshooting

### Issue: "dart: command not found"

**Solution:** Install Dart SDK from https://dart.dev/get-dart

### Issue: Parse errors

**Solution:** Ensure your P1 file has valid Dart syntax:
```bash
dart analyze your_file.dart
```

### Issue: Unexpected results

**Solution:** 
1. Check entity names match exactly
2. Review method signatures
3. Ensure files have similar structure

## 💡 Tips

1. ✅ **Always commit before merging** - Version control is your friend
2. ✅ **Review the output** - Don't blindly accept merged code
3. ✅ **Run frequently** - Easier to merge small changes than large ones
4. ✅ **Test thoroughly** - Verify the merged code works as expected

## 🎯 Common Use Cases

### Use Case 1: Code Generation with build_runner

```bash
# Generate code
dart run build_runner build

# Merge with existing
dart run dart-diff-cli/bin/main.dart \
  -c lib/models/user.dart \
  -g lib/models/user.g.dart \
  -o lib/models/user.dart
```

### Use Case 2: Template Updates

```bash
# Update from template, preserve customizations
dart run dart-diff-cli/bin/main.dart \
  -c src/my_screen.dart \
  -g templates/screen_template.dart \
  -o src/my_screen.dart
```

### Use Case 3: Batch Processing

```bash
# Merge multiple files
for file in lib/models/*.dart; do
  dart run dart-diff-cli/bin/main.dart \
    -c "$file" \
    -g "${file%.dart}.g.dart" \
    -o "$file"
done
```

## 📊 What's Inside?

| File/Directory | Description |
|----------------|-------------|
| `bin/main.dart` | CLI entry point |
| `lib/merger.dart` | Core merge logic (AST manipulation) |
| `example/` | Working example files |
| `README.md` | Complete documentation |
| `USAGE.md` | Usage guide |
| `DEVELOPER_GUIDE.md` | Technical deep dive |
| `run_example.sh` | Example runner script |

## 🎓 How It Works (Simple Version)

1. **Parse:** Read both files and convert to syntax trees (AST)
2. **Collect:** Extract all entities (imports, fields, methods) from your file (P1)
3. **Merge:** For each generated entity (P2):
   - If exists in P1: Use P1 version
   - If new in P2: Add to output
4. **Format:** Apply Dart formatting
5. **Write:** Save merged result

## ✨ Features at a Glance

- ✅ Preserves user modifications
- ✅ Incorporates new generated code
- ✅ No manual conflict resolution
- ✅ AST-based (semantic understanding)
- ✅ Fast (100-300ms typical)
- ✅ Format-safe (uses dart_style)
- ✅ Integration-ready (Shell/Make/CI-CD)
- ✅ Production-grade error handling

## 🎉 You're Ready!

You now have everything you need to start using the Dart AST Smart Merge CLI. 

### Quick Command Reference

```bash
# Run merge
dart run bin/main.dart -c P1 -g P2 -o P3

# Run example
./run_example.sh

# Show help
dart run bin/main.dart --help

# Compile to executable
dart compile exe bin/main.dart -o dart-merge
```

### Need More Help?

- 📖 Read [README.md](README.md) for comprehensive documentation
- 🚀 Check [USAGE.md](USAGE.md) for detailed examples
- ⚡ See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for command reference
- 🔧 Review [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for technical details

---

**Happy Merging!** 🎯

If you find this tool useful, consider starring it and sharing with your team!

