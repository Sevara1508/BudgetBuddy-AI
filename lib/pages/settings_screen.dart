import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/budget_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final void Function() onChangeLanguage;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool darkMode;
  bool notifications = true;
  bool tips = true;
  bool weeklySummary = true;

  double weeklyBudget = 0.0; // new

  final SettingsService _service = SettingsService();
  final BudgetService _budgetService = BudgetService(); // new

  @override
  void initState() {
    super.initState();
    darkMode = widget.isDarkMode;
    _loadSettings();
  }

  

  Future<void> _loadSettings() async {
    notifications = await _service.getNotificationsEnabled();
    tips = await _service.getTipsEnabled();
    weeklySummary = await _service.getWeeklySummaryEnabled();
    weeklyBudget = await _budgetService.getWeeklyBudget(); // new

    setState(() {});
  }

  // helper to edit weekly budget
  Future<void> _editWeeklyBudget() async {
    final controller = TextEditingController(
      text: weeklyBudget == 0 ? "" : weeklyBudget.toString(),
    );

    double? result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Weekly Budget"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount (e.g. 150.00)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, double.tryParse(controller.text) ?? 0.0);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _budgetService.setWeeklyBudget(result);
      setState(() => weeklyBudget = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // dark mode
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
              widget.onToggleTheme(value);
            },
          ),

          ListTile(
            title: Text(AppLocalizations.of(context)!.changeLanguage),
            trailing: const Icon(Icons.language),
            onTap: widget.onChangeLanguage,
          ),

          const Divider(),

          // notifications
          SwitchListTile(
            title: const Text("Notifications"),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
              _service.setNotificationsEnabled(value);
            },
          ),

          // ai tips
          SwitchListTile(
            title: const Text("Daily Tips (AI)"),
            value: tips,
            onChanged: (value) {
              setState(() => tips = value);
              _service.setTipsEnabled(value);
            },
          ),

          // ai weekly summary
          SwitchListTile(
            title: const Text("Weekly Summary (AI)"),
            value: weeklySummary,
            onChanged: (value) {
              setState(() => weeklySummary = value);
              _service.setWeeklySummaryEnabled(value);
            },
          ),

          const Divider(),

          // weekly budget section
          ListTile(
            title: const Text("Weekly Budget"),
            subtitle: Text(
              weeklyBudget == 0
                  ? "Not set"
                  : "\$${weeklyBudget.toStringAsFixed(2)}",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editWeeklyBudget,
            ),
          ),
        ],
      ),
    );
  }
}
