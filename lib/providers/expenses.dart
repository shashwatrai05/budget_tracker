import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../exceptions.dart/http_exception.dart';
import 'transaction.dart';
import 'package:flutter/foundation.dart';

class Expenses with ChangeNotifier {
  double _budget = 0.0;
  List<Expense> _userTransactions = [];

  final String authTokens;
  final String userId;
  Expenses(this.authTokens, this.userId, this._userTransactions);

  double get budget => _budget;
  List<Expense> get payments => [..._userTransactions];

  Expense findById(String id) {
    return _userTransactions.firstWhere((trax) => trax.id == id);
  }

  Future<void> fetchAndSetExpenses() async {
  //final authTokens = '...'; // Your authentication tokens

  var url =
      'https://budget-tracker-2418e-default-rtdb.firebaseio.com/expenses.json?$authTokens';

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }

    extractedData.forEach((txnId, txnData) {
      _userTransactions.add(Expense(
        id: txnId,
        title: txnData['title'],
        amount: txnData['amount'],
        date: DateTime.parse(txnData['date']),
      ));
    });
    notifyListeners();
  } catch (error) {
    print('Error fetching expenses: $error');
  }
}




  Future<void> addExpense(Expense expense) async {
    final url =
        'https://budget-tracker-2418e-default-rtdb.firebaseio.com/expenses.json?auth=$authTokens';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': expense.title,
          'amount': expense.amount,
          'date': expense.date.toIso8601String(),
          'creatorId': userId,
        }),
      );
      final newExpense = Expense(
        id: json.decode(response.body)['name'],
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
      );
      _userTransactions.add(newExpense);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteExpense(String id) async {
    final url =
        'https://budget-tracker-2418e-default-rtdb.firebaseio.com/expenses/$id.json?auth=$authTokens';
    final existingExpenseIndex =
        _userTransactions.indexWhere((prod) => prod.id == id);
    var existingExpense = _userTransactions[existingExpenseIndex];
    _userTransactions.removeAt(existingExpenseIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _userTransactions.insert(existingExpenseIndex, existingExpense);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
  }

  Future<void> setBudget(double budget) async {
   final url =
        'https://budget-tracker-2418e-default-rtdb.firebaseio.com/budget.json?auth=$authTokens';
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(budget),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Could not set budget');
      }
      _budget = budget;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetBudget() async {
    final url =
        'https://budget-tracker-2418e-default-rtdb.firebaseio.com/budget.json?auth=$authTokens';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);
      if (extractedData != null) {
        _budget = extractedData as double;
        notifyListeners();
      }
    } catch (error) {
      throw (error);
    }
  }
}
