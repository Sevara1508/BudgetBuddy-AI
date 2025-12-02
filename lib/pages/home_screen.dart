import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_screen.dart';

import '/models/transaction_model.dart';
import '/services/db_helper.dart';
import 'transaction_screen.dart'; // import your screen here


class Home_Screen extends StatefulWidget {
  final String title;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const Home_Screen({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}


class _Home_ScreenState extends State<Home_Screen> {
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadTransact();
  }

  Future<void> _initializeNotifications() async {
    const DarwinInitializationSettings darwinInit = DarwinInitializationSettings();
    const LinuxInitializationSettings linuxInit = LinuxInitializationSettings(defaultActionName: "Open");

    const InitializationSettings initSettings = InitializationSettings(
      iOS: darwinInit,
      macOS: darwinInit,
      linux: linuxInit,
      android: null,
    );

    await _notificationsPlugin.initialize(initSettings);
  }


  Future<void> _showTransactionsNotification() async {
    if (_transactions.isEmpty) return;
    final latest = _transactions.last;

    await _notificationsPlugin.show(
      0,
      "New Transaction Added",
      "${latest.category}: \$${latest.amount.toStringAsFixed(2)}",
      NotificationDetails(
        android: AndroidNotificationDetails(
          "transactions",
          "Transactions",
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }


  Future<void> _loadTransact() async {
    var transactions = await _dbHelper.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: Text(widget.title),

        //ADDED SETTINGS BUTTON HERE
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final t = _transactions[index];
            return Container(
              width: 500.0,
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.category,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(t.note ?? ''),
                    Text('\$${t.amount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const Transaction_Screen(title: 'Transactions'),
            ),
          );
          _loadTransact();
          _showTransactionsNotification();
        },
        child: const Icon(Icons.pages),
      ),
    );
  }
}
