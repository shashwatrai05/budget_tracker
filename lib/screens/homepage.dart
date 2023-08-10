import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/expenses.dart';
import '../widgets/budget_dialag.dart';
import '../widgets/new_transaction.dart';
import '../widgets/transaction_list.dart';
import '../widgets/chart.dart';
import '../providers/transaction.dart';
import 'auth_screen.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _budget = 0.0;
  List<Expense> _extractedTransactions = [];
  bool _isLoading = false;

  List<Expense> get _recentTransactions {
    return _extractedTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  double get _spentAmount {
    double spentAmount = 0.0;
    for (final expense in _extractedTransactions) {
      spentAmount += expense.amount;
    }
    return spentAmount;
  }

  Future<void> _fetchAndSetTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Expenses>(context, listen: false).fetchAndSetExpenses();
      final expenses = Provider.of<Expenses>(context, listen: false).payments;
      setState(() {
        _extractedTransactions = expenses;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _setBudget(BuildContext context) async {
    final enteredBudget = await showDialog<double>(
      context: context,
      builder: (ctx) => BudgetDialog(),
    );

    if (enteredBudget != null) {
      try {
        await Provider.of<Expenses>(context, listen: false)
            .setBudget(enteredBudget);
        setState(() {
          _budget = enteredBudget;
        });
      } catch (error) {
        // Handle error
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetTransactions();
    _fetchAndSetBudget();
  }

  Future<void> _addNewTransaction(String expTitle, double expAmount, DateTime chosenDate) async {
  final newExp = await Expense(
    title: expTitle,
    amount: expAmount,
    date: chosenDate,
    id: DateTime.now().toString(),
  );

  Provider.of<Expenses>(context, listen: false).addExpense(newExp);

  setState(() {
    _extractedTransactions.add(newExp);
  });
}

  _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
  final deletedTransaction = _extractedTransactions.firstWhere((tx) => tx.id == id);
  Provider.of<Expenses>(context, listen: false).deleteExpense(id);

  setState(() {
    _extractedTransactions.removeWhere((tx) => tx.id == id);
  });
}
  Future<void> _fetchAndSetBudget() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Expenses>(context, listen: false).fetchAndSetBudget();
      final budget = Provider.of<Expenses>(context, listen: false).budget;
      setState(() {
        _budget = budget;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  List<Widget> _buildPortraitContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions, _budget),
      ),
      
      txListWidget,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text(
        'My Budget Tracker',
        style: TextStyle(fontSize: 22),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _setBudget(context),
        ),
        IconButton(
          onPressed: () async {
            await Provider.of<Auth>(context, listen: false).logout();
            Navigator.of(context).pop();
            Navigator.of(context).popUntil((route) => route.isFirst);
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => AuthScreen()),
            );
          },
          icon: Icon(Icons.exit_to_app),
        ),
      ],
    );

    final txListWidget = Consumer<Expenses>(
      builder: (ctx, expenses, _) {
        final _extractedTransactions = expenses.payments;
        return Container(
          height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
              0.7,
          child: TransactionList(_extractedTransactions, _deleteTransaction),
        );
      },
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ..._buildPortraitContent(
              mediaQuery,
              appBar,
              txListWidget,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          pageBody,
          Visibility(
            visible: _isLoading,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
