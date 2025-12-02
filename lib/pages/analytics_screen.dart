import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/db_helper.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.title});
  final String title;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // local copy of all saved transactions
  List<TransactionModel> _transactions = [];

  // instance of the database helper
  final DBHelper _db = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load transactions from the database
  Future<void> _loadData() async {
    // fetch all transactions the user added
    final data = await _db.getTransactions();

    // update the state with loaded data
    setState(() {
      _transactions = data;
    });
  }

  // compute total expenses from real database data
  double get totalExpenses {
    return _transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  // fixed income (not stored anywhere so keep static)
  double get totalInc => 5000;

  // calculate remaining balance
  double get balance => totalInc - totalExpenses;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.dashboard),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // summary cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    label: t.income,
                    amount: totalInc,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _summaryCard(
                    label: t.totalExpenses,
                    amount: totalExpenses,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _summaryCard(
                    label: t.remaining,
                    amount: balance,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // expenses/income progress bar
            _progressBar(
              label: "${t.totalExpenses} % ${t.weeklyBudget}",
              percent: totalExpenses / totalInc,
              isDark: isDark,
            ),

            const SizedBox(height: 25),

            // balance/income progress bar
            _progressBar(
              label: "${t.remaining} % ${t.weeklyBudget}",
              percent: balance / totalInc,
              isDark: isDark,
            ),

            const SizedBox(height: 35),

            Text(
              t.recentTransactions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // show message if there are no transactions
            if (_transactions.isEmpty)
              Text(
                t.noTransactions,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),

            // render each real transaction
            ..._transactions.map((t) => _transactionTile(t, isDark)).toList(),
          ],
        ),
      ),
    );
  }

  // summary card widget
  Widget _summaryCard({
    required String label,
    required double amount,
    required bool isDark,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF3B2F4A)
            : const Color(0xFFF0E9FB),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // localized label text
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Amount text
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // progress bar widget
  Widget _progressBar({
    required String label,
    required double percent,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation(
              percent > 0.9
                  ? Colors.red
                  : (percent > 0.6 ? Colors.orange : Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }

  // transaction tile for database transactions
  Widget _transactionTile(TransactionModel t, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF2E2636) : const Color(0xFFF8F3FF),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(
          t.category,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          t.note ?? "",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        trailing: Text(
          "\$${t.amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
