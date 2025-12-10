import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing onboarding tutorial state
class OnboardingService {
  static const String _tutorialShownKey = 'tutorial_shown';
  static const String _tutorialStepKey = 'tutorial_step';

  /// Check if tutorial has been shown
  static Future<bool> hasTutorialBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialShownKey) ?? false;
  }

  /// Mark tutorial as shown
  static Future<void> markTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialShownKey, true);
  }

  /// Get current tutorial step
  static Future<int> getCurrentTutorialStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tutorialStepKey) ?? 0;
  }

  /// Set current tutorial step
  static Future<void> setCurrentTutorialStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tutorialStepKey, step);
  }

  /// Reset tutorial state (for testing)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialShownKey);
    await prefs.remove(_tutorialStepKey);
  }
}

/// Tutorial step data
class TutorialStep {
  final String title;
  final String description;
  final String? targetWidgetKey;
  final bool showSkip;

  const TutorialStep({
    required this.title,
    required this.description,
    this.targetWidgetKey,
    this.showSkip = true,
  });
}

/// Tutorial steps for the app
class TutorialSteps {
  static const List<TutorialStep> steps = [
    TutorialStep(
      title: 'Welcome to TaxMate!',
      description: 'Your personal Nigerian income tax calculator. Let\'s take a quick tour.',
      showSkip: false,
    ),
    TutorialStep(
      title: 'Enter Your Income',
      description: 'Start by entering your annual gross income. The app automatically formats currency.',
      targetWidgetKey: 'gross_income_field',
    ),
    TutorialStep(
      title: 'Add Deductions',
      description: 'Enter any allowable deductions like pension contributions or business expenses.',
      targetWidgetKey: 'deductions_field',
    ),
    TutorialStep(
      title: 'Rent Relief',
      description: 'Add rent paid for housing allowance. Maximum relief is ₦500,000 per year.',
      targetWidgetKey: 'rent_field',
    ),
    TutorialStep(
      title: 'Calculate Tax',
      description: 'Click Calculate to see your tax breakdown, effective rate, and net income.',
      targetWidgetKey: 'calculate_button',
    ),
    TutorialStep(
      title: 'View Results',
      description: 'See your tax summary, breakdown by tax bands, and visual charts.',
      targetWidgetKey: 'results_card',
    ),
    TutorialStep(
      title: 'Export Options',
      description: 'Export your results as PDF, CSV, JSON, or share a screenshot.',
      targetWidgetKey: 'export_buttons',
    ),
    TutorialStep(
      title: 'Theme & Settings',
      description: 'Toggle between light and dark themes, and switch between monthly/annual views.',
      targetWidgetKey: 'theme_toggle',
    ),
    TutorialStep(
      title: 'Comparison Mode',
      description: 'Compare two different tax scenarios side by side to see the differences.',
      targetWidgetKey: 'comparison_toggle',
    ),
    TutorialStep(
      title: 'You\'re All Set!',
      description: 'Start calculating your taxes. Tap anywhere to begin using TaxMate.',
      showSkip: false,
    ),
  ];
}
