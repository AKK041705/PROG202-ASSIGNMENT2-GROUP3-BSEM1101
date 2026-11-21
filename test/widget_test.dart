import 'package:flutter_test/flutter_test.dart';

import 'package:salone_transport_hub/main.dart';

void main() {
  testWidgets('Salone Transport Hub launches successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SaloneTransportHubApp());

    expect(find.text('Salone Transport Hub'), findsOneWidget);
  });
}
