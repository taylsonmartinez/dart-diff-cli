// Example P1: User-modified file with custom logic

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // User added this import

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // User-modified field with custom initialization
  final TextEditingController _controller = TextEditingController();
  
  // User-added field
  bool _isLoading = false;
  
  // User-added custom field
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // User added custom initialization
    _controller.addListener(_onTextChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    // User added custom cleanup
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  // User added this custom method
  void _onTextChanged() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  // User added this custom method
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      // Load data logic here
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // User heavily modified the build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Custom Screen'),
        // User added custom action
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User added custom error display
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter your text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }

  // User added this custom method
  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some text';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate form submission
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
        _controller.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Submission failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

