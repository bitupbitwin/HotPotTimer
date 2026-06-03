import 'package:flutter_test/flutter_test.dart';

import 'package:hotpot_timer/main.dart';

void main() {
  testWidgets('启动后展示菜品名与推荐时间', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pump();

    expect(find.text('脆爽毛肚'), findsOneWidget);
    expect(find.textContaining('推荐'), findsWidgets);
  });
}
