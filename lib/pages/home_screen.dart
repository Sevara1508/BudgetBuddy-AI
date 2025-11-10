import 'package:flutter/material.dart';
import '/models/transaction_model.dart';
import '/services/db_helper.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key, required this.title});
  final String title;

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransact();
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
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: Text(widget.title), //this can be image, icon or multiline text
      ),
      body: Container(
        height: 100,  // Limiting the height to make it look like a row
        child: ListView.builder(
          scrollDirection: Axis.horizontal,  // Scroll horizontally
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
                  Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)), //for category
                  Text(t.note ?? ''), //outputs the note from db
                  Text('\$${t.amount.toStringAsFixed(2)}'),//for price with two decimals
                ],
              ),
            ),

            );
          },
        ),
      ),
    );
  }
}
