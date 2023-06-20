import 'package:flutter/material.dart';

class BudgetDialog extends StatefulWidget {
  @override
  _BudgetDialogState createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Budget'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a budget amount';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Enter Budget Amount',
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final enteredBudget = double.parse(_budgetController.text);
              Navigator.of(context).pop(enteredBudget);
            }
          },
        ),
      ],
    );
  }
}
