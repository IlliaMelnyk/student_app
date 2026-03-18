import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedStars = 0;
  bool _isClosing = false;

  void _handleStarTap(int index) {
    if (_isClosing) return;

    setState(() {
      _selectedStars = index + 1;
      _isClosing = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context, _selectedStars);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text(
                    "0",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.star_border,
                    size: 20,
                    color: AppColors.background,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            ...List.generate(5, (index) {
              bool isSelected = index < _selectedStars;

              return GestureDetector(
                onTap: () => _handleStarTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.5),
                    size: 32,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
