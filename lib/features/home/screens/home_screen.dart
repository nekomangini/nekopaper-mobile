import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import '../../../data/models/category_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<CategoryModel> categories = [
    CategoryModel(
      name: 'Abstract',
      route: 'abstract',
      imagePath: 'assets/abstract/radiant/yellow_004.webp',
    ),
    CategoryModel(
      name: 'Anime',
      route: 'anime',
      imagePath: 'assets/anime/chainsaw-man/makima_001.webp',
    ),
    CategoryModel(
      name: 'Arts',
      route: 'arts',
      imagePath: 'assets/arts/character-art/character_art_027.webp',
    ),
    CategoryModel(
      name: 'Cars',
      route: 'cars',
      imagePath: 'assets/cars/cars_009.webp',
    ),
    CategoryModel(
      name: 'Cats',
      route: 'cats',
      imagePath: 'assets/cats/cats_005.webp',
    ),
    CategoryModel(
      name: 'Dogs',
      route: 'dogs',
      imagePath: 'assets/dogs/dogs_001.webp',
    ),
    CategoryModel(
      name: 'Environment',
      route: 'environment',
      imagePath: 'assets/environment/environment_005.webp',
    ),
    CategoryModel(
      name: 'Games',
      route: 'games',
      imagePath: 'assets/games/games_008.webp',
    ),
    CategoryModel(
      name: 'Mecha',
      route: 'mecha',
      imagePath: 'assets/mecha/mecha_001.webp',
    ),
    CategoryModel(
      name: 'Neon',
      route: 'neon',
      imagePath: 'assets/neon/neon_001.webp',
    ),
    CategoryModel(
      name: 'Others',
      route: 'others',
      imagePath: 'assets/others/others_001.webp',
    ),
    CategoryModel(
      name: 'Space',
      route: 'space',
      imagePath: 'assets/space/space_002.webp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF282828),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFFFABD2F),
        title: Text('ネコpaper'),
        shadowColor: Colors.black.withValues(alpha: 0.9),
        scrolledUnderElevation: 10,
        elevation: 10,
      ),
      backgroundColor: const Color(0xFF282828),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Categories",
                      style: TextStyle(
                        color: Color(0xFFFABD2F),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Browse ${categories.length} categories",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // The List (One Column)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    // Mimics the 'mainAxisSpacing' we had in the grid
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: SizedBox(
                      height: 300, // Fixed height for a consistent list feel
                      child: CategoryCard(category: categories[index]),
                    ),
                  );
                }, childCount: categories.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
