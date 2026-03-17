import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/models/wallpaper_model.dart';
import '../../../core/utils/github_helper.dart';

class WallpaperDetailsScreen extends StatelessWidget {
  final WallpaperModel wallpaper;
  const WallpaperDetailsScreen({super.key, required this.wallpaper});

  String get cleanWallpaperName {
    return wallpaper.title
        .replaceAll(RegExp(r'\.[^/.]+$'), "")
        .replaceAll(RegExp(r'[_-]+'), " ")
        .replaceAll(RegExp(r'\s\d+$'), "")
        .trim()
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = GithubHelper.getRawUrl(wallpaper.imagePath);

    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFABD2F)),
          onPressed: () => Navigator.pop(context),
        ),
        // TODO:
        title: Text(
          "Back to ${wallpaper.category}",
          style: const TextStyle(color: Color(0xFFFABD2F), fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.black,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFABD2F)),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallpaper.title,
                    style: const TextStyle(
                      color: Color(0xFFFABD2F),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag(wallpaper.category, isPrimary: true),
                      _buildTag("ネコpaper"),
                      _buildTag(cleanWallpaperName),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // DOWNLOAD BUTTON
                  _buildActionButton(
                    label: "Download",
                    icon: Icons.download_rounded,
                    color: const Color(0xFFFABD2F),
                    textColor: Colors.black,
                    onPressed: () async {
                      // 1. Show the initial snackbar immediately (no await yet, so context is safe)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Downloading to gallery..."),
                        ),
                      );

                      try {
                        // 2. Perform the async network call
                        var response = await Dio().get(
                          imageUrl,
                          options: Options(responseType: ResponseType.bytes),
                        );

                        // 3. Perform the async save call
                        final result = await ImageGallerySaverPlus.saveImage(
                          Uint8List.fromList(response.data),
                          quality: 100,
                          name: wallpaper.slug,
                        );

                        // GUARD: Check if the user is still on this screen before using context
                        if (!context.mounted) return;

                        if (result != null && result['isSuccess'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saved to Gallery!")),
                          );
                        }
                      } catch (e) {
                        // GUARD: Check again here because the catch block is also after an await
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // SHARE BUTTON
                  _buildActionButton(
                    label: "Share",
                    icon: Icons.share_rounded,
                    color: const Color(0xFF3C3836),
                    textColor: const Color(0xFFFABD2F),
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Preparing share...")),
                        );

                        final response = await Dio().get(
                          imageUrl,
                          options: Options(responseType: ResponseType.bytes),
                        );

                        final tempDir = await getTemporaryDirectory();
                        final tempFile = File(
                          '${tempDir.path}/${wallpaper.slug}.jpg',
                        );
                        await tempFile.writeAsBytes(response.data);

                        if (!context.mounted) return;

                        // ✅ Modern share_plus API
                        await SharePlus.instance.share(
                          ShareParams(
                            text:
                                "Check out this wallpaper: ${wallpaper.title}",
                            files: [XFile(tempFile.path)],
                            subject: wallpaper.title,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Could not share: $e")),
                        );
                      }
                    },
                    border: true,
                  ),
                  const SizedBox(height: 12),

                  // KO-FI BUTTON
                  _buildActionButton(
                    label: "Support on Ko-fi",
                    icon: Icons.coffee_rounded,
                    color: const Color(0xFF29ABE0),
                    textColor: Colors.white,
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://ko-fi.com/nekomangini',
                      );
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw Exception('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFFABD2F) : const Color(0xFF3C3836),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool border = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border
                ? const BorderSide(color: Color(0xFFFABD2F))
                : BorderSide.none,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
