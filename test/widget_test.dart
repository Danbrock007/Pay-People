import 'package:flutter_test/flutter_test.dart';
import 'package:kapco_payroll/main.dart';

void main() {
  testWidgets('KAPCO Payroll login renders', (tester) async {
    await tester.pumpWidget(const KapcoPayrollApp());

    expect(find.text('KAPCO'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to KAPCO Payroll'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('Username / Employee ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
