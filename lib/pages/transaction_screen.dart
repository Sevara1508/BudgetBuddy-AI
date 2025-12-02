import 'package:flutter/material.dart';
import '/models/transaction_model.dart';
import '/services/db_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class Transaction_Screen extends StatefulWidget {
  const Transaction_Screen({super.key, required this.title});
  final String title;

  @override
  State<Transaction_Screen> createState() => _Transaction_ScreenState();
}

class _Transaction_ScreenState extends State<Transaction_Screen> {
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  final TextEditingController _noteController = TextEditingController();

  String? _selectCategory; //in order to select category from picker
  DateTime? _selectDate; // in order to select date from picker
  double? _enterAmount; // in order to store amount entered from dialog

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
    final note = _noteController.text.trim();
    // using selected values from pickers and dialog
    final category = _selectCategory;
    final amount = _enterAmount ?? 0.0;
    final date = _selectDate ?? DateTime.now();

    // if category or amount is invalid, do nothing
    if (category == null || category.isEmpty || amount <= 0) return;

    final newTransaction = TransactionModel(
      category: category,
      date: date.toString(), // user can select an actual date instead of saving current date
      note: note,
      amount: amount,
    );

    try {
      await _dbHelper.insertTransaction(newTransaction);

      _noteController.clear(); // only clear note field

      // reset the selected values
      setState(() {
        _selectCategory = null;
        _enterAmount = null;
        _selectDate = null;
      });

      _loadTransact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.transactionAdded),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.transactionFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // create function to deletes a transaction
  Future<void> _deleteTransaction(int? id) async {
    if (id == null) return;

    await _dbHelper.deleteTransaction(id);
    await _loadTransact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.transactionDeleted), // notif
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        final List<String> _categories = [
      AppLocalizations.of(context)!.food,
      AppLocalizations.of(context)!.shopping,
      AppLocalizations.of(context)!.utilities,
      AppLocalizations.of(context)!.transportation,
      AppLocalizations.of(context)!.other
    ]; // used in category picker

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
              Text(
                AppLocalizations.of(context)!.addNewTransaction,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              //code for each input type (changed to pickers and dialog)
              const SizedBox(height: 10),

              // create category picker using dropdown
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.category}: '),
                  DropdownButton<String>(
                    value: _selectCategory,
                    hint: Text(AppLocalizations.of(context)!.select),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectCategory = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // create date picker
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.date}: '),
                  TextButton(
                    onPressed: () async {
                      final chosenDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2004),
                        lastDate: DateTime(2100),
                      );
                      if (chosenDate != null) {
                        setState(() {
                          _selectDate = chosenDate;
                        });
                      }
                    },
                    child: Text(
                      _selectDate == null
                          ? AppLocalizations.of(context)!.selectDate
                          : _selectDate!.toString().split(' ')[0],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // keep note so user can enter in any text
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.note,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.amount}: '),
                  TextButton(
                    onPressed: () async {
                      final controller = TextEditingController();

                      final result = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('${AppLocalizations.of(context)!.enterAmount} '),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration:
                              InputDecoration(labelText: AppLocalizations.of(context)!.amount),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    double.tryParse(controller.text) ?? 0.0,
                                  );
                                },
                                child: Text(AppLocalizations.of(context)!.save), // display "Save" button
                              ),
                            ],
                          );
                        },
                      );

                      if (result != null) {
                        setState(() {
                          _enterAmount = result;
                        });
                      }
                    },
                    child: Text(
                      _enterAmount == null
                          ? AppLocalizations.of(context)!.enterAmount
                          : '\$${_enterAmount!.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _addTransaction,
                child: Text(AppLocalizations.of(context)!.saveTransaction),
              ),

              const SizedBox(height: 20),
              const Divider(),
              Text(
                AppLocalizations.of(context)!.allTransactions,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  var inp = _transactions[index];
                  return Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3B2F4A)
                        : const Color(0xFFEDE7F6),
                    child: ListTile(
                      title: Text(
                        inp.category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(inp.note ?? ''),

                      // updated to also delete transaction
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${inp.amount.toStringAsFixed(2)}'), //displays amount in decimal
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteTransaction(inp.id);
                            },
                          ),
                        ],
                      ),
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