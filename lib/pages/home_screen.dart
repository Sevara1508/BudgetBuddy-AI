import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/models/transaction_model.dart';
import '/services/db_helper.dart';
import 'transaction_screen.dart'; // import your screen here

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key, required this.title});
  final String title;

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();


  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadTransact();
  }

  Future<void> _initializeNotifications() async {
    const LinuxInitializationSettings linuxInitSettings = LinuxInitializationSettings(defaultActionName: "Open");

    const InitializationSettings initSettings = InitializationSettings(
      linux: linuxInitSettings
      );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showTransactionsNotification() async {
    if (_transactions.isEmpty) return null;
    final latest = _transactions.last;

    await _notificationsPlugin.show(
      0,
      "New Transaction Added",
      "${latest.category}: \$${latest.amount.toStringAsFixed(2)}",
      NotificationDetails(
        android: AndroidNotificationDetails(
          "transactions",
          "Transactions"
          )
      )
      );
  }


  // Method to initialize and create the database
  Future<void> _loadTransact() async {
    // Getting the path to store the database file
    var transactions = await _dbHelper.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .onInverseSurface,
        title: Text(widget.title), //this can be image, icon or multiline text
      ),
      body: Container(
        height: 100, // Limiting the height to make it look like a row
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Scroll horizontally
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
                    //for category
                    Text(t.note ?? ''),
                    //outputs the note from db
                    Text('\$${t.amount.toStringAsFixed(2)}'),
                    //for price with two decimals
                  ],
                ),
              ),
            );
          },
        ),
      ),
      //inspired from lecture code
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
        child: const Icon(Icons.pages), //add icon for navigating to another page
      ),
    );
  }
}
