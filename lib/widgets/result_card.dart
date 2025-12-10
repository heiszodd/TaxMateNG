import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/tax_service.dart';
import '../services/validation_service.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

/// Result card displaying tax calculation results with friendly messages
class ResultCard extends StatefulWidget {
  final TaxResult result;
  final TaxInput input;
  final bool showMonthly;

  const ResultCard({
    super.key,
    required this.result,
    required this.input,
    this.showMonthly = false,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  late ConfettiController _confettiController;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Trigger confetti for no/low tax scenarios
    if (widget.result.annualTax == 0 || widget.result.annualTax < 10000) {
      _showConfetti = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getFriendlyMessage() {
    if (widget.result.annualTax == 0) {
      return '🎉 Congratulations! No tax liability for you this year!';
    } else if (widget.result.annualTax < 10000) {
      return '😊 Great news! Your tax liability is very low!';
    } else if (widget.result.annualTax < 50000) {
      return '👍 Your tax liability is reasonable. Good job!';
    } else if (widget.result.annualTax < 200000) {
      return '💼 You have a moderate tax liability. Consider tax optimization strategies.';
    } else {
      return '📊 You have a significant tax liability. Let\'s explore ways to optimize your taxes.';
    }
  }

  IconData _getResultIcon() {
    if (widget.result.annualTax == 0) {
      return Icons.celebration;
    } else if (widget.result.annualTax < 10000) {
      return Icons.sentiment_very_satisfied;
    } else if (widget.result.annualTax < 50000) {
      return Icons.thumb_up;
    } else if (widget.result.annualTax < 200000) {
      return Icons.account_balance_wallet;
    } else {
      return Icons.analytics;
    }
  }

  Color _getResultColor() {
    if (widget.result.annualTax == 0) {
      return AppConstants.success;
    } else if (widget.result.annualTax < 10000) {
      return AppConstants.success.withOpacity(0.8);
    } else if (widget.result.annualTax < 50000) {
      return AppConstants.primary;
    } else if (widget.result.annualTax < 200000) {
      return Colors.orange;
    } else {
      return AppConstants.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tips = ValidationService.getTaxTips(widget.result, widget.input);

    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and friendly message
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingXs),
                      decoration: BoxDecoration(
                        color: _getResultColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                      ),
                      child: Icon(
                        _getResultIcon(),
                        color: _getResultColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        _getFriendlyMessage(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Taxable Income',
                        AppFormatters.formatCurrency(widget.result.taxableIncome),
                        Icons.account_balance,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: _buildSummaryCard(
                        widget.showMonthly ? 'Monthly Tax' : 'Annual Tax',
                        AppFormatters.formatCurrency(
                          widget.showMonthly ? widget.result.monthlyTax : widget.result.annualTax,
                        ),
                        Icons.receipt,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Net After Tax',
                        AppFormatters.formatCurrency(widget.result.netAnnualAfterTax),
                        Icons.savings,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: _buildSummaryCard(
                        'Effective Rate',
                        '${(widget.result.annualTax / widget.result.taxableIncome * 100).toStringAsFixed(1)}%',
                        Icons.percent,
                        isDark,
                      ),
                    ),
                  ],
                ),

                // Tax tips
                if (tips.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSm),
                    decoration: BoxDecoration(
                      color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              size: 16,
                              color: AppConstants.primary,
                            ),
                            const SizedBox(width: AppConstants.spacingXs),
                            Text(
                              'Tax Optimization Tips',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        ...tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacingXs / 2),
                          child: Text(
                            '• $tip',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Confetti effect
        if (_showConfetti)
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
              ),
              const SizedBox(width: AppConstants.spacingXs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs / 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
