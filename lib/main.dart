import 'package:budget_tracker/providers/auth.dart';
import 'package:budget_tracker/providers/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './screens/homepage.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Expenses>(
  create: (_) => Expenses('', '', []),
  update: (ctx, auth, previousProducts) => Expenses(
    auth.token ?? '',
    auth.userId ?? '',
    previousProducts == null
      ? []
      : previousProducts.payments,
  ),
)

      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              //builders: {
               // TargetPlatform.android: CustomPageTransitionBuilder(),
                //TargetPlatform.iOS: CustomPageTransitionBuilder(),
              //},
            ),
            colorScheme:
                ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                    .copyWith(secondary: Colors.deepOrange),
          ),
          home: auth.isAuth
              ? MyHomePage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) {
                    if (authResultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SplashScreen();
                    } else if (authResultSnapshot.hasError) {
                      return Center(
                        child: Text('An error occurred.'),
                      );
                    } else {
                      return AuthScreen();
                    }
                  },
                ),
                routes: {
                  //MyHomePage.routeName:(ctx)=>MyHomePage(),
                  AuthScreen.routeName:(ctx)=> AuthCard(),
                },
        ),
      ),
    );
  }
}