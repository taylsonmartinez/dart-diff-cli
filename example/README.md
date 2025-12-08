# Example Files

This directory contains example files demonstrating the merge capabilities of the Dart AST Smart Merge CLI.

## Files

### `current_file.dart` (P1 - User Modified)

This file represents a Flutter screen that has been modified by a developer. It includes:

- **User-added imports:** `package:flutter/services.dart`
- **User-added fields:** 
  - `_isLoading` - Loading state management
  - `_errorMessage` - Error handling
- **User-modified methods:**
  - `initState()` - Custom initialization with listeners
  - `dispose()` - Custom cleanup
  - `build()` - Heavily customized UI with error display
- **User-added methods:**
  - `_onTextChanged()` - Custom text change handler
  - `_loadInitialData()` - Async data loading
  - `_handleSubmit()` - Form submission logic

### `generated_file.dart` (P2 - Generated)

This file represents freshly generated code from a code generator. It includes:

- **Basic structure:** Standard Flutter StatefulWidget
- **New generated fields:**
  - `_focusNode` - New feature for focus management
  - `_characterCount` - New feature for character counting
- **Generated methods:**
  - `_updateCharacterCount()` - New generated utility
  - Updated `dispose()` - With cleanup for new fields
  - Basic `build()` - Simple generated UI

### `merged_output.dart` (P3 - Output)

After running the merge, this file will contain:

**From P1 (Preserved):**
- User's custom import (`services.dart`)
- User's fields (`_isLoading`, `_errorMessage`)
- User's versions of `initState()`, `dispose()`, `build()`
- User's custom methods (`_onTextChanged`, `_loadInitialData`, `_handleSubmit`)

**From P2 (Added):**
- New generated field `_focusNode`
- New generated field `_characterCount`
- New generated method `_updateCharacterCount()`

**Result:** A perfect blend where user customizations are preserved and new generated features are incorporated.

## Running the Example

### Option 1: Use the Script

```bash
# From the project root
./run_example.sh
```

### Option 2: Manual Command

```bash
# From the project root
dart run bin/main.dart \
  --current-file example/current_file.dart \
  --generated-file example/generated_file.dart \
  --output-file example/merged_output.dart
```

### View the Result

```bash
cat example/merged_output.dart
```

Or open it in your editor to see the merged code.

## Expected Merge Behavior

### Imports

**P1:** 
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // User added
```

**P2:**
```dart
import 'package:flutter/material.dart';
```

**Merged:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // P1 import added
```

### Fields

**P1:**
```dart
final TextEditingController _controller = TextEditingController();
bool _isLoading = false; // User field
String? _errorMessage; // User field
```

**P2:**
```dart
final TextEditingController _controller = TextEditingController();
final FocusNode _focusNode = FocusNode(); // New generated field
int _characterCount = 0; // New generated field
```

**Merged:**
```dart
final TextEditingController _controller = TextEditingController(); // P1 version
bool _isLoading = false; // From P1
String? _errorMessage; // From P1
final FocusNode _focusNode = FocusNode(); // From P2
int _characterCount = 0; // From P2
```

### Methods

**initState() - P1 wins:**

P1 version with custom initialization is preserved, even though P2 has a basic version.

**dispose() - P1 wins:**

P1's custom cleanup logic is preserved. Note: P2's cleanup for `_focusNode` would need manual integration.

**build() - P1 wins:**

P1's heavily customized UI with error handling, loading states, and custom submit button is preserved.

**_updateCharacterCount() - P2 added:**

This new method from P2 is added since it doesn't exist in P1.

## Understanding the Merge

The merge follows the **"User Wins"** principle:

1. **P1 (User) Priority:** When the same entity exists in both files, P1's version is used
2. **P2 Additions:** New entities from P2 that don't exist in P1 are added
3. **Complete Preservation:** User's custom logic, error handling, and UI modifications are fully preserved

## Use Case Demonstration

This example simulates a real-world scenario:

1. **Day 1:** Developer creates a Flutter screen with basic functionality (like P2)
2. **Day 2-5:** Developer adds custom features:
   - Loading states
   - Error handling
   - Custom data fetching
   - Form validation
   - Custom UI elements
3. **Day 6:** Code generator runs again and adds new features:
   - Focus management
   - Character counting
4. **Merge:** Developer uses this tool to merge, preserving all custom work while incorporating new generated features

## Modifying the Example

Feel free to modify the example files to test different scenarios:

### Add a new field to P1:
```dart
// In current_file.dart
int _userCounter = 0;
```

Run merge → Field appears in output

### Add a new method to P2:
```dart
// In generated_file.dart
void _newGeneratedMethod() {
  print('New feature');
}
```

Run merge → Method appears in output

### Modify an existing method differently in both:
```dart
// P1: initState has custom logic
@override
void initState() {
  super.initState();
  _loadData();
}

// P2: initState has different logic
@override
void initState() {
  super.initState();
  _initialize();
}
```

Run merge → P1 version wins

## Validation

After running the merge, validate:

1. **Syntax:** `dart analyze example/merged_output.dart`
2. **Formatting:** `dart format example/merged_output.dart`
3. **Manual Review:** Check that all your custom logic is present

## Clean Up

To reset and run again:

```bash
# Remove the output
rm example/merged_output.dart

# Run the merge again
./run_example.sh
```

---

**Tip:** Try modifying `current_file.dart` with your own customizations, then run the merge to see how your changes are preserved!

