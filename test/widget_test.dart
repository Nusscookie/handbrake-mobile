import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/main.dart';

void main() {
  testWidgets('Transcoder shows Source screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TranscoderApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choose video'), findsOneWidget);
  });
}
