import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sauce_recipe.dart';

/// 忌口偏好与自定义蘸料的本地持久化。
class PreferenceStore {
  static const String _tabooKey = 'taboo_items';
  static const String _saucesKey = 'custom_sauces';

  Future<Set<String>> loadTabooItems() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_tabooKey) ?? const []).toSet();
  }

  Future<void> saveTabooItems(Set<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tabooKey, items.toList());
  }

  Future<List<SauceRecipe>> loadCustomSauces() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSauces = prefs.getStringList(_saucesKey) ?? const [];
    final sauces = <SauceRecipe>[];
    for (final raw in rawSauces) {
      try {
        sauces.add(
          SauceRecipe.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // 跳过损坏的数据条目，避免整表加载失败
      }
    }
    return sauces;
  }

  Future<void> saveCustomSauces(List<SauceRecipe> sauces) async {
    final prefs = await SharedPreferences.getInstance();
    final rawSauces =
        sauces.map((sauce) => jsonEncode(sauce.toJson())).toList();
    await prefs.setStringList(_saucesKey, rawSauces);
  }
}
