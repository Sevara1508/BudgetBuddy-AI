import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_screen.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init db
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // load saved theme
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool("darkMode") ?? false;

  runApp(MyApp(isDarkMode: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
    SharedPreferences.getInstance().then((prefs) {
      final lang = prefs.getString("language") ?? "en";
      setState(() {
        _locale = Locale(lang);
      });
    });
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);

    setState(() {
      _darkMode = value;
    });
  }

  void onChangeLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(()
    {
      if (_locale.languageCode == 'en') {
        _locale = const Locale('fr');
        prefs.setString("language", "fr");
      }
      else
      {
        _locale = const Locale('en');
        prefs.setString("language", "en");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Buddy',
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),

      locale: _locale,
      supportedLocales: const [
        Locale("en"),
        Locale("fr"),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: Home_Screen(
        title: 'Budget Buddy Home Page',
        onToggleTheme: toggleTheme, // pass function to child
        onChangeLanguage: onChangeLanguage,
        isDarkMode: _darkMode,
      ),
    );
  }
}