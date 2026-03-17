class WallpaperModel {
  final String title;
  final String slug;
  final String category;
  final String imagePath; // e.g., 'assets/anime/batman/batman_001.webp'

  WallpaperModel({
    required this.title,
    required this.slug,
    required this.category,
    required this.imagePath,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      title: json['title'] ?? 'Untitled',
      slug: json['slug'] ?? '',
      category: json['category'] ?? 'Other',
      imagePath: json['imagePath'] ?? '',
    );
  }
}
