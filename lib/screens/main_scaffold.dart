import 'package:flutter/material.dart';
import '../models/sauce_recipe.dart';
import '../services/preference_store.dart';
import 'home_screen.dart';
import 'seasoning_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 1; // 默认停在"涮锅"

  final PreferenceStore _preferenceStore = PreferenceStore();
  final Set<String> _tabooItems = {};
  final List<SauceRecipe> _customSauces = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final taboo = await _preferenceStore.loadTabooItems();
    final sauces = await _preferenceStore.loadCustomSauces();
    if (!mounted) return;
    setState(() {
      _tabooItems
        ..clear()
        ..addAll(taboo);
      _customSauces
        ..clear()
        ..addAll(sauces);
    });
  }

  void _toggleTaboo(String item) {
    setState(() {
      if (_tabooItems.contains(item)) {
        _tabooItems.remove(item);
      } else {
        _tabooItems.add(item);
      }
    });
    _preferenceStore.saveTabooItems(_tabooItems);
  }

  void _addCustomSauce(SauceRecipe sauce) {
    setState(() => _customSauces.add(sauce));
    _preferenceStore.saveCustomSauces(_customSauces);
  }

  void _removeCustomSauce(String id) {
    setState(() => _customSauces.removeWhere((s) => s.id == id));
    _preferenceStore.saveCustomSauces(_customSauces);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      SeasoningScreen(
        tabooItems: _tabooItems,
        customSauces: _customSauces,
        onToggleTaboo: _toggleTaboo,
        onAddCustomSauce: _addCustomSauce,
        onRemoveCustomSauce: _removeCustomSauce,
      ),
      const HomeScreen(),
      ProfileScreen(
        tabooItems: _tabooItems,
        onNavigateToSeasoning: () => setState(() => _currentIndex = 0),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFFFCC00),
        unselectedItemColor: const Color(0xFF555555),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.soup_kitchen_outlined),
            activeIcon: Icon(Icons.soup_kitchen),
            label: '蘸料',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.outdoor_grill_outlined),
            activeIcon: Icon(Icons.outdoor_grill),
            label: '涮锅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
