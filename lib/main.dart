import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_screen.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // ensures flutter bindings are ready before running async code
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the ffi version of sqflite (required for desktop platforms)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // load saved theme preference from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool("darkMode") ?? false;

  // start the app with the saved theme state
  runApp(MyApp(isDarkMode: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  // receives the saved theme state from main()
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // holds the current dark/light theme state
  late bool _darkMode;

  // holds the current language for the whole app
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();

    // initialize theme using the value passed from main()
    _darkMode = widget.isDarkMode;

    // load saved language preference from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      final lang = prefs.getString("language") ?? "en";

      // update the locale to match the saved language
      setState(() {
        _locale = Locale(lang);
      });
    });
  }

  // toggles between dark and light mode
  // also stores the selected mode in shared preferences
  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);

    setState(() {
      _darkMode = value;
    });
  }

  // switches the app language between english and french
  // and saves the choice in shared preferences
  void onChangeLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_locale.languageCode == 'en') {
        // switch to french
        _locale = const Locale('fr');
        prefs.setString("language", "fr");
      } else {
        // switch to english
        _locale = const Locale('en');
        prefs.setString("language", "en");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // app title seen on window title bars
      title: 'Budget Buddy',

      // theme settings for the entire app
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),

      // sets the active language
      locale: _locale,

      // defines which languages the app supports
      supportedLocales: const [
        Locale("en"),
        Locale("fr"),
      ],

      // declares the localization delegates needed for translations
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // root screen of the app
      // passes theme + language callbacks to the home screen
      home: Home_Screen(
        isDarkMode: _darkMode,
        onToggleTheme: toggleTheme,
        onChangeLanguage: onChangeLanguage,
      ),
    );
  }
}