import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nekopaper_mobile/features//home/screens/wallpaper_details_screen.dart';

import 'package:nekopaper_mobile/data/models/category_model.dart';
import 'package:nekopaper_mobile/data/models/wallpaper_model.dart';
import 'package:nekopaper_mobile/core/utils/github_helper.dart';

class GalleryScreen extends StatefulWidget {
  final CategoryModel category;
  const GalleryScreen({super.key, required this.category});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int currentPage = 1;
  final int itemsPerPage = 12;
  final Color cssGray = const Color.fromRGBO(96, 99, 106, 1.0);

  // Dynamic state variables
  List<WallpaperModel> allWallpapers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchWallpapers();
  }

  Future<void> _fetchWallpapers() async {
    try {
      final response = await http.get(Uri.parse(GithubHelper.jsonUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> wallpaperList = data['wallpapers'];

        // 1. Process data OUTSIDE setState to keep UI thread snappy
        final filteredWallpapers = wallpaperList
            .map((item) => WallpaperModel.fromJson(item))
            .where((wp) {
              return wp.category.trim().toLowerCase() ==
                  widget.category.name.trim().toLowerCase();
            })
            .toList();

        // 2. Log high-level summary only
        if (kDebugMode) {
          print(
            "DEBUG: Category '${widget.category.name}' -> Found ${filteredWallpapers.length} matches.",
          );
        }

        // 3. Only update state with the final result
        if (mounted) {
          setState(() {
            allWallpapers = filteredWallpapers;
            isLoading = false;
          });
        }
      } else {
        throw Exception(
          "Failed to load wallpapers (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Handle Loading State
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF282828),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFABD2F)),
        ),
      );
    }

    // 2. Handle Error State
    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Color(0xFF282828),
        body: Center(
          child: Text(
            "Error: $errorMessage",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // 3. Handle Empty State
    if (allWallpapers.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF282828),
        appBar: AppBar(),
        body: const Center(
          child: Text(
            "No wallpapers found in this category.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // 4. Existing Pagination Logic
    final int totalPages = (allWallpapers.length / itemsPerPage).ceil();
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    final paginatedItems = allWallpapers.sublist(
      startIndex,
      endIndex > allWallpapers.length ? allWallpapers.length : endIndex,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 8,
        elevation: 4,
        shadowColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFABD2F)),
        title: Text(
          widget.category.name,
          style: const TextStyle(color: Color(0xFFFABD2F)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Showing ${paginatedItems.length} of ${allWallpapers.length} wallpapers",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 32.0,
                    ), // Increased for shadow room
                    child: _buildImageListCard(paginatedItems[index]),
                  );
                },
              ),
            ),
            _buildPagination(totalPages),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageListCard(WallpaperModel wp) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperDetailsScreen(wallpaper: wp),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Matches border: 1px solid rgba(var(--gray-light), 0.1);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: GithubHelper.getRawUrl(wp.imagePath),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                color: const Color(0xFF1A1A1A),
                child: Text(
                  wp.title,
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

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFABD2F)),
            onPressed: currentPage > 1
                ? () => setState(() => currentPage--)
                : null,
          ),
          const SizedBox(width: 15),
          Text(
            "Page $currentPage of $totalPages",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Color(0xFFFABD2F)),
            onPressed: currentPage < totalPages
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}
