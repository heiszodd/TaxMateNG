import '../utils/formatters.dart';

/// Tax calculation result
class TaxResult {
  final double taxableIncome;
  final double annualTax;
  final double monthlyTax;
  final double netAnnualAfterTax;
  final List<TaxBand> bandBreakdown;

  const TaxResult({
    required this.taxableIncome,
    required this.annualTax,
    required this.monthlyTax,
    required this.netAnnualAfterTax,
    required this.bandBreakdown,
  });

  /// Create from the existing calculation function result
  factory TaxResult.fromMap(Map<String, dynamic> map) {
    return TaxResult(
      taxableIncome: map['taxableIncome'] as double,
      annualTax: map['annualTax'] as double,
      monthlyTax: map['monthlyTax'] as double,
      netAnnualAfterTax: map['netAnnualAfterTax'] as double,
      bandBreakdown: (map['bandBreakdown'] as List<dynamic>)
          .map((band) => TaxBand.fromMap(band as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Individual tax band breakdown
class TaxBand {
  final String band;
  final String rate;
  final double taxable;
  final double tax;

  const TaxBand({
    required this.band,
    required this.rate,
    required this.taxable,
    required this.tax,
  });

  factory TaxBand.fromMap(Map<String, dynamic> map) {
    return TaxBand(
      band: map['band'] as String,
      rate: map['rate'] as String,
      taxable: map['taxable'] as double,
      tax: map['tax'] as double,
    );
  }

  /// Get formatted taxable amount
  String get formattedTaxable => AppFormatters.formatCurrency(taxable);

  /// Get formatted tax amount
  String get formattedTax => AppFormatters.formatCurrency(tax);
}

/// Input data for tax calculation
class TaxInput {
  final double grossIncome;
  final double deductions;
  final double rentPaid;

  const TaxInput({
    required this.grossIncome,
    this.deductions = 0,
    this.rentPaid = 0,
  });

  /// Sample data for testing
  static List<TaxInput> get sampleData => [
    const TaxInput(grossIncome: 1000000, deductions: 0, rentPaid: 0),
    const TaxInput(grossIncome: 5000000, deductions: 250000, rentPaid: 1000000),
    const TaxInput(grossIncome: 60000000, deductions: 2000000, rentPaid: 3000000),
  ];
}

/// Service for tax calculations
class TaxService {
  /// Calculate tax using the existing function
  static TaxResult calculateTax(TaxInput input) {
    // This would call the existing calculateNigeriaTax2025Detailed function
    // For now, we'll simulate it
    final result = calculateNigeriaTax2025Detailed(
      grossIncome: input.grossIncome,
      deductions: input.deductions,
      rentPaid: input.rentPaid,
    );
    return TaxResult.fromMap(result);
  }
}

/// Placeholder for the existing tax calculation function
/// This should be replaced with the actual implementation
Map<String, dynamic> calculateNigeriaTax2025Detailed({
  required double grossIncome,
  double deductions = 0,
  double rentPaid = 0,
}) {
  // Rent Relief: 20% of rent, max 500k
  double rentRelief = (rentPaid * 0.20);
  if (rentRelief > 500000) rentRelief = 500000;

  // Taxable Income
  double taxable = grossIncome - deductions - rentRelief;
  if (taxable <= 0) {
    return {
      'taxableIncome': 0.0,
      'annualTax': 0.0,
      'monthlyTax': 0.0,
      'netAnnualAfterTax': grossIncome - deductions,
      'bandBreakdown': [],
    };
  }

  double tax = 0;
  double remaining = taxable;
  List<Map<String, dynamic>> breakdown = [];

  // Tax bands: {limit: rate} where limit is the upper bound of the bracket
  final bands = [
    {'limit': 800000.0, 'rate': 0.00},
    {'limit': 2200000.0, 'rate': 0.15},
    {'limit': 9000000.0, 'rate': 0.18},
    {'limit': 13000000.0, 'rate': 0.21},
    {'limit': 25000000.0, 'rate': 0.23},
    {'limit': double.infinity, 'rate': 0.25},
  ];

  double previousLimit = 0;
  for (var band in bands) {
    double limit = band['limit']!;
    double rate = band['rate']!;

    if (remaining <= previousLimit) break;

    double bracketEnd = limit;
    double bracketStart = previousLimit;
    double taxableInBracket = (remaining > bracketEnd ? bracketEnd : remaining) - bracketStart;
    if (taxableInBracket > 0) {
      double taxInBracket = taxableInBracket * rate;
      tax += taxInBracket;
      breakdown.add({
        'band': '₦${AppFormatters.formatNumber(bracketStart)} - ₦${limit == double.infinity ? '∞' : AppFormatters.formatNumber(limit)}',
        'rate': '${(rate * 100).toStringAsFixed(0)}%',
        'taxable': taxableInBracket,
        'tax': taxInBracket,
      });
    }
    previousLimit = limit;
  }

  double monthlyTax = tax / 12;
  double netAnnualAfterTax = grossIncome - deductions - tax;

  return {
    'taxableIncome': taxable,
    'annualTax': tax,
    'monthlyTax': monthlyTax,
    'netAnnualAfterTax': netAnnualAfterTax,
    'bandBreakdown': breakdown,
  };
}
