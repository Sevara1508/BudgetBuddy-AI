import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/budget_service.dart';
import '../services/db_helper.dart';
import '../models/transaction_model.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';

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
  // db + data
  final DBHelper _dbHelper = DBHelper();
  List<TransactionModel> _transactions = [];

  // weekly budget service
  final BudgetService _budgetService = BudgetService();
  double weeklyBudget = 0.0;

  // notification system
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadData();
  }

  // load transactions + weekly budget
  Future<void> _loadData() async {
    final trans = await _dbHelper.getTransactions();
    final budget = await _budgetService.getWeeklyBudget();

    setState(() {
      _transactions = trans;
      weeklyBudget = budget;
    });
  }

  // notification setup
  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: "Open");

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: ios,
      linux: linux,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // popup notification for new transactions
  Future<void> _showTransactionNotification() async {
    if (_transactions.isEmpty) return;

    final latest = _transactions.last;

    await _notificationsPlugin.show(
      0,
      "New Transaction Added",
      "${latest.category}: \$${latest.amount.toStringAsFixed(2)}",
      const NotificationDetails(
        android: AndroidNotificationDetails("transactions", "Transactions"),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  // calculate total weekly expenses
  double get totalExpenses {
    return _transactions.fold(
      0.0,
          (prev, item) => prev + item.amount,
    );
  }

  // calculate remaining money
  double get remainingBudget {
    if (weeklyBudget == 0) return 0;
    return (weeklyBudget - totalExpenses).clamp(0, weeklyBudget);
  }

  // calculate progress bar value
  double get progress {
    if (weeklyBudget == 0) return 0;
    return (totalExpenses / weeklyBudget).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
              ).then((_) => _loadData()); // refresh budget if changed
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // headline
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // card showing weekly summary
            _buildSummaryCard(isDark),

            const SizedBox(height: 30),

            Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            _buildRecentTransactions(isDark),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const Transaction_Screen(title: 'Transactions'),
            ),
          );

          await _loadData();
          await _showTransactionNotification();
        },
      ),
    );
  }

  // dashboard summary card
  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E2A3A)
            : const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          // expenses + budget numbers
          Text(
            "Total Expenses: \$${totalExpenses.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weeklyBudget == 0
                ? "Weekly Budget: Not Set"
                : "Weekly Budget: \$${weeklyBudget.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          if (weeklyBudget != 0)
            Text(
              "Remaining: \$${remainingBudget.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                color: remainingBudget < weeklyBudget * 0.3
                    ? Colors.redAccent
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),

          const SizedBox(height: 20),

          // progress bar
          if (weeklyBudget != 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor:
                isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation(
                  progress > 0.9
                      ? Colors.red
                      : (progress > 0.6 ? Colors.orange : Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // recent transactions section
  Widget _buildRecentTransactions(bool isDark) {
    if (_transactions.isEmpty) {
      return Text(
        "No transactions yet.",
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      );
    }

    return Column(
      children: _transactions.take(5).map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF3B2F4A)
                : const Color(0xFFEDE7F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(t.note ?? ""),
                ],
              ),
              Text(
                "\$${t.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
