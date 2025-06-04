import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


/// Helper class to initialize Google Maps
class MapInitializer {
  /// Initialize Google Maps with proper renderers and settings
  static Future<void> initialize() async {
    // Set Android renderer
    final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      try {
        mapsImplementation.useAndroidViewSurface = true;
      } catch (e) {
        debugPrint('Error initializing Google Maps for Android: $e');
      }
    }
  }
}
