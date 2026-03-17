import 'package:flutter/foundation.dart';

class GithubHelper {
  // Ensure the base URL ends with /src
  static const String baseUrl =
      "https://raw.githubusercontent.com/nekomangini/nekopaper/main/src";

  static String getRawUrl(String path) {
    // 1. Clean up the path (remove leading slashes or ../)
    String cleanPath = path.replaceAll('../', '');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // 2. Combine them with a single slash
    final finalUrl = "$baseUrl/$cleanPath";

    // 3. Debugging: This will print the URL in your console so you can click it!
    if (kDebugMode) {
      print("Fetching Image: $finalUrl");
    }

    return finalUrl;
  }

  static const String jsonUrl =
      "https://raw.githubusercontent.com/nekomangini/nekopaper/refs/heads/main/public/wallpapers.json";
}
