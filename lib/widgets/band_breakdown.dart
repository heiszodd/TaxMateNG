import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Expandable widget showing tax band breakdown
class BandBreakdown extends StatefulWidget {
  final List<TaxBand> bands;

  const BandBreakdown({
    super.key,
    required this.bands,
  });

  @override
  State<BandBreakdown> createState() => _BandBreakdownState();
}

class _BandBreakdownState extends State<BandBreakdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _copyBreakdown() {
    final csv = 'Band,Rate,Taxable Amount,Tax\n' +
        widget.bands.map((band) =>
            '${band.band},${band.rate},${AppFormatters.formatCurrency(band.taxable)},${AppFormatters.formatCurrency(band.tax)}'
        ).join('\n');

    Clipboard.setData(ClipboardData(text: csv)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tax breakdown copied to clipboard'),
          backgroundColor: AppConstants.accent,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.bands.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkSurface : AppConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: const [AppConstants.softShadow],
        ),
        child: Center(
          child: Text(
            'No tax owed',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkSurface : AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: const [AppConstants.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _copyBreakdown,
                        icon: Icon(
                          Icons.copy,
                          color: AppConstants.primary,
                          size: 20,
                        ),
                        tooltip: 'Copy as CSV',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _animation,
            child: Column(
              children: widget.bands.map((band) => _buildBandRow(band, theme, isDark)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandRow(TaxBand band, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: (isDark ? AppConstants.darkMutedBg : AppConstants.mutedBg).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                band.band,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                ),
              ),
              Text(
                band.rate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxable: ${AppFormatters.formatCurrency(band.taxable)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.7),
                ),
              ),
              Text(
                'Tax: ${AppFormatters.formatCurrency(band.tax)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
