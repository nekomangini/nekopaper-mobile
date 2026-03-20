import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nekopaper_mobile/data/models/category_model.dart';
import 'package:nekopaper_mobile/core/utils/github_helper.dart';
import 'package:nekopaper_mobile/features/home/screens/gallery_screen.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  // Defining the gray color from your CSS: 96, 99, 106
  final Color cssGray = const Color.fromRGBO(96, 99, 106, 1.0);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Matches: border: 1px solid rgba(var(--gray-light), 0.1);
          // 140, 140, 140 = 0xFF8C8C8C
          border: Border.all(
            color: const Color(0xFF8C8C8C).withValues(alpha: 0.1),
          ),
          boxShadow: [
            // Layer 1: 0 2px 6px rgba(var(--gray), 25%)
            BoxShadow(
              color: cssGray.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            // Layer 2: 0 8px 24px rgba(var(--gray), 33%)
            BoxShadow(
              color: cssGray.withValues(alpha: 0.33),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            // Layer 3: 0 16px 32px rgba(var(--gray), 33%)
            BoxShadow(
              color: cssGray.withValues(alpha: 0.33),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: GithubHelper.getRawUrl(category.imagePath),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFABD2F)),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: const Color(0xFF1A1A1A),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFABD2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
