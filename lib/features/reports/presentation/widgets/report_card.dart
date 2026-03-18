import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String building;
  final String statusText;
  final Color statusColor;
  final String rating;
  final String comments;

  const ReportCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.building,
    required this.statusText,
    required this.statusColor,
    required this.rating,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HLAVIČKA ---
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0E0E0),
                radius: 18,
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Eliška Borýsková", // Změněno podle Figmy :)
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$date • $building",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- TĚLO ---
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatPill(rating, Icons.star_border),
                  const SizedBox(width: 8),
                  _buildStatPill(comments, Icons.chat_bubble_outline),
                ],
              ),

              const SizedBox(width: 8),
              // Status Pilulka (plná barva, tmavý text)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Trochu víc místa do stran podle Figmy
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor, // Plná barva bez průhlednosti
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: AppColors.textOnWhite, // Černý/tmavý text
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Trošku zvětšeno
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pomocná metoda pro vykreslení těch malých pilulek s hvězdičkou a bublinou
  Widget _buildStatPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.textOnWhite.withOpacity(0.1),
        ), // Lehký rámeček
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textOnWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 18, color: AppColors.textOnWhite),
        ],
      ),
    );
  }
}
