// this file is a simple test setup to verify that the sqlite database works
// it inserts, reads, updates, and deletes sample transactions using dbhelper
// used to test storage functionality
/*
import 'services/db_helper.dart';
import 'models/transaction_model.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Platform specfic DB initialization
  if (defaultTargetPlatform == TargetPlatform.linux)
  {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // create an instance of the database helper
  final db = DBHelper();

  // insert a sample transaction into the database
  // this will add one new record into the transactions table
  await db.insertTransaction(TransactionModel(
    amount: 25.5,
    category: 'Food',
    date: '2025-11-04',
    note: 'Lunch',
  ));

  // fetch all transactions from the database
  // this reads every row and returns them as a list of transactionmodel objects
  var list = await db.getTransactions();
  print('Transactions: ${list.map((t) => t.toMap())}');

  // if there are any transactions, update the first one
  // this changes the first transaction’s amount and note
  if (list.isNotEmpty) {
    var first = list.first;
    await db.updateTransaction(TransactionModel(
      id: first.id,
      amount: 30.0, // new amount after update
      category: first.category,
      date: first.date,
      note: 'Updated Lunch',
    ));
  }

  // if there are still transactions, delete the first one
  // this permanently removes that record from the database
  if (list.isNotEmpty) await db.deleteTransaction(list.first.id!);
}
*/

//here is the code to run the app

import 'package:flutter/material.dart';
import 'pages/home_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Budget Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      //The home property defines the default screen (or route) that appears when the app launches.
      // Whatever widget you put here is shown as the first page of the app.
      home: const Home_Screen(title: 'Budget Buddy Home Page'),
    );
  }
// flutter run -d emulator-5554
}