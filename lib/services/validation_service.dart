import '../services/tax_service.dart';
import '../utils/formatters.dart';

/// Service for validating tax inputs and providing smart error checking
class ValidationService {
  static const double _minIncome = 0;
  static const double _maxIncome = 100000000; // 100 million NGN
  static const double _pensionCap = 500000; // Annual pension cap
  static const double _rentCap = 500000; // Annual rent cap

  /// Validate gross income and return validation message
  static String? validateGrossIncome(double value) {
    if (value < _minIncome) {
      return 'Income cannot be negative';
    }

    if (value > _maxIncome) {
      return 'Income seems unusually high. Please verify the amount.';
    }

    if (value == 0) {
      return null; // Allow zero for empty state
    }

    // Check for potentially monthly values
    if (value > 0 && value < 50000) {
      return 'Income seems unusually low. Did you mean to enter annual income?';
    }

    // Check for potentially monthly values that look like annual
    if (value > 100000 && value < 200000) {
      return 'This looks like it might be monthly income. Consider switching to monthly mode.';
    }

    return null;
  }

  /// Validate deductions and return validation message
  static String? validateDeductions(double grossIncome, double deductions) {
    if (deductions < 0) {
      return 'Deductions cannot be negative';
    }

    if (deductions > grossIncome) {
      return 'Deductions cannot exceed gross income';
    }

    if (grossIncome > 0 && deductions > grossIncome * 0.8) {
      return 'Deductions seem unusually high. Please verify the amounts.';
    }

    return null;
  }

  /// Validate rent paid and return validation message
  static String? validateRentPaid(double rentPaid) {
    if (rentPaid < 0) {
      return 'Rent paid cannot be negative';
    }

    if (rentPaid > _rentCap) {
      return 'Rent relief is capped at ₦500,000 per annum. Excess will not qualify.';
    }

    return null;
  }

  /// Get smart validation messages for all inputs
  static Map<String, String?> validateAll(TaxInput input) {
    return {
      'grossIncome': validateGrossIncome(input.grossIncome),
      'deductions': validateDeductions(input.grossIncome, input.deductions),
      'rentPaid': validateRentPaid(input.rentPaid),
    };
  }

  /// Check if values look like monthly amounts
  static bool looksLikeMonthly(double value) {
    // Monthly income typically ranges from ~50k to ~2M NGN
    return value >= 50000 && value <= 2000000;
  }

  /// Check if values look like annual amounts
  static bool looksLikeAnnual(double value) {
    // Annual income typically ranges from ~500k to ~50M NGN
    return value >= 500000 && value <= 50000000;
  }

  /// Suggest mode based on input values
  static String? suggestMode(TaxInput input) {
    if (input.grossIncome == 0) return null;

    if (looksLikeMonthly(input.grossIncome)) {
      return 'This looks like monthly income. Consider switching to monthly mode.';
    }

    if (looksLikeAnnual(input.grossIncome)) {
      return 'This looks like annual income. Consider switching to annual mode.';
    }

    return null;
  }

  /// Get helpful tips based on the tax result
  static List<String> getTaxTips(TaxResult result, TaxInput input) {
    final tips = <String>[];

    // Effective rate tips
    final effectiveRate = result.annualTax / result.taxableIncome;
    if (effectiveRate < 0.05) {
      tips.add('Your effective tax rate (${(effectiveRate * 100).toStringAsFixed(1)}%) is relatively low.');
    } else if (effectiveRate > 0.25) {
      tips.add('Your effective tax rate (${(effectiveRate * 100).toStringAsFixed(1)}%) is quite high.');
    }

    // Pension optimization
    final pensionContribution = input.grossIncome - result.taxableIncome;
    if (pensionContribution < 500000) {
      final potentialSavings = _calculatePotentialSavings(result, input, 500000 - pensionContribution);
      if (potentialSavings > 0) {
        tips.add('Increasing pension contribution by ₦${AppFormatters.formatCurrency(500000 - pensionContribution)} could save you ₦${AppFormatters.formatCurrency(potentialSavings)} in taxes.');
      }
    }

    // Tax bracket information
    final highestBand = result.bandBreakdown.lastWhere((band) => band.tax > 0, orElse: () => result.bandBreakdown.first);
    final rateValue = double.tryParse(highestBand.rate.replaceAll('%', '')) ?? 0;
    tips.add('You are taxed in the ${highestBand.band} bracket (${rateValue.toStringAsFixed(0)}%).');

    return tips;
  }

  /// Calculate potential tax savings from additional pension contribution
  static double _calculatePotentialSavings(TaxResult currentResult, TaxInput input, double additionalPension) {
    // This is a simplified calculation - in reality, it would depend on the tax brackets
    final newTaxableIncome = currentResult.taxableIncome - additionalPension;
    if (newTaxableIncome <= 0) return 0;

    // Use the same tax calculation logic
    final newResult = TaxService.calculateTax(TaxInput(
      grossIncome: input.grossIncome,
      deductions: input.deductions + additionalPension,
      rentPaid: input.rentPaid,
    ));

    return currentResult.annualTax - newResult.annualTax;
  }
}
