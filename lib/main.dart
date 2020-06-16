import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keeping_track/pages/dayValuesSettings.dart';
import 'package:keeping_track/pages/loading.dart';
import 'package:keeping_track/pages/days.dart';
import 'package:keeping_track/pages/login.dart';
import 'package:keeping_track/pages/day.dart';
import 'package:keeping_track/pages/settings.dart';
import 'package:keeping_track/pages/about.dart';
import 'package:keeping_track/services/sign_in.dart';
import 'package:keeping_track/services/themeModeHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  
  
  runZoned(() {
    runApp(App());
  }, onError: Crashlytics.instance.recordError);

}

class App extends StatefulWidget {

  _AppState myAppState= new _AppState();
  @override
  _AppState createState() => myAppState;

}

class _AppState extends State<App> {

  String uid;
  bool authSignedIn;
  bool darkTheme = false;
  bool lightTheme = false;
  

  @override
  void initState() {
    super.initState();
    getUserInfo();
    
  }

  Future getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lightTheme = prefs.getBool('lightTheme') ?? false;
    darkTheme = prefs.getBool('darkTheme') ?? false;
  }

  Future getUserInfo() async {
    Map userInfo = await getUserAuthInfo();
    uid = userInfo['uid'];
    authSignedIn = userInfo['authSignedIn'];
    setState(() {});
  }

  void setLightTheme() async {
    darkTheme = false;
    lightTheme = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('lightTheme', lightTheme);
    prefs.setBool('lightTheme', darkTheme);
    //setState(() {});
  }

  void setDarkTheme() async {
    lightTheme = false;
    darkTheme = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('lightTheme', lightTheme);
    prefs.setBool('lightTheme', darkTheme);
    //setState(() {});
  }

  
  @override
  Widget build(BuildContext context) {

    return ThemeModeHandler(
      manager: ThemeModeManager(),
      builder: (ThemeMode themeMode) {
        return MaterialApp(
          title: 'Keeping track',
          theme: ThemeData.light().copyWith(
            primaryColor: Color.fromARGB(255, 56, 113, 229),
            accentColor: Color.fromARGB(255, 56, 113, 229),
            cardColor: Colors.white,
            scaffoldBackgroundColor: Colors.grey[200],
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            primaryColor: Color.fromARGB(255, 56, 113, 229),
            accentColor: Color.fromARGB(255, 56, 113, 229),
          ),
          themeMode: themeMode,
          home: (uid != null && authSignedIn != false) ? LoadingPage() : LoginPage(),
          routes: {
            '/login': (context) => LoginPage(),
            '/loading': (context) => LoadingPage(),
            '/days': (context) => DaysPage(),
            '/day': (context) => DayPage(),
            '/settings': (context) => SettingsPage(),
            '/dayValuesSettings': (context) => DayValuesSettingsPage(),
            '/about': (context) => AboutPage(),
          }
        );
      }
    );
  }
}