//import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Expense with ChangeNotifier{
  final String id;
  final String title;
  final double amount;
  final DateTime date;

 Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}