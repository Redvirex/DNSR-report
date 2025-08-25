import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  /// Checks if location services are enabled and permissions are granted
  /// Returns true if location can be accessed
  Future<bool> isLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Gets the current GPS location of the device
  /// Returns null if location cannot be obtained due to permissions or service availability
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await isLocationEnabled();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return position;
    } catch (e) {
      log('Error getting location: $e');
      return null;
    }
  }

  /// Requests location permission from the user
  /// Returns the permission status after the request
  Future<LocationPermissionStatus> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
