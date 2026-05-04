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

  Future<List<int>> getUpvotedReportIds(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('upvotes_$userEmail') ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  Future<void> saveUpvotedReportId(int reportId, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('upvotes_$userEmail') ?? [];
    if (!list.contains(reportId.toString())) {
      list.add(reportId.toString());
      await prefs.setStringList('upvotes_$userEmail', list);
    }
  }

  Future<void> removeUpvotedReportId(int reportId, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('upvotes_$userEmail') ?? [];
    list.remove(reportId.toString());
    await prefs.setStringList('upvotes_$userEmail', list);
  }
}
