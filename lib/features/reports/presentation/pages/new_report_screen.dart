import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/reports_service.dart';

enum Severity { light, medium, heavy }

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Severity _selectedSeverity = Severity.light;

  final ReportsService _reportsService = ReportsService();
  bool _isSubmitting = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _problemController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Funkce pro výběr fotky z galerie
  Future<void> _pickImage() async {
    // Můžeš změnit na ImageSource.camera, pokud chceš primárně foťák
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Načtení překladů
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textOnWhite,
                size: 18,
              ),
              Text(
                l10n.back,
                style: const TextStyle(
                  color: AppColors.textOnWhite,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          l10n.newReportTitle,
          style: const TextStyle(
            color: AppColors.textOnWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PŘIDAT FOTKU ---
            InkWell(
              onTap: _pickImage, // Spustí výběr fotky
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                // Pokud je vybraná fotka, kontejner se jí přizpůsobí, jinak dáme pevnou výšku (vycpávku)
                padding: _selectedImage == null
                    ? const EdgeInsets.symmetric(vertical: 32)
                    : null,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: _selectedImage != null
                    // A. Pokud MÁME fotku -> Zobrazíme ji s kulatými rohy
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          height: 200, // Pevná výška náhledu
                          width: double.infinity,
                        ),
                      )
                    // B. Pokud NEMÁME fotku -> Zobrazíme tlačítko PLUS
                    : Column(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 20,
                            child: Icon(Icons.add, color: AppColors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.addPhoto,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addPhotoHint,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 2. SPECIFIKACE PROBLÉMU ---
            Text(
              l10n.problemSpecification,
              style: const TextStyle(
                color: AppColors.textOnWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: _inputDecoration(l10n.problemHint),
            ),

            const SizedBox(height: 16),

            // --- 3. LOKACE ---
            TextField(
              controller: _locationController,
              decoration: _inputDecoration(l10n.locationHint).copyWith(
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 4. ZÁVAŽNOST HLÁŠENÍ ---
            Text(
              l10n.severity,
              style: const TextStyle(
                color: AppColors.textOnWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Mapujeme texty na Enum hodnoty
            _buildRadioOption(l10n.severityLight, Severity.light),
            _buildRadioOption(l10n.severityMedium, Severity.medium),
            _buildRadioOption(l10n.severityHeavy, Severity.heavy),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_problemController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a problem description.',
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isSubmitting = true;
                        });

                        bool success = await _reportsService.submitReport(
                          title: _problemController.text.split('\n')[0],
                          description: _problemController.text,
                          email: "test@mendelu.cz",
                        );

                        setState(() {
                          _isSubmitting = false;
                        });

                        if (success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  ' Report submitted successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error submitting the report.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(
                        l10n.submit,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  // Upravená metoda pro přepínač, používá Enum pro logiku, ale překlad pro zobrazení
  Widget _buildRadioOption(String title, Severity value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSeverity = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<Severity>(
                value: value,
                groupValue: _selectedSeverity,
                activeColor: AppColors.primary,
                onChanged: (Severity? newValue) {
                  setState(() {
                    _selectedSeverity = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textOnWhite,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
