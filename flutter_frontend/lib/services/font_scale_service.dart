import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global text-size controller (accessibility for elderly / low-vision
/// users). Cycles 100% → 115% → 130% and persists the choice.
class FontScaleService extends ValueNotifier<double> {
  FontScaleService._() : super(1.0) {
    _load();
  }

  /// Global singleton.
  static final FontScaleService instance = FontScaleService._();

  static const String _key = 'font_scale';
  static const List<double> steps = [1.0, 1.15, 1.3];

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getDouble(_key);
      if (v != null && steps.contains(v)) value = v;
    } catch (_) {}
  }

  Future<void> cycle() async {
    final i = steps.indexOf(value);
    value = steps[(i + 1) % steps.length];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_key, value);
    } catch (_) {}
  }

  String get label => '${(value * 100).round()}%';
}
