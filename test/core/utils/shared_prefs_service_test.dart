import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/utils/shared_prefs_service.dart'; // Uprav cestu!

void main() {
  late SharedPrefsService prefsService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefsService = SharedPrefsService();
  });

  group('SharedPrefsService - Reálná perzistence dat', () {
    test(
      'saveSelectedFaculties() a getSelectedFaculties() - korektně zapíše a přečte pole ID',
      () async {
        // 1. ACT:
        await prefsService.saveSelectedFaculties([1, 4]);

        // 2. ACT:
        final nacteneFakulty = await prefsService.getSelectedFaculties();

        // 3. ASSERT:
        expect(nacteneFakulty, [1, 4]);
      },
    );

    test(
      'saveUpvotedReportId() - uchová informaci o tom, že uživatel dal lajk závadě',
      () async {
        final testEmail = "illia@mendelu.cz";

        await prefsService.saveUpvotedReportId(99, testEmail);

        final seznamLajku = await prefsService.getUpvotedReportIds(testEmail);
        expect(seznamLajku.contains(99), true);
      },
    );
  });
}
