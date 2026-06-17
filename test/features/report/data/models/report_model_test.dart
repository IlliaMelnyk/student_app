import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/reports/data/models/report_model.dart';

void main() {
  group('ReportModel - JSON Parsování a Fallbacky', () {
    test(
      'fromJson() - správně naparsuje data pomocí záložních klíčů (snake_case)',
      () {
        // ARRANGE:
        final Map<String, dynamic> jsonMap = {
          "post_id": 42,
          "title": "Rozbité okno",
          "description": "Fouká sem",
          "status": "NEW",
          "date_added": "2026-06-17T10:00:00Z",
          "upvotes": 5,
          "author_name": "Illia",
          "location": "Budova Q",
          "comment_count": 3,
          "image_url": "https://example.com/img.jpg",
        };

        // ACT:
        final report = ReportModel.fromJson(jsonMap);

        // ASSERT:
        expect(report.id, 42);
        expect(report.title, "Rozbité okno");
        expect(report.description, "Fouká sem");
        expect(report.upvoteCount, 5);
        expect(report.authorName, "Illia");
        expect(report.place, "Budova Q");
        expect(report.commentCount, 3);
        expect(report.imageUrl, "https://example.com/img.jpg");
      },
    );

    test(
      'fromJson() - nespadne při prázdném JSONu a dosadí výchozí hodnoty',
      () {
        // ARRANGE:
        final Map<String, dynamic> emptyJson = {};

        // ACT
        final report = ReportModel.fromJson(emptyJson);

        // ASSERT:
        expect(report.id, 0);
        expect(report.title, "Bez názvu");
        expect(report.description, "");
        expect(report.status, "NEW");
        expect(report.upvoteCount, 0);
        expect(report.authorName, "Anonymní uživatel");
        expect(report.place, "Neznámá lokace");
        expect(report.commentCount, 0);
        expect(report.imageUrl, null);
      },
    );

    test('copyWith() - vytvoří novou instanci se změněnými vlastnostmi', () {
      // ARRANGE:
      final originalReport = ReportModel(
        id: 1,
        title: "Test",
        description: "Test",
        status: "NEW",
        dateAdded: DateTime.now(),
        upvoteCount: 0,
        authorName: "Test",
        place: "Test",
        commentCount: 0,
        isUpvoted: false,
      );

      // ACT:
      final updatedReport = originalReport.copyWith(
        upvoteCount: 1,
        isUpvoted: true,
      );

      // ASSERT:
      expect(updatedReport.id, 1);
      expect(updatedReport.title, "Test");
      expect(updatedReport.upvoteCount, 1);
      expect(updatedReport.isUpvoted, true);

      // Důležité:
      expect(originalReport.upvoteCount, 0);
    });
  });
}
