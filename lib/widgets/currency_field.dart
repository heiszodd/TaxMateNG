import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import 'shake_animation.dart';

/// A custom text field for currency input with formatting
class CurrencyField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? tooltip;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final String? errorText;
  final bool enabled;

  const CurrencyField({
    super.key,
    required this.label,
    this.hint,
    this.tooltip,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<CurrencyField> {
  late TextEditingController _controller;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
    locale: 'en_NG',
  );
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null && widget.initialValue! > 0
          ? _formatNumber(widget.initialValue!)
          : '',
    );
  }

  @override
  void didUpdateWidget(CurrencyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final newText = widget.initialValue != null && widget.initialValue! > 0
          ? _formatNumber(widget.initialValue!)
          : '';
      // Preserve selection/cursor position when updating text
      _controller.value = _controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return _currencyFormat.format(value).replaceAll('₦', '').trim();
  }

  double _parseValue(String text) {
    final cleanText = text.replaceAll(',', '').replaceAll('₦', '').trim();
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _onChanged(String value) {
    final numericValue = _parseValue(value);
    widget.onChanged?.call(numericValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixText: '₦',
            prefixStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
            errorText: widget.errorText,
            filled: true,
            fillColor: isDark ? AppConstants.darkSurface : AppConstants.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: isDark ? AppConstants.darkTextPrimary.withOpacity(0.2) : AppConstants.textPrimary.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: isDark ? AppConstants.darkTextPrimary.withOpacity(0.2) : AppConstants.textPrimary.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: AppConstants.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: AppConstants.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingMd,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
          ),
          onChanged: _onChanged,
        ),
      ],
    );
  }
}

/// Input formatter for currency with commas
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format with commas
    final formatted = _formatNumber(digitsOnly);

    // Let Flutter handle cursor positioning naturally
    return TextEditingValue(
      text: formatted,
      selection: newValue.selection,
    );
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '';
    final buffer = StringBuffer();
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
