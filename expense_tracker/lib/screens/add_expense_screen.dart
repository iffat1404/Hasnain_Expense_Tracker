import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/edit_expense_dialog.dart'; // <-- IMPORT THE NEW DIALOG
import 'package:expense_tracker/services/ai_service.dart';
import 'package:expense_tracker/services/firestore_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _textController = TextEditingController();
  final _aiService = AiService();
  final _firestoreService = FirestoreService();

  bool _isProcessing = false;
  Map<String, dynamic>? _processedData;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processAndAnalyzeExpense() async {
    // ... (This function remains unchanged)
    if (_textController.text.isEmpty) return;
    setState(() {
      _isProcessing = true;
      _processedData = null;
      _error = null;
    });
    final result = await _aiService.processExpenseText(_textController.text);
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      if (result != null) {
        _processedData = result;
      } else {
        _error = 'Could not process the expense. Please try again or check the server.';
      }
    });
  }
  
  // --- NEW METHOD TO SHOW THE EDIT DIALOG ---
  Future<void> _showEditDialog() async {
    if (_processedData == null) return;

    // Show the dialog and wait for it to return data
    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditExpenseDialog(initialData: _processedData!),
    );

    // If the user saved changes, the dialog returns the new data
    if (updatedData != null) {
      setState(() {
        _processedData = updatedData; // Update the UI with the edited data
      });
    }
    // If the user hit "Cancel", updatedData will be null and nothing happens.
  }


  Future<void> _saveConfirmedExpense() async {
    // ... (This function remains unchanged)
    if (_processedData == null) return;
    setState(() => _isProcessing = true);
    await _firestoreService.addExpense(
      _processedData!['item'],
      _processedData!['amount'],
      _processedData!['category'],
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense with AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (The top part for text entry and analysis remains the same)
            const Text(
              'Describe your expense in one sentence:',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'e.g., "Bought a school bag for 500"',
              ),
              onSubmitted: (_) => _processAndAnalyzeExpense(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processAndAnalyzeExpense,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isProcessing && _processedData == null
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Analyze Expense', style: TextStyle(fontSize: 16)),
            ),
            
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
            ],
            
            if (_processedData != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('Please Confirm Analysis', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildResultRow('Item', _processedData!['item'].toString()),
              _buildResultRow('Amount', '₹${_processedData!['amount']}'),
              _buildResultRow('Category', _processedData!['category'].toString()),
              const SizedBox(height: 32),
              
              // --- MODIFIED BUTTON SECTION ---
              Row(
                children: [
                  // Edit Button
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: _showEditDialog,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Confirm Button
                  Expanded(
                    flex: 2, // Make confirm button larger
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm & Save'),
                      onPressed: _isProcessing ? null : _saveConfirmedExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        padding: const EdgeInsets.symmetric(vertical: 14)
                      ),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value) {
    // ... (This helper widget remains unchanged)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}