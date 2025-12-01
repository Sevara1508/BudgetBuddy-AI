import 'package:flutter/material.dart';
import '../services/settings_service.dart';


class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool darkMode;
  bool notifications = true;
  bool tips = true;
  bool weeklySummary = true;

  final SettingsService _service = SettingsService();

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
              widget.onToggleTheme(value);
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text("Notifications"),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
              _service.setNotificationsEnabled(value);
            },
          ),

          SwitchListTile(
            title: const Text("Daily Tips (AI)"),
            value: tips,
            onChanged: (value) {
              setState(() => tips = value);
              _service.setTipsEnabled(value);
            },
          ),

          SwitchListTile(
            title: const Text("Weekly Summary (AI)"),
            value: weeklySummary,
            onChanged: (value) {
              setState(() => weeklySummary = value);
              _service.setWeeklySummaryEnabled(value);
            },
          ),
        ],
      ),
    );
  }
}
