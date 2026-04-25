import 'package:flutter/material.dart';
import 'package:student_app/features/news/data/models/faculties_model.dart';
import '../../../../core/utils/shared_prefs_service.dart';

class NewsSettingsScreen extends StatefulWidget {
  const NewsSettingsScreen({super.key});

  @override
  State<NewsSettingsScreen> createState() => _NewsSettingsScreenState();
}

class _NewsSettingsScreenState extends State<NewsSettingsScreen> {
  final SharedPrefsService _prefs = SharedPrefsService();

  List<int> _initialFacultyIds = [];
  List<int> _initialGroupIds = [];

  List<int> _selectedFacultyIds = [];
  List<int> _selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final fIds = await _prefs.getSelectedFaculties();
    final gIds = await _prefs.getSelectedGroups();
    setState(() {
      _initialFacultyIds = List.from(fIds);
      _initialGroupIds = List.from(gIds);
      _selectedFacultyIds = List.from(fIds);
      _selectedGroupIds = List.from(gIds);
    });
  }

  bool _listsMatch(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }

  bool get hasChanges {
    return !_listsMatch(_initialFacultyIds, _selectedFacultyIds) ||
        !_listsMatch(_initialGroupIds, _selectedGroupIds);
  }

  void _saveSettings() async {
    await _prefs.saveSelectedFaculties(_selectedFacultyIds);
    await _prefs.saveSelectedGroups(_selectedGroupIds);
    if (mounted) Navigator.pop(context, true);
  }

  void _handleBackNavigation(bool didPop) async {
    if (didPop) return;

    if (!hasChanges) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Neuložené změny",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Máte neuložené změny ve filtrech. Chcete je aplikovat?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Zahodit",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Aplikovat",
                style: TextStyle(
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      _saveSettings();
    } else if (shouldSave == false) {
      if (mounted) Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7B61FF);

    return PopScope(
      canPop: false,
      onPopInvoked: _handleBackNavigation,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E2C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Nastavení novinek",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => _handleBackNavigation(false),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 20),
                  _buildHeader("Součásti"),
                  _buildToggleAll(
                    "Zvolit všechny",
                    facultyOptions,
                    _selectedFacultyIds,
                  ),
                  ...facultyOptions.map(
                    (opt) => _buildSelectionRow(
                      opt,
                      _selectedFacultyIds,
                      primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildHeader("Skupiny"),
                  _buildToggleAll(
                    "Zvolit všechny",
                    groupOptions,
                    _selectedGroupIds,
                  ),
                  ...groupOptions.map(
                    (opt) => _buildSelectionRow(
                      opt,
                      _selectedGroupIds,
                      primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildToggleAll(
    String title,
    List<FacultyOption> allOptions,
    List<int> currentSelection,
  ) {
    bool isAllSelected =
        currentSelection.length == allOptions.length && allOptions.isNotEmpty;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      value: isAllSelected,
      activeColor: const Color(0xFF7B61FF),
      onChanged: (bool value) {
        setState(() {
          currentSelection.clear();
          if (value) currentSelection.addAll(allOptions.map((e) => e.id));
        });
      },
    );
  }

  Widget _buildSelectionRow(
    FacultyOption option,
    List<int> selectionList,
    Color activeColor,
  ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        option.name,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      secondary: SizedBox(
        width: 30,
        child: Image.asset(
          option.iconAsset,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.school, color: Colors.white54),
        ),
      ),
      value: selectionList.contains(option.id),
      activeColor: activeColor,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectionList.add(option.id);
          } else {
            selectionList.remove(option.id);
          }
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges
              ? const Color(0xFF7B61FF)
              : Colors.grey.shade800,
          disabledBackgroundColor: Colors.grey.shade800,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: hasChanges ? _saveSettings : null,
        child: Text(
          "Uložit filtry",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: hasChanges ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}
