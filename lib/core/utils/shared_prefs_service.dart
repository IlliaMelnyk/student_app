import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _keySelectedFaculties = 'selected_faculties';
  static const String _keySelectedGroups = 'selected_groups';

  Future<void> saveSelectedFaculties(List<int> facultyIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keySelectedFaculties,
      facultyIds.map((e) => e.toString()).toList(),
    );
  }

  Future<List<int>> getSelectedFaculties() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_keySelectedFaculties);
    if (list == null) return [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> saveSelectedGroups(List<int> groupIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keySelectedGroups,
      groupIds.map((e) => e.toString()).toList(),
    );
  }

  Future<List<int>> getSelectedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_keySelectedGroups);
    return list?.map((e) => int.parse(e)).toList() ?? [];
  }

  Future<void> saveUpvotedReportId(int reportId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> upvoted = prefs.getStringList('upvoted_reports') ?? [];

    if (!upvoted.contains(reportId.toString())) {
      upvoted.add(reportId.toString());
      await prefs.setStringList('upvoted_reports', upvoted);
    }
  }

  Future<List<int>> getUpvotedReportIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> upvoted = prefs.getStringList('upvoted_reports') ?? [];
    return upvoted.map((e) => int.parse(e)).toList();
  }

  Future<void> removeUpvotedReportId(int reportId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> upvoted = prefs.getStringList('upvoted_reports') ?? [];

    if (upvoted.contains(reportId.toString())) {
      upvoted.remove(reportId.toString());
      await prefs.setStringList('upvoted_reports', upvoted);
    }
  }
}
