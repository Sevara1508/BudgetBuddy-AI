import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/budget_service.dart';
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
  // tracks dark mode state
  late bool darkMode;

  // tracks notification toggle
  bool notifications = true;

  // tracks which language is currently active
  bool isFrench = false;

  // holds the weekly budget value
  double weeklyBudget = 0.0;

  // services used to load and save settings
  final SettingsService _service = SettingsService();
  final BudgetService _budgetService = BudgetService();

  @override
  void initState() {
    super.initState();

    // initial toggle state comes from parent widget
    darkMode = widget.isDarkMode;

    // load settings stored in shared preferences
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // get saved notification preference
    notifications = await _service.getNotificationsEnabled();

    // get saved weekly budget value
    weeklyBudget = await _budgetService.getWeeklyBudget();

    // detect the language currently active in the app
    final locale = Localizations.localeOf(context).languageCode;

    // this simply checks if french mode is on
    isFrench = locale == 'fr';

    // refreshes ui after loading values
    setState(() {});
  }

  // opens a dialog to edit weekly budget
  Future<void> _editWeeklyBudget() async {
    final t = AppLocalizations.of(context)!;

    // controller for the text field
    final controller = TextEditingController(
      text: weeklyBudget == 0 ? "" : weeklyBudget.toString(),
    );

    // build dialog
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // localized title
          title: Text(t.setWeeklyBudget),

          // numeric input box for weekly budget
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: t.amountExample,
            ),
          ),

          // dialog action buttons
          actions: [
            // cancel button, closes dialog only
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel ?? "Cancel"),
            ),

            // save button, returns the numeric value
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  double.tryParse(controller.text) ?? 0.0,
                );
              },
              child: Text(t.save),
            ),
          ],
        );
      },
    );

    // update value if user provided one
    if (result != null) {
      await _budgetService.setWeeklyBudget(result);
      setState(() => weeklyBudget = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // loads translations for this screen
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // localized page title
        title: Text(t.settings),
      ),

      body: ListView(
        children: [
          // dark mode toggle row
          SwitchListTile(
            // localized text
            title: Text(t.darkMode),

            // current value
            value: darkMode,

            // when switch changes
            onChanged: (value) {
              setState(() => darkMode = value);

              // notify app-level theme change
              widget.onToggleTheme(value);
            },
          ),

          // language toggle row
          SwitchListTile(
            // localized label
            title: Text(t.changeLanguage),

            // shows currently active language
            subtitle: Text(isFrench ? "Français" : "English"),

            // toggle state
            value: isFrench,

            onChanged: (value) {
              // update local state
              setState(() => isFrench = value);

              // tells main.dart to toggle actual locale
              widget.onChangeLanguage();
            },
          ),

          const Divider(),

          // notifications toggle row
          // the label DID NOT show because "notifications" was missing from arb file
          SwitchListTile(
            // localized notifications label
            title: Text(t.notifications),

            // current toggle
            value: notifications,

            // when user toggles notifications
            onChanged: (value) {
              setState(() => notifications = value);

              // saves preference through service
              _service.setNotificationsEnabled(value);
            },
          ),

          const Divider(),

          // weekly budget editable row
          ListTile(
            // localized title
            title: Text(t.weeklyBudget),

            // shows amount or "not set"
            subtitle: Text(
              weeklyBudget == 0
                  ? t.notSet
                  : "\$${weeklyBudget.toStringAsFixed(2)}",
            ),

            // edit icon
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
