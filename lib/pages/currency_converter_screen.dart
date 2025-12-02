import 'package:flutter/material.dart';
import '/services/currency_service.dart';
import '../l10n/app_localizations.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  // service used to call api and perform conversion
  final CurrencyService _currencyService = CurrencyService();

  // controls the user's amount input
  final TextEditingController _amountController = TextEditingController();

  // dropdown selections for currencies
  String _fromCurrency = 'USD';
  String _toCurrency = 'CAD';

  // final conversion result (null means nothing calculated yet)
  double? _convertedAmount;

  // used to show loading state on convert button
  bool _isLoading = false;

  // error text for invalid input or failed api call
  String? _errorMessage;

  // list of supported currencies shown in dropdowns
  List<String> _popularCurrencies = [];

  @override
  void initState() {
    super.initState();

    // get the list of available currencies from the service
    _popularCurrencies = _currencyService.getPopularCurrencies();
  }

  // handles the convert button click
  Future<void> _convertCurrency() async {
    final t = AppLocalizations.of(context)!;

    // reset any old result or error before running new conversion
    setState(() {
      _convertedAmount = null;
      _errorMessage = null;
    });

    // read and validate input
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = t.errorEnterAmount);
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = t.errorValidNumber);
      return;
    }

    // ui goes into loading state
    setState(() => _isLoading = true);

    try {
      // call service to convert using live rates
      final result = await _currencyService.convertCurrency(
        amount,
        _fromCurrency,
        _toCurrency,
      );

      // store converted value and stop loading indicator
      setState(() {
        _convertedAmount = result;
        _isLoading = false;
      });

      // small popup indicating success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.conversionSuccessful),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // set error message and stop loading state
      setState(() {
        _errorMessage = t.conversionFailed;
        _isLoading = false;
      });

      // popup showing failure reason
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.conversionFailed),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // swaps the "from" and "to" currencies
  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;

      // clear old result since currencies changed
      _convertedAmount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      // page title
      appBar: AppBar(
        title: Text(t.currencyConverter),
      ),

      // main scrollable column
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // large headline
            Text(
              t.convertCurrency,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // main conversion card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2E2A3A)
                    : const Color(0xFFF3EFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // amount label
                  Text(
                    t.amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // amount input box
                  TextField(
                    controller: _amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: t.enterAmount,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF3B2F4A)
                          : const Color(0xFFEDE7F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color:
                        isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "from" currency label
                  Text(
                    t.from,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // dropdown for "from"
                  _buildDropdown(isDark, true),

                  const SizedBox(height: 15),

                  // swap currency button
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3B2F4A)
                            : const Color(0xFFEDE7F6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.swap_vert,
                          color:
                          isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: _swapCurrencies,
                        tooltip: t.swapCurrencies,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // "to" currency label
                  Text(
                    t.to,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // dropdown for "to"
                  _buildDropdown(isDark, false),

                  const SizedBox(height: 30),

                  // convert button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _convertCurrency,
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isDark
                            ? Colors.deepPurple
                            : Colors.deepPurple.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        t.convert,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // result card (only shown when successful conversion exists)
            if (_convertedAmount != null) _buildResultCard(isDark, t),

            // error card (only shown when an error message exists)
            if (_errorMessage != null) _buildErrorCard(),

            const SizedBox(height: 20),

            // "about" card explaining what the screen does
            _buildAboutCard(isDark, t),
          ],
        ),
      ),
    );
  }

  // builds both "from" and "to" dropdowns
  Widget _buildDropdown(bool isDark, bool isFrom) {
    final items = _popularCurrencies;
    final value = isFrom ? _fromCurrency : _toCurrency;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
        isDark ? const Color(0xFF3B2F4A) : const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor:
          isDark ? const Color(0xFF3B2F4A) : const Color(0xFFEDE7F6),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          items: items.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (value) {
            // update selected currency and clear old results
            setState(() {
              if (isFrom) {
                _fromCurrency = value!;
              } else {
                _toCurrency = value!;
              }
              _convertedAmount = null;
            });
          },
        ),
      ),
    );
  }

  // displays the final converted value
  Widget _buildResultCard(bool isDark, AppLocalizations t) {
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
          // result label
          Text(
            t.result,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 15),

          // shows "xx USD ="
          Text(
            '${_amountController.text} $_fromCurrency =',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // main converted value
          Text(
            '${_convertedAmount!.toStringAsFixed(2)} $_toCurrency',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // displays conflict or invalid input messages
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // card explaining how the feature works
  Widget _buildAboutCard(bool isDark, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
        isDark ? const Color(0xFF3B2F4A) : const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title row with icon
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                t.about,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                  isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // description text
          Text(
            t.aboutDescription,
            style: TextStyle(
              fontSize: 14,
              color:
              isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // cleanup to prevent memory leaks
    _amountController.dispose();
    super.dispose();
  }
}
