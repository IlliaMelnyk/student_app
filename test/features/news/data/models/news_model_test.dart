import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/news/data/models/news_model.dart';

void main() {
  group('NewsModel - JSON Parsování a Jazykové Fallbacky', () {
    test('fromJson() - úspěšně naparsuje kompletní JSON v angličtině', () {
      final Map<String, dynamic> jsonMap = {
        "id": 10,
        "titleImageUrl": "https://example.com/image.jpg",
        "startDate": "2026-06-17T12:00:00Z",
        "localizedAttributes": {
          "en": {
            "title": "English Title",
            "text": "English Text",
            "unformattedText": "Raw Text",
          },
          "cz": {"title": "Český titulek"},
        },
        "category": [
          {
            "localizedAttributes": {
              "en": {"name": "Events"},
            },
          },
        ],
        "faculty": [
          {
            "id": 5,
            "localizedAttributes": {
              "en": {"name": "FRRMS"},
            },
          },
        ],
      };

      final result = NewsModel.fromJson(jsonMap, 'en');

      expect(result.id, 10);
      expect(result.title, "English Title");
      expect(result.categoryName, "Events");
      expect(result.facultyIds.first, 5);
    });

    test(
      'fromJson() - při chybějící angličtině aplikuje záchranný fallback na češtinu',
      () {
        final Map<String, dynamic> jsonMap = {
          "id": 20,
          "localizedAttributes": {
            "cz": {
              "title": "Pouze česky",
              "text": "Český text",
              "unformattedText": "Surový text",
            },
          },
        };

        final result = NewsModel.fromJson(jsonMap, 'en');
        expect(result.title, "Pouze česky");
        expect(result.text, "Český text");
      },
    );
  });
}
