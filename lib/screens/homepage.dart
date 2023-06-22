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
  static const routeName= '/';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _budget = 0.0;

  List<Expense> _extractedTransactions = [];

  List<Expense> get _recentTransactions {
    return _extractedTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  Future<void> _fetchAndSetTransactions() async {
    try {
      await Provider.of<Expenses>(context, listen: false).fetchAndSetExpenses();
      final expenses = Provider.of<Expenses>(context, listen: false).payments;
      setState(() {
        _extractedTransactions = expenses;
      });
    } catch (error) {
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

  void _addNewTransaction(
      String expTitle, double expAmount, DateTime chosenDate) {
    final newExp = Expense(
      title: expTitle,
      amount: expAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    Provider.of<Expenses>(context, listen: false).addExpense(newExp);
  }

  void _startAddNewTransaction(BuildContext ctx) {
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
    Provider.of<Expenses>(context, listen: false).deleteExpense(id);
  }

  Future<void> _fetchAndSetBudget() async {
    try {
      await Provider.of<Expenses>(context, listen: false).fetchAndSetBudget();
      final budget = Provider.of<Expenses>(context, listen: false).budget;
      setState(() {
        _budget = budget;
      });
    } catch (error) {
      // Handle error
    }
  }

  List<Widget> _buildPortraitContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Container(
        height:
            (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *
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
    await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => AuthScreen()));
  },
  icon: Icon(Icons.exit_to_app),
)



      ],
    );

    final txListWidget = Consumer<Expenses>(
      builder: (ctx, expenses, _) {
        return Container(
          height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) *
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
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
