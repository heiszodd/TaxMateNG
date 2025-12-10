import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Export buttons for tax calculation results
class ExportButtons extends StatelessWidget {
  final TaxResult result;
  final TaxInput input;

  const ExportButtons({
    super.key,
    required this.result,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: (isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
      ),
      child: Row(
        children: [
          Text(
            'Export:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          _buildExportButton(
            context,
            'CSV',
            Icons.table_chart,
            () => ExportService.exportAsCSV(result, input, context),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          _buildExportButton(
            context,
            'JSON',
            Icons.data_object,
            () => ExportService.exportAsJSON(result, input, context),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          _buildExportButton(
            context,
            'PNG',
            Icons.image,
            () => ExportService.exportAsImage(
              _buildExportWidget(context),
              context,
              'tax_calculation_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXs,
          vertical: AppConstants.spacingXs / 2,
        ),
        decoration: BoxDecoration(
          color: AppConstants.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius / 2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppConstants.primary,
            ),
            const SizedBox(width: AppConstants.spacingXs / 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      color: isDark ? AppConstants.darkSurface : AppConstants.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TaxMate - Tax Calculation Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Generated on ${DateTime.now().toString().split('.')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Input summary
          _buildExportRow(context, 'Gross Income', AppFormatters.formatCurrency(input.grossIncome), isDark),
          _buildExportRow(context, 'Deductions', AppFormatters.formatCurrency(input.deductions), isDark),
          _buildExportRow(context, 'Rent Paid', AppFormatters.formatCurrency(input.rentPaid), isDark),
          const SizedBox(height: AppConstants.spacingSm),

          // Results
          _buildExportRow(context, 'Taxable Income', AppFormatters.formatCurrency(result.taxableIncome), isDark),
          _buildExportRow(context, 'Annual Tax', AppFormatters.formatCurrency(result.annualTax), isDark),
          _buildExportRow(context, 'Monthly Tax', AppFormatters.formatCurrency(result.monthlyTax), isDark),
          _buildExportRow(context, 'Net After Tax', AppFormatters.formatCurrency(result.netAnnualAfterTax), isDark),
        ],
      ),
    );
  }

  Widget _buildExportRow(BuildContext context, String label, String value, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
