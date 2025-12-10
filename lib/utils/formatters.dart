import 'package:intl/intl.dart';

/// Utility class for formatting numbers and currencies
class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
    locale: 'en_NG',
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'en_NG');

  /// Format a number as currency with ₦ symbol
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Format a number with commas (no currency symbol)
  static String formatNumber(double value) {
    return _numberFormat.format(value);
  }

  /// Parse a currency string back to double
  static double parseCurrency(String value) {
    final cleanValue = value.replaceAll('₦', '').replaceAll(',', '').trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }
}
