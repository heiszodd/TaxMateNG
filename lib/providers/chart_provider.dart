import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for chart type (pie vs stacked bar)
final chartTypeProvider = StateNotifierProvider<ChartTypeNotifier, bool>((ref) {
  return ChartTypeNotifier();
});

class ChartTypeNotifier extends StateNotifier<bool> {
  ChartTypeNotifier() : super(false); // false = pie chart, true = stacked bar

  void toggle() => state = !state;
  void setPie() => state = false;
  void setStackedBar() => state = true;
}
