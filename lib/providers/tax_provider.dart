import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tax_service.dart';

/// Provider for tax input state
final taxInputProvider = StateNotifierProvider<TaxInputNotifier, TaxInput>((ref) {
  return TaxInputNotifier();
});

class TaxInputNotifier extends StateNotifier<TaxInput> {
  TaxInputNotifier() : super(const TaxInput(grossIncome: 0));

  void updateGrossIncome(double value) {
    state = TaxInput(
      grossIncome: value,
      deductions: state.deductions,
      rentPaid: state.rentPaid,
    );
  }

  void updateDeductions(double value) {
    state = TaxInput(
      grossIncome: state.grossIncome,
      deductions: value,
      rentPaid: state.rentPaid,
    );
  }

  void updateRentPaid(double value) {
    state = TaxInput(
      grossIncome: state.grossIncome,
      deductions: state.deductions,
      rentPaid: value,
    );
  }

  void reset() {
    state = const TaxInput(grossIncome: 0);
  }

  void loadSample(int index) {
    final samples = TaxInput.sampleData;
    if (index >= 0 && index < samples.length) {
      state = samples[index];
    }
  }
}

/// Provider for tax calculation result with debounced live preview
final taxResultProvider = StateNotifierProvider<TaxResultNotifier, AsyncValue<TaxResult?>>((ref) {
  final input = ref.watch(taxInputProvider);
  return TaxResultNotifier(input);
});

class TaxResultNotifier extends StateNotifier<AsyncValue<TaxResult?>> {
  Timer? _debounceTimer;

  TaxResultNotifier(TaxInput input) : super(const AsyncValue.data(null)) {
    _debouncedCalculateTax(input);
  }

  void _debouncedCalculateTax(TaxInput input) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _calculateTax(input);
    });
  }

  void _calculateTax(TaxInput input) async {
    if (input.grossIncome <= 0) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Simulate async calculation
      await Future.delayed(const Duration(milliseconds: 200));
      final result = TaxService.calculateTax(input);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void recalculate(TaxInput input) {
    _debouncedCalculateTax(input);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
}

/// Provider for showing monthly/annual toggle
final showMonthlyProvider = StateNotifierProvider<ShowMonthlyNotifier, bool>((ref) {
  return ShowMonthlyNotifier();
});

class ShowMonthlyNotifier extends StateNotifier<bool> {
  ShowMonthlyNotifier() : super(false);

  void toggle() => state = !state;
}

/// Provider for comparison mode
final comparisonModeProvider = StateNotifierProvider<ComparisonModeNotifier, bool>((ref) {
  return ComparisonModeNotifier();
});

class ComparisonModeNotifier extends StateNotifier<bool> {
  ComparisonModeNotifier() : super(false);

  void toggle() => state = !state;
}

/// Provider for comparison input (B values)
final comparisonInputProvider = StateNotifierProvider<ComparisonInputNotifier, TaxInput>((ref) {
  return ComparisonInputNotifier();
});

class ComparisonInputNotifier extends StateNotifier<TaxInput> {
  ComparisonInputNotifier() : super(const TaxInput(grossIncome: 0));

  void updateGrossIncome(double value) {
    state = TaxInput(
      grossIncome: value,
      deductions: state.deductions,
      rentPaid: state.rentPaid,
    );
  }

  void updateDeductions(double value) {
    state = TaxInput(
      grossIncome: state.grossIncome,
      deductions: value,
      rentPaid: state.rentPaid,
    );
  }

  void updateRentPaid(double value) {
    state = TaxInput(
      grossIncome: state.grossIncome,
      deductions: state.deductions,
      rentPaid: value,
    );
  }

  void reset() {
    state = const TaxInput(grossIncome: 0);
  }

  void loadSample(int index) {
    final samples = TaxInput.sampleData;
    if (index >= 0 && index < samples.length) {
      state = samples[index];
    }
  }
}

/// Provider for comparison result
final comparisonResultProvider = StateNotifierProvider<ComparisonResultNotifier, AsyncValue<TaxResult?>>((ref) {
  final input = ref.watch(comparisonInputProvider);
  return ComparisonResultNotifier(input);
});

class ComparisonResultNotifier extends StateNotifier<AsyncValue<TaxResult?>> {
  ComparisonResultNotifier(TaxInput input) : super(const AsyncValue.data(null)) {
    _calculateTax(input);
  }

  void _calculateTax(TaxInput input) async {
    if (input.grossIncome <= 0) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final result = TaxService.calculateTax(input);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void recalculate(TaxInput input) {
    _calculateTax(input);
  }
}
