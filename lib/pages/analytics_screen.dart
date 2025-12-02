import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.title});
  final String title;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // example transactions
  final List<Transaction> _transactions = [
    Transaction(category: 'Food', note: 'Lunch', amount: 12.50),
    Transaction(category: 'Transport', note: 'Bus', amount: 2.75),
    Transaction(category: 'Shopping', note: 'T-shirt', amount: 24.99),
    Transaction(category: 'Entertainment', note: 'Movie', amount: 15.00),
  ];

  double get totalExpenses => _transactions.fold(0, (sum, t) => sum + t.amount);

  double get totalInc => 5000;
  //calculate the total balance
  double get balance => totalInc - totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryCard('Income', totalInc, Colors.blue),
                _summaryCard('Expenses', totalExpenses, Colors.blue),
                _summaryCard('Balance', balance, Colors.blue),
              ],
            ),

            const SizedBox(height: 50),

            // bars to track progress (expenses/income and balance/income)
            _progressBar('Expenses % of Income', totalExpenses / totalInc, Colors.red),
            const SizedBox(height: 20),
            _progressBar('Balance % of Income', balance / totalInc, Colors.green),

            const SizedBox(height: 30),

            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // transactions list
            ..._transactions.map((t) => _transactionTile(t)).toList(),
          ],
        ),
      ),
    );
  }

  //cards to display transaction summary
  Widget _summaryCard(String title, double amount, Color color) {
    return Card(
      color: color,
      child: SizedBox(
        width: 110,
        child: ListTile(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)), //for styling
          subtitle: Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  //code to add the bars as an analytic
  Widget _progressBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator( //for the bar add this
            value: percent.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _transactionTile(Transaction t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(t.category),
        subtitle: Text(t.note),
        trailing: Text('\$${t.amount.toStringAsFixed(2)}'),
      ),
    );
  }
}

class Transaction {
  final String category;
  final String note;
  final double amount;

  Transaction({
    required this.category,
    required this.note,
    required this.amount,
  });
}
