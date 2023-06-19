import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './modals/transaction.dart';

void main()  {
  
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,]
    
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Personal Expenses',
     
          theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Teko',
        textTheme: ThemeData.light().textTheme.copyWith(
          titleMedium: const TextStyle(fontFamily: 'Ubuntu',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          ),
        ), 

        appBarTheme: AppBarTheme(
          toolbarTextStyle: ThemeData.light().textTheme.copyWith(
          titleLarge:const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 48,
            fontWeight: FontWeight.bold,
          )
          ).bodyMedium, titleTextStyle: ThemeData.light().textTheme.copyWith(
          titleLarge:const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 48,
            fontWeight: FontWeight.bold,
          )
          ).titleLarge,
        )

      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  final List<Expenses> _userTransactions = [
   //...........
  ];
  //bool _showChart=false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
  }

  @override
  dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Expenses> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String expTitle, double expAmount, DateTime chosenDate) {
    final newExp = Expenses(
      title: expTitle,
      amount: expAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newExp);
    });
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
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }



List<Widget> _buildPortraitContent(
  MediaQueryData mediaQuerry, 
  AppBar appBar, 
  Widget txListWidget){
  return [Container(
                height: (mediaQuerry.size.height-
                appBar.preferredSize.height-
                mediaQuerry.padding.top)*0.3,
                child: Chart(_recentTransactions)
                ), txListWidget ];

}
  @override
  Widget build(BuildContext context) {
    final mediaQuerry= MediaQuery.of(context);
   final PreferredSizeWidget appBar = AppBar(
        title: const Text('Personal Expenses'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
        ],
      );

      final txListWidget=Container(
              height: (mediaQuerry.size.height-
              appBar.preferredSize.height-
              mediaQuerry.padding.top)*0.7,
              child: TransactionList(_userTransactions, _deleteTransaction));

              final pageBody= SafeArea(
                child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                         ..._buildPortraitContent(
                            mediaQuerry, 
                            appBar as AppBar, 
                            txListWidget),
                        ],
                      ),
                    ),
              );
    return  Scaffold(
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
