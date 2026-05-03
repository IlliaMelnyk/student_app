import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/reports_viewmodel.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLocalLoading = false;

  @override
  void dispose() {
    _problemController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<ReportsViewModel>();

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
            _buildPhotoPicker(l10n),
            const SizedBox(height: 32),
            Text(l10n.problemSpecification, style: _labelStyle()),
            const SizedBox(height: 12),
            TextField(
              controller: _problemController,
              maxLines: 4,
              decoration: _inputDecoration(l10n.problemHint),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration(l10n.locationHint).copyWith(
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(viewModel, l10n),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
    color: AppColors.textOnWhite,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  Widget _buildPhotoPicker(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: _selectedImage == null
            ? const EdgeInsets.symmetric(vertical: 32)
            : null,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              )
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton(ReportsViewModel viewModel, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLocalLoading
            ? null
            : () async {
                if (_problemController.text.trim().isEmpty) return;
                setState(() => _isLocalLoading = true);

                // ZMĚNA: Voláme metodu už jen se 3 parametry
                final success = await viewModel.addReport(
                  _problemController.text.split('\n')[0], // Title
                  _problemController.text, // Description
                  _locationController.text, // Place
                );

                setState(() => _isLocalLoading = false);
                if (success && mounted) Navigator.of(context).pop();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLocalLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : Text(
                l10n.submit,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
}
