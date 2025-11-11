import 'package:flutter/material.dart';
import '/models/transaction_model.dart';
import '/services/db_helper.dart';

class Transaction_Screen extends StatefulWidget {
  const Transaction_Screen({super.key, required this.title});
  final String title;

  @override
  State<Transaction_Screen> createState() => _Transaction_ScreenState();
}

class _Transaction_ScreenState extends State<Transaction_Screen> {
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransact();
  }

  Future<void> _loadTransact() async {
    final transactions = await _dbHelper.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _addTransaction() async {
    final category = _categoryController.text.trim();
    final note = _noteController.text.trim();
    final amountText = _amountController.text.trim();

    if (category.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText) ?? 0.0;

    final newTransaction = TransactionModel(
      category: category,
      date: DateTime.now().toString(),
      note: note,
      amount: amount,
    );

    await _dbHelper.insertTransaction(newTransaction);

    _categoryController.clear();
    _noteController.clear();
    _amountController.clear();

    _loadTransact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a New Transaction',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              //code for each input type
              const SizedBox(height: 10),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              //button to save transaction
              ElevatedButton(
                onPressed: _addTransaction,
                child: const Text('Save Transaction'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                'All Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              //code for the saved transactions
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  var inp = _transactions[index];
                  return Card(
                    color: Colors.lightBlueAccent,
                    child: ListTile(
                      title: Text(
                        inp.category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(inp.note ?? ''),
                      trailing: Text('\$${inp.amount.toStringAsFixed(2)}'), //displays amount in decimal
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
