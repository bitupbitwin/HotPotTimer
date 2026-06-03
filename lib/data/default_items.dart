import '../models/hotpot_item.dart';

/// 预设食材清单。后续可替换为从 JSON / 网络加载。
/// 没有真实图片资源时，用 emoji 兜底显示。
final List<HotpotItem> defaultItems = [
  HotpotItem(id: '1', name: '脆爽毛肚', category: '荤菜', targetSeconds: 15, emoji: '🥩'),
  HotpotItem(id: '2', name: '鲜切鸭肠', category: '荤菜', targetSeconds: 12, emoji: '🐤'),
  HotpotItem(id: '3', name: '嫩牛肉', category: '荤菜', targetSeconds: 30, emoji: '🥓'),
  HotpotItem(id: '4', name: '潮汕牛肉丸', category: '丸滑', targetSeconds: 600, emoji: '🧆'),
  HotpotItem(id: '5', name: '虾滑', category: '丸滑', targetSeconds: 240, emoji: '🦐'),
  HotpotItem(id: '6', name: '嫩豆腐', category: '素菜', targetSeconds: 180, emoji: '🧈'),
  HotpotItem(id: '7', name: '金针菇', category: '素菜', targetSeconds: 90, emoji: '🍄'),
  HotpotItem(id: '8', name: '宽粉', category: '主食', targetSeconds: 300, emoji: '🍜'),
  HotpotItem(id: '9', name: '鹌鹑蛋', category: '丸滑', targetSeconds: 360, emoji: '🥚'),
  HotpotItem(id: '10', name: '生菜', category: '素菜', targetSeconds: 20, emoji: '🥬'),
];
