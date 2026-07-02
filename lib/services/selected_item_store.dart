import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/selected_hotpot_item.dart';

class SelectedItemStore {
  static const String _itemsKey = 'selected_hotpot_items';

  Future<List<SelectedHotpotItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_itemsKey) ?? const [];

    final items = <SelectedHotpotItem>[];
    for (final raw in rawItems) {
      try {
        items.add(
          SelectedHotpotItem.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // 跳过损坏的数据条目，避免整表加载失败
      }
    }
    return items;
  }

  Future<void> saveItems(List<SelectedHotpotItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_itemsKey, rawItems);
  }
}
