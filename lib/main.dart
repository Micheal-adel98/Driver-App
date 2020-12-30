import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutterapp/ui/signin.dart';
import 'package:flutterapp/ui/splashscreen.dart';
import 'package:provider/provider.dart';

import 'constants/constants.dart';
import 'enum/connectivity_status.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      theme: ThemeData(primaryColor: Colors.blue[200]),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) =>  SplashScreen(),
        SIGN_IN: (BuildContext context) =>  SignInPage(),

      },
      initialRoute: SPLASH_SCREEN,
    );

  }



}




