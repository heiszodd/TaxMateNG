import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/tax_service.dart';
import '../utils/constants.dart';

/// Pie chart showing tax distribution by band
class TaxChart extends StatefulWidget {
  final List<TaxBand> bands;
  final bool isStackedBar;
  final VoidCallback onChartTypeChanged;

  const TaxChart({
    super.key,
    required this.bands,
    required this.isStackedBar,
    required this.onChartTypeChanged,
  });

  @override
  State<TaxChart> createState() => _TaxChartState();
}

class _TaxChartState extends State<TaxChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(TaxChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStackedBar != widget.isStackedBar) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.bands.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalTax = widget.bands.fold<double>(0, (sum, band) => sum + band.tax);
    if (totalTax == 0) {
      return const SizedBox.shrink();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax Distribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onChartTypeChanged,
                    icon: Icon(
                      widget.isStackedBar ? Icons.pie_chart : Icons.bar_chart,
                      color: widget.isStackedBar ? AppConstants.primary : AppConstants.accent,
                    ),
                    tooltip: widget.isStackedBar ? 'Switch to pie chart' : 'Switch to bar chart',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: SizedBox(
              key: ValueKey(widget.isStackedBar),
              height: 200,
              child: widget.isStackedBar ? _buildBarChart(totalTax) : _buildPieChart(totalTax),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildLegend(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPieChart(double totalTax) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PieChart(
      PieChartData(
        sections: _buildSections(totalTax),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        centerSpaceColor: isDark ? AppConstants.darkSurface : AppConstants.surface,
      ),
    );
  }

  Widget _buildBarChart(double totalTax) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(totalTax),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₦${(value / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= widget.bands.length) return const SizedBox();
                return Text(
                  widget.bands[value.toInt()].rate,
                  style: TextStyle(
                    color: isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: totalTax / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: (isDark ? AppConstants.darkTextSecondary : AppConstants.textSecondary).withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? AppConstants.darkSurface : AppConstants.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₦${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double totalTax) {
    final colors = [
      AppConstants.primary,
      AppConstants.accent,
      const Color(0xFF9C88FF),
      const Color(0xFFF0932B),
      const Color(0xFFE84393),
    ];

    return widget.bands.asMap().entries.map((entry) {
      final index = entry.key;
      final band = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: band.tax,
            color: colors[index % colors.length],
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _buildSections(double totalTax) {
    final colors = [
      AppConstants.primary,
      AppConstants.accent,
      const Color(0xFF9C88FF),
      const Color(0xFFF0932B),
      const Color(0xFFE84393),
    ];

    return widget.bands.asMap().entries.map((entry) {
      final index = entry.key;
      final band = entry.value;
      final percentage = (band.tax / totalTax) * 100;

      return PieChartSectionData(
        value: band.tax,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: percentage < 5 ? null : Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length],
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme, bool isDark) {
    final colors = [
      AppConstants.primary,
      AppConstants.accent,
      const Color(0xFF9C88FF),
      const Color(0xFFF0932B),
      const Color(0xFFE84393),
    ];

    return Wrap(
      spacing: AppConstants.spacingMd,
      runSpacing: AppConstants.spacingXs,
      children: widget.bands.asMap().entries.map((entry) {
        final index = entry.key;
        final band = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              band.rate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppConstants.darkTextPrimary : AppConstants.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
