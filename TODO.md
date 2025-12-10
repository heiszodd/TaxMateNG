# TaxMate Enhancement TODO

## Completed Features
- [x] Mobile-first responsiveness (LayoutBuilder in home_page.dart)
- [x] Dark/Light mode toggle (app bar icon, auto-detect system)
- [x] Currency fields auto-format with commas and prefix "₦"
- [x] PrimaryButton: pill shape, gradient, microshadow, scale animation
- [x] SecondaryButton: text button, hover elevation/color tint
- [x] Result Card: animate fade + slide, copy-to-clipboard with toast
- [x] Tax Band Breakdown: accordion, copy CSV, expand/collapse animation, hover highlights
- [x] Charts: Pie chart with animations, hover shows value, accent colors
- [x] Sample Data: sampleData() method present
- [x] Debug banner for seeding sample values

## Pending Enhancements
- [ ] Live preview with 300ms debounce (implement in tax_provider.dart)
- [ ] Input presets dropdown (replace debug buttons with dropdown)
- [ ] Inline tooltips on fields (add Tooltip widgets)
- [ ] Keyboard shortcuts: Enter → calculate, Esc → reset (add FocusNode and RawKeyboardListener)
- [ ] Shake animation on invalid input (add animation to CurrencyField)
- [ ] Friendly messages with emoji/confetti (enhance ResultCard)
- [ ] Export summary as CSV/PNG (add export buttons, use screenshot for PNG)
- [ ] Stacked bar chart option (add toggle in TaxChart)
- [ ] Accent color picker (add to settings or footer)
- [ ] High-contrast mode toggle (add to theme provider)
- [ ] Accessibility: Semantics for inputs, buttons, charts
- [ ] Confetti effects for no/low tax scenarios

## Implementation Plan
1. Enhance tax_provider.dart for live preview with debounce
2. Add tooltips to CurrencyField widgets
3. Implement keyboard shortcuts in home_page.dart
4. Add shake animation to CurrencyField
5. Enhance ResultCard with friendly messages and confetti
6. Add export functionality to ResultCard
7. Add chart type toggle to TaxChart
8. Add accent color picker to footer
9. Add high-contrast mode to theme provider
10. Add Semantics throughout the app
