import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'package:nekopaper_mobile/data/models/wallpaper_model.dart';
import 'package:nekopaper_mobile/core/utils/github_helper.dart';
import 'package:nekopaper_mobile/main.dart'; // for unityAdsReady

class WallpaperDetailsScreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  const WallpaperDetailsScreen({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailsScreen> createState() => _WallpaperDetailsScreenState();
}

class _WallpaperDetailsScreenState extends State<WallpaperDetailsScreen> {
  // ✅ Unity Ads placement ID — must match exactly in Unity dashboard
  static const String _placementId = 'Interstitial_Android';
  bool _isAdLoaded = false;

  String get cleanWallpaperName {
    return widget.wallpaper.title
        .replaceAll(RegExp(r'\.[^/.]+$'), "")
        .replaceAll(RegExp(r'[_-]+'), " ")
        .replaceAll(RegExp(r'\s\d+$'), "")
        .trim()
        .toLowerCase();
  }

  @override
  void initState() {
    super.initState();

    if (unityAdsReady.value) {
      // ✅ Small delay to let Unity Ads fully settle after init
      Future.delayed(const Duration(milliseconds: 500), _loadAd);
    } else {
      unityAdsReady.addListener(_onSdkReady);
    }
  }

  void _onSdkReady() {
    if (unityAdsReady.value) {
      unityAdsReady.removeListener(_onSdkReady);
      Future.delayed(const Duration(milliseconds: 500), _loadAd);
    }
  }

  @override
  void dispose() {
    unityAdsReady.removeListener(_onSdkReady);
    super.dispose();
  }

  void _loadAd() {
    UnityAds.load(
      placementId: _placementId,
      onComplete: (placementId) {
        debugPrint('Ad loaded ✅: $placementId');
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onFailed: (placementId, error, message) {
        debugPrint('Ad load failed: $message');
        if (mounted) setState(() => _isAdLoaded = false);
      },
    );
  }

  Future<void> _showAd() async {
    if (!_isAdLoaded) {
      debugPrint('Ad not ready, skipping');
      _loadAd(); // queue for next time
      return;
    }

    setState(() => _isAdLoaded = false);

    UnityAds.showVideoAd(
      placementId: _placementId,
      onStart: (placementId) => debugPrint('Ad started'),
      onSkipped: (placementId) {
        debugPrint('Ad skipped');
        _loadAd(); // preload next
      },
      onComplete: (placementId) {
        debugPrint('Ad completed ✅');
        _loadAd(); // preload next
      },
      onFailed: (placementId, error, message) {
        debugPrint('Ad show failed: $message');
        _loadAd(); // try again
      },
    );
  }

  // ─── Download logic ───────────────────────────────────────────────────────

  Future<void> _downloadImage(String imageUrl) async {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Downloading to gallery...")));

    try {
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: widget.wallpaper.slug,
      );

      if (!mounted) return;

      if (result != null && result['isSuccess'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Saved to Gallery! ✅")));

        // ✅ Show ad after successful download
        await _showAd();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String imageUrl = GithubHelper.getRawUrl(widget.wallpaper.imagePath);

    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFABD2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Back to ${widget.wallpaper.category}",
          style: const TextStyle(color: Color(0xFFFABD2F), fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.black,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFABD2F)),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.wallpaper.title,
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
                      _buildTag(widget.wallpaper.category, isPrimary: true),
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
                    onPressed: () => _downloadImage(imageUrl),
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
                          '${tempDir.path}/${widget.wallpaper.slug}.jpg',
                        );
                        await tempFile.writeAsBytes(response.data);

                        if (!context.mounted) return;

                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(tempFile.path)],
                            text:
                                "Check out this wallpaper: ${widget.wallpaper.title}",
                            subject: widget.wallpaper.title,
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
                      try {
                        final Uri url = Uri.parse(
                          'https://ko-fi.com/nekomangini',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
    required Future<void> Function() onPressed,
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
