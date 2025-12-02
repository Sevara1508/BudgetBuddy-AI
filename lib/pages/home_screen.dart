import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// services for storage and logic
import '../services/budget_service.dart';
import '../services/db_helper.dart';

// model for transaction entries
import '../models/transaction_model.dart';

// app pages
import 'transaction_screen.dart';
import 'settings_screen.dart';
import 'currency_converter_screen.dart';
import '../l10n/app_localizations.dart';
import 'analytics_screen.dart';

class Home_Screen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final VoidCallback onChangeLanguage;

  // constructor receives theme + language callbacks from main.dart
  const Home_Screen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  // db helper handles all sqlite reads/writes
  final DBHelper _dbHelper = DBHelper();

  // list of all saved transactions
  List<TransactionModel> _transactions = [];

  // service used to read / write weekly budget
  final BudgetService _budgetService = BudgetService();
  double weeklyBudget = 0.0;

  // notifications handler for popup alerts
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // initializes notification channels
    _initializeNotifications();

    // loads stored transactions + stored weekly budget
    _loadData();
  }

  // loads all transactions + weekly budget from sqlite
  Future<void> _loadData() async {
    final trans = await _dbHelper.getTransactions();
    final budget = await _budgetService.getWeeklyBudget();

    // update local state so ui reflects database values
    setState(() {
      _transactions = trans;
      weeklyBudget = budget;
    });
  }

  // sets up notification channels for android, ios, macos, linux
  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: "Open");

    // default initialization for all platforms
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: ios,
      linux: linux,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // shows popup when a new transaction is added
  Future<void> _showTransactionNotification() async {
    // nothing to show if user has no transactions
    if (_transactions.isEmpty) return;

    // get the most recent transaction
    final latest = _transactions.last;

    await _notificationsPlugin.show(
      0,
      AppLocalizations.of(context)!.homeTitle,
      "${latest.category}: \$${latest.amount.toStringAsFixed(2)}",
      const NotificationDetails(
        android: AndroidNotificationDetails("transactions", "Transactions"),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  // calculates total amount spent
  double get totalExpenses =>
      _transactions.fold(0.0, (sum, t) => sum + t.amount);

  // calculates remaining weekly budget
  double get remainingBudget {
    if (weeklyBudget == 0) return 0;
    return (weeklyBudget - totalExpenses).clamp(0, weeklyBudget);
  }

  // calculates percentage used for progress bar
  double get progress {
    if (weeklyBudget == 0) return 0;
    return (totalExpenses / weeklyBudget).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // localized strings
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // top bar with title and icons
      appBar: AppBar(
        title: Text(t.homeTitle),
        actions: [
          // currency converter button
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencyConverterScreen(),
                ),
              );
            },
            tooltip: t.currencyConverter,
          ),

          // settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                    onChangeLanguage: widget.onChangeLanguage,
                  ),
                ),
              ).then((_) => _loadData()); // reload after returning
            },
            tooltip: t.settings,
          ),

          // analytics button
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsScreen(title: t.dashboard),
                ),
              );
            },
            tooltip: "analytics",
          ),
        ],
      ),

      // main scroll area
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // big dashboard title
            Text(
              t.dashboard,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // weekly summary card
            _buildSummaryCard(isDark, t),

            const SizedBox(height: 30),

            // recent transactions section title
            Text(
              t.recentTransactions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            // recent transactions list
            _buildRecentTransactions(isDark, t),
          ],
        ),
      ),

      // new transaction button
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // open transaction input page
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Transaction_Screen(title: t.transaction),
            ),
          );

          // reload data after returning
          await _loadData();

          // notify the user
          await _showTransactionNotification();
        },
      ),
    );
  }

  // weekly summary box
  Widget _buildSummaryCard(bool isDark, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // background color depends on theme
        color: isDark
            ? const Color(0xFF2E2A3A)
            : const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header label
          Text(
            t.weeklyOverview,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 15),

          // total expenses
          Text(
            "${t.totalExpenses}: \$${totalExpenses.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // weekly budget amount
          Text(
            weeklyBudget == 0
                ? "${t.weeklyBudget}: ${t.notSet}"
                : "${t.weeklyBudget}: \$${weeklyBudget.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // remaining money
          if (weeklyBudget != 0)
            Text(
              "${t.remaining}: \$${remainingBudget.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                color: remainingBudget < weeklyBudget * 0.3
                    ? Colors.redAccent
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),

          const SizedBox(height: 20),

          // progress bar for spending
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

  // recent transactions builder
  Widget _buildRecentTransactions(bool isDark, AppLocalizations t) {
    // empty state message
    if (_transactions.isEmpty) {
      return Text(
        t.noTransactions,
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      );
    }

    // show up to 5 most recent transactions
    return Column(
      children: _transactions.reversed.take(5).map((tr) {
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
              // left side: category + note
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(tr.note ?? ""),
                ],
              ),

              // right side: amount
              Text(
                "\$${tr.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
