import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';

class WidgetService {
  static const String _androidWidgetName = 'StreakWidgetProvider';

  /// Updates the Home Screen Widget with the current streak
  static Future<void> updateStreakWidget(int streakDays) async {
    // Requirements: Platform Guard (Android/iOS only)
    if (!(Platform.isAndroid || Platform.isIOS)) {
      debugPrint("Home Widget ignored: Not on Android/iOS");
      return;
    }

    try {
      // Save data for the widget
      await HomeWidget.saveWidgetData<int>('streak_days', streakDays);
      
      // Trigger a native UI refresh
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
      
      debugPrint("Home Widget updated: $streakDays days");
    } catch (e) {
      debugPrint("Error updating Home Widget: $e");
    }
  }
}
