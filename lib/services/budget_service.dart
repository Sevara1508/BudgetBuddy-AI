import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String weeklyBudgetKey = "weekly_budget"; // key used to store the weekly budget value

  Future<double> getWeeklyBudget() async {
    final prefs = await SharedPreferences.getInstance(); // load local storage
    return prefs.getDouble(weeklyBudgetKey) ?? 0.0;       // return saved budget or 0 if nothing saved yet
  }

  Future<void> setWeeklyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance(); // access shared prefs
    await prefs.setDouble(weeklyBudgetKey, amount);      // save the given budget value
  }
}
