import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../services/tax_service.dart';
import '../utils/formatters.dart';

/// Service for exporting tax calculation results
class ExportService {
  static final ScreenshotController _screenshotController = ScreenshotController();

  /// Export tax result as CSV
  static Future<void> exportAsCSV(TaxResult result, TaxInput input, BuildContext context) async {
    try {
      final csvData = _generateCSV(result, input);
      final fileName = 'tax_calculation_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Share the CSV content
        await Share.share(
          csvData,
          subject: 'Tax Calculation Results',
          filename: fileName,
        );
      } else {
        // Desktop: Save to downloads directory
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(csvData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV exported to ${file.path}'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () async {
                  // On desktop, we could open the file, but for now just show the path
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  /// Export tax result as JSON
  static Future<void> exportAsJSON(TaxResult result, TaxInput input, BuildContext context) async {
    try {
      final jsonData = _generateJSON(result, input);
      final fileName = 'tax_calculation_${DateTime.now().millisecondsSinceEpoch}.json';

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Share the JSON content
        await Share.share(
          jsonData,
          subject: 'Tax Calculation Results',
          filename: fileName,
        );
      } else {
        // Desktop: Save to downloads directory
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(jsonData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('JSON exported to ${file.path}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export JSON: $e')),
      );
    }
  }

  /// Capture screenshot of a widget and share/save
  static Future<void> exportAsImage(Widget widget, BuildContext context, String fileName) async {
    try {
      // Create a temporary widget tree for screenshot
      final boundaryKey = GlobalKey();
      final tempWidget = RepaintBoundary(
        key: boundaryKey,
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget,
          ),
        ),
      );

      // Render the widget off-screen
      final image = await _screenshotController.captureFromWidget(tempWidget);

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Share the image
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName.png');
        await file.writeAsBytes(image);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Tax Calculation Screenshot',
        );
      } else {
        // Desktop: Save to downloads directory
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName.png');
          await file.writeAsBytes(image);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Screenshot saved to ${file.path}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export image: $e')),
      );
    }
  }

  /// Generate CSV data from tax result
  static String _generateCSV(TaxResult result, TaxInput input) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Tax Calculation Summary');
    buffer.writeln('Generated on,${DateTime.now().toString()}');
    buffer.writeln('');

    // Input data
    buffer.writeln('Input Data');
    buffer.writeln('Gross Income,${input.grossIncome}');
    buffer.writeln('Allowable Deductions,${input.deductions}');
    buffer.writeln('Rent Paid,${input.rentPaid}');
    buffer.writeln('');

    // Results
    buffer.writeln('Tax Calculation Results');
    buffer.writeln('Taxable Income,${result.taxableIncome}');
    buffer.writeln('Annual Tax,${result.annualTax}');
    buffer.writeln('Monthly Tax,${result.monthlyTax}');
    buffer.writeln('Net Annual After Tax,${result.netAnnualAfterTax}');
    buffer.writeln('Effective Rate,${(result.annualTax / result.taxableIncome * 100).toStringAsFixed(2)}%');
    buffer.writeln('');

    // Tax bands
    buffer.writeln('Tax Band Breakdown');
    buffer.writeln('Band,Rate,Taxable Amount,Tax');
    for (final band in result.bandBreakdown) {
      buffer.writeln('${band.band},${band.rate},${band.taxableAmount},${band.tax}');
    }

    return buffer.toString();
  }

  /// Generate JSON data from tax result
  static String _generateJSON(TaxResult result, TaxInput input) {
    final data = {
      'generatedAt': DateTime.now().toIso8601String(),
      'input': {
        'grossIncome': input.grossIncome,
        'deductions': input.deductions,
        'rentPaid': input.rentPaid,
      },
      'results': {
        'taxableIncome': result.taxableIncome,
        'annualTax': result.annualTax,
        'monthlyTax': result.monthlyTax,
        'netAnnualAfterTax': result.netAnnualAfterTax,
        'effectiveRate': result.annualTax / result.taxableIncome,
      },
      'bandBreakdown': result.bandBreakdown.map((band) => {
        'band': band.band,
        'rate': band.rate,
        'taxableAmount': band.taxableAmount,
        'tax': band.tax,
      }).toList(),
    };

    return JsonEncoder.withIndent('  ').convert(data);
  }

  /// Get screenshot controller for capturing widgets
  static ScreenshotController get screenshotController => _screenshotController;
}
