import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/screens/register_screen.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Flutter Application Flow Tests', () {
    testWidgets('LoginScreen form validation flow', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find Login button and tap without entering credentials
      final loginButtons = find.text('Đăng nhập');
      expect(loginButtons, findsWidgets);

      // Tap the submit button in the form
      await tester.tap(loginButtons.last);
      await tester.pumpAndSettle();

      // Expect validation error messages
      expect(find.text('Vui lòng nhập email hoặc tên đăng nhập.'), findsOneWidget);
    });

    testWidgets('Navigation from LoginScreen to RegisterScreen flow', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final registerLink = find.textContaining('Đăng ký ngay');
      expect(registerLink, findsOneWidget);

      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Verify RegisterScreen is pushed
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Tạo tài khoản'), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
    });


  });
}
