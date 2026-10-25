import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotpot_timer/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('启动后展示菜品名与推荐时间', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pump();

    expect(find.text('脆爽毛肚'), findsOneWidget);
    expect(find.textContaining('推荐'), findsWidgets);
  });

  testWidgets('点击菜品后加入已点并在已点页启动倒计时', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('脆爽毛肚').last);
    await tester.pumpAndSettle();

    expect(find.text('已选 1 道'), findsOneWidget);

    await tester.tap(find.textContaining('已点').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('脆爽毛肚').last);
    await tester.pumpAndSettle();

    expect(find.text('已选 1 道'), findsOneWidget);
    expect(find.text('15s'), findsWidgets);
  });

  testWidgets('已点页按推荐时长从短到长排序', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('嫩牛肉').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('脆爽毛肚').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('鲜切鸭肠').last);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('已点').first);
    await tester.pumpAndSettle();

    final duckTop = tester.getTopLeft(find.text('鲜切鸭肠').last);
    final tripeTop = tester.getTopLeft(find.text('脆爽毛肚').last);

    expect(duckTop.dy, tripeTop.dy);
    expect(duckTop.dx, lessThan(tripeTop.dx));
  });
}
