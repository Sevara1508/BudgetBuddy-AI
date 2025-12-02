import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Using exchangerate-api.com - free, no API key needed
  static const String baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  // Get conversion rate between two currencies
  Future<double> getConversionRate(String fromCurrency, String toCurrency) async {
    try {
      final url = Uri.parse('$baseUrl/$fromCurrency');
      print('Fetching: $url'); // Debug log

      final response = await http.get(url);
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];

        if (rates.containsKey(toCurrency)) {
          return rates[toCurrency].toDouble();
        } else {
          throw Exception('Currency $toCurrency not found');
        }
      } else {
        throw Exception('Failed to load conversion rate: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR in getConversionRate: $e'); // Debug log
      throw Exception('Error fetching conversion rate: $e');
    }
  }

  // Convert amount from one currency to another
  Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    try {
      final rate = await getConversionRate(fromCurrency, toCurrency);
      return amount * rate;
    } catch (e) {
      print('Currency conversion error: $e');
      rethrow;
    }
  }

  // Get list of available currencies
  Future<List<String>> getAvailableCurrencies() async {
    try {
      final url = Uri.parse('$baseUrl/USD');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.keys.toList()..sort();
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      throw Exception('Error fetching currencies: $e');
    }
  }

  // Get popular currencies (you can customize this list)
  List<String> getPopularCurrencies() {
    return [
      'USD', // US Dollar
      'CAD', // Canadian Dollar
      'EUR', // Euro
      'GBP', // British Pound
      'JPY', // Japanese Yen
      'AUD', // Australian Dollar
      'CHF', // Swiss Franc
      'CNY', // Chinese Yuan
      'INR', // Indian Rupee
      'MXN', // Mexican Peso
    ];
  }
}