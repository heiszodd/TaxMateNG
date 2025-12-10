import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/tax_provider.dart';
import '../providers/chart_provider.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';
import '../widgets/currency_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/result_card.dart';
import '../widgets/band_breakdown.dart';
import '../widgets/tax_chart.dart';

/// Main home page for the TaxMate app
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taxInput = ref.watch(taxInputProvider);
    final taxResult = ref.watch(taxResultProvider);
    final showMonthly = ref.watch(showMonthlyProvider);
    final chartType = ref.watch(chartTypeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkMutedBg : AppConstants.mutedBg,
      appBar: AppBar(
        title: Text(
          'TaxMate',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: () => ref.read(showMonthlyProvider.notifier).toggle(),
            icon: Icon(
              showMonthly ? Icons.calendar_view_month : Icons.calendar_today,
              color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
            ),
            tooltip: showMonthly ? 'Show annual' : 'Show monthly',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 960;
            final isDesktop = constraints.maxWidth >= 960;

            if (isMobile) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CurrencyField(
                      label: 'Annual Gross Income',
                      hint: 'Enter your gross income',
                      initialValue: taxInput.grossIncome,
                      onChanged: (value) => ref.read(taxInputProvider.notifier).updateGrossIncome(value),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    CurrencyField(
                      label: 'Annual Deductions',
                      hint: 'Enter deductions',
                      initialValue: taxInput.deductions,
                      onChanged: (value) => ref.read(taxInputProvider.notifier).updateDeductions(value),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    CurrencyField(
                      label: 'Annual Rent Paid',
                      hint: 'Enter rent paid',
                      initialValue: taxInput.rentPaid,
                      onChanged: (value) => ref.read(taxInputProvider.notifier).updateRentPaid(value),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Calculate Tax',
                            onPressed: () => ref.read(taxResultProvider.notifier).recalculate(taxInput),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        TextButton(
                          onPressed: () => ref.read(taxInputProvider.notifier).reset(),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: AppConstants.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Debug banner (only in debug mode)
                    if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                      const SizedBox(height: AppConstants.spacingMd),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingSm),
                        decoration: BoxDecoration(
                          color: AppConstants.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Debug: ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primary,
                              ),
                            ),
                            ...List.generate(
                              TaxInput.sampleData.length,
                              (index) => TextButton(
                                onPressed: () => ref.read(taxInputProvider.notifier).loadSample(index),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppConstants.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingLg),

                    // Results section
                    taxResult.when(
                      data: (result) => result != null ? Column(
                        children: [
                          ResultCard(result: result, input: taxInput, showMonthly: showMonthly),
                          const SizedBox(height: AppConstants.spacingMd),
                          TaxChart(
                            bands: result.bandBreakdown,
                            isStackedBar: chartType,
                            onChartTypeChanged: () => ref.read(chartTypeProvider.notifier).toggle(),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          BandBreakdown(bands: result.bandBreakdown),
                        ],
                      ) : const SizedBox.shrink(),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error calculating tax: $error',
                          style: TextStyle(color: AppConstants.error),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Tablet and Desktop layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input section
                  Expanded(
                    flex: isTablet ? 1 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CurrencyField(
                          label: 'Annual Gross Income',
                          hint: 'Enter your gross income',
                          initialValue: taxInput.grossIncome,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateGrossIncome(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        CurrencyField(
                          label: 'Annual Deductions',
                          hint: 'Enter deductions',
                          initialValue: taxInput.deductions,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateDeductions(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        CurrencyField(
                          label: 'Annual Rent Paid',
                          hint: 'Enter rent paid',
                          initialValue: taxInput.rentPaid,
                          onChanged: (value) => ref.read(taxInputProvider.notifier).updateRentPaid(value),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Calculate Tax',
                                onPressed: () => ref.read(taxResultProvider.notifier).recalculate(taxInput),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            TextButton(
                              onPressed: () => ref.read(taxInputProvider.notifier).reset(),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppConstants.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Debug banner (only in debug mode)
                        if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                          const SizedBox(height: AppConstants.spacingMd),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingSm),
                            decoration: BoxDecoration(
                              color: AppConstants.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSm),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Debug: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primary,
                                  ),
                                ),
                                ...List.generate(
                                  TaxInput.sampleData.length,
                                  (index) => TextButton(
                                    onPressed: () => ref.read(taxInputProvider.notifier).loadSample(index),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: AppConstants.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (isTablet || isDesktop) const SizedBox(width: AppConstants.spacingLg),

                  // Results section
                  Expanded(
                    flex: isTablet ? 1 : 1,
                    child: taxResult.when(
                      data: (result) => result != null ? Column(
                        children: [
                          ResultCard(result: result, input: taxInput, showMonthly: showMonthly),
                          const SizedBox(height: AppConstants.spacingMd),
                          TaxChart(
                            bands: result.bandBreakdown,
                            isStackedBar: chartType,
                            onChartTypeChanged: () => ref.read(chartTypeProvider.notifier).toggle(),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          BandBreakdown(bands: result.bandBreakdown),
                        ],
                      ) : const SizedBox.shrink(),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error calculating tax: $error',
                          style: TextStyle(color: AppConstants.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
