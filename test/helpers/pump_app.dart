import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in the app-level dependencies (theme, providers).
  ///
  /// Add repository/bloc providers here as they are introduced so that every
  /// widget test gets the same environment.
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(MaterialApp(home: widget));
  }
}
