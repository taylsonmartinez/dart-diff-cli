// Example P2: Newly generated file with structural updates

import 'package:flutter/material.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // Generated basic field
  final TextEditingController _controller = TextEditingController();
  
  // NEW: Generated added this new field
  final FocusNode _focusNode = FocusNode();
  
  // NEW: Generated added this new field
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    // Basic generated initialization
  }

  @override
  void dispose() {
    _controller.dispose();
    // NEW: Generated added cleanup for new field
    _focusNode.dispose();
    super.dispose();
  }

  // NEW: Generated added this method
  void _updateCharacterCount() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  // Basic generated build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _updateCharacterCount(),
            ),
            const SizedBox(height: 8),
            // NEW: Generated added character counter
            Text('Characters: $_characterCount'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

