import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

  /// Get wilaya (province) name from coordinates using reverse geocoding
  /// Returns the administrative area (wilaya) for Algerian coordinates
  Future<String?> getWilayaFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print('🌍 LocationService: Getting wilaya for coordinates: $latitude, $longitude');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // In Algeria, administrativeArea usually contains the wilaya
        String? wilaya = placemark.administrativeArea;

        print('✅ LocationService: Found wilaya: $wilaya');
        print('📍 LocationService: Full placemark details:');
        print('   - locality: ${placemark.locality}');
        print('   - subLocality: ${placemark.subLocality}');
        print('   - administrativeArea: ${placemark.administrativeArea}');
        print('   - subAdministrativeArea: ${placemark.subAdministrativeArea}');
        print('   - country: ${placemark.country}');
        print('   - postalCode: ${placemark.postalCode}');
        print('   - street: ${placemark.street}');

        return wilaya;
      }

      print('⚠️ LocationService: No placemarks found');
      return null;
    } catch (e) {
      print('❌ LocationService: Error getting wilaya: $e');
      return null;
    }
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
