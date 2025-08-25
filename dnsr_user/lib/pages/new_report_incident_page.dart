import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'dart:developer';

class NewReportIncidentPage extends StatefulWidget {
  const NewReportIncidentPage({super.key});

  @override
  State<NewReportIncidentPage> createState() => _NewReportIncidentPageState();
}

class _NewReportIncidentPageState extends State<NewReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedIncidentCategory;
  String? _selectedIncidentType;
  String? _selectedVehicleType;
  int? _selectedCategoryId;
  int? _selectedIncidentTypeId;
  int? _selectedVehicleTypeId;
  bool _showIncidentTypeDropdown = false;
  bool _showVehicleTypeDropdown = false;
  bool _isLoading = true;
  bool _isGettingLocation = false;
  bool _isUploadingPhotos = false;
  bool _isUpdatingUserLocation = false;

  double? _latitude;
  double? _longitude;
  String? _locationError;

  final List<File> _selectedPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _incidentCategories = [];
  List<Map<String, dynamic>> _incidentTypes = [];
  List<Map<String, dynamic>> _vehicleTypes = [];

  final List<int> _categoriesRequiringVehicle = [1, 2];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Loads incident categories, types, and vehicle types from the database
  Future<void> _loadData() async {
    try {
      final incidentCategoriesData = await SupabaseService.instance
          .getIncidentCategories();
      final vehicleTypesData = await SupabaseService.instance.getVehicleTypes();

      setState(() {
        _incidentCategories = incidentCategoriesData;
        _vehicleTypes = vehicleTypesData;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles location permissions and requests
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled.';
      });
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permissions are denied';
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permissions are permanently denied';
      });
      return false;
    }

    return true;
  }

  /// Gets current GPS location
  Future<void> _getCurrentPosition() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
        _locationError = null;
      });

      _updateUserLocationInBackground();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location obtained: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _locationError = 'Failed to get location: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Picks image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo added! Total: ${_selectedPhotos.length}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Removes photo at specified index
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  /// Uploads photos to Supabase storage
  Future<List<String>> _uploadPhotosToSupabase() async {
    List<String> uploadedUrls = [];

    setState(() {
      _isUploadingPhotos = true;
    });

    try {
      for (int i = 0; i < _selectedPhotos.length; i++) {
        final file = _selectedPhotos[i];
        final fileName =
            'incident_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        final url = await SupabaseService.instance.uploadIncidentPhoto(
          file,
          fileName,
        );
        uploadedUrls.add(url);
      }

      setState(() {
        _isUploadingPhotos = false;
      });

      return uploadedUrls;
    } catch (e) {
      setState(() {
        _isUploadingPhotos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photos: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return [];
    }
  }

  /// Handles incident category selection
  void _onIncidentCategoryChanged(String? newValue) async {
    if (newValue == null) return;

    final selectedCategory = _incidentCategories.firstWhere(
      (category) => category['title'] == newValue,
    );

    setState(() {
      _selectedIncidentCategory = newValue;
      _selectedCategoryId = selectedCategory['id'] as int;
      _selectedIncidentType = null;
      _selectedVehicleType = null;
      _showIncidentTypeDropdown = false;
      _showVehicleTypeDropdown = false;
      _incidentTypes = [];
    });

    try {
      final incidentTypesData = await SupabaseService.instance
          .getIncidentTypesByCategory(_selectedCategoryId!);
      setState(() {
        _incidentTypes = incidentTypesData;
        _showIncidentTypeDropdown = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading incident types: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles incident type selection
  void _onIncidentTypeChanged(String? newValue) {
    if (newValue == null) {
      setState(() {
        _selectedIncidentType = null;
        _selectedIncidentTypeId = null;
        _selectedVehicleType = null;
        _selectedVehicleTypeId = null;
        _showVehicleTypeDropdown = false;
      });
      return;
    }

    final selectedIncidentType = _incidentTypes.firstWhere(
      (incidentType) => incidentType['title'] == newValue,
    );

    setState(() {
      _selectedIncidentType = newValue;
      _selectedIncidentTypeId = selectedIncidentType['id'] as int;
      _selectedVehicleType = null;
      _selectedVehicleTypeId = null;

      _showVehicleTypeDropdown =
          _selectedCategoryId != null &&
          _categoriesRequiringVehicle.contains(_selectedCategoryId!);
    });
  }

  /// Handles vehicle type selection
  void _onVehicleTypeChanged(String? newValue) {
    if (newValue == null) {
      setState(() {
        _selectedVehicleType = null;
        _selectedVehicleTypeId = null;
      });
      return;
    }

    final selectedVehicleType = _vehicleTypes.firstWhere(
      (vehicleType) => vehicleType['title'] == newValue,
    );

    setState(() {
      _selectedVehicleType = newValue;
      _selectedVehicleTypeId = selectedVehicleType['id'] as int;
    });
  }

  /// Updates user location in background
  Future<void> _updateUserLocationInBackground() async {
    setState(() {
      _isUpdatingUserLocation = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userProfile?.id;

      if (userId != null && _latitude != null && _longitude != null) {
        await SupabaseService.instance.updateUserLocation(
          userId: userId,
          latitude: _latitude!,
          longitude: _longitude!,
        );
      }
    } catch (e) {
      log('Background user location update failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingUserLocation = false;
        });
      }
    }
  }

  /// Submits the incident report
  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPhotos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoRequiredError),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationMandatoryError),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );

        await _getCurrentPosition();
        return;
      }

      if (_selectedIncidentTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSelectIncidentType),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (_showVehicleTypeDropdown && _selectedVehicleTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSelectVehicleType),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final photoUrls = await _uploadPhotosToSupabase();

        if (photoUrls.isEmpty && mounted) {
          throw Exception('Failed to upload photos');
        }

        await SupabaseService.instance.submitIncidentReport(
          typeIncidentId: _selectedIncidentTypeId!,
          typeVehiculeId: _selectedVehicleTypeId,
          description: _descriptionController.text.trim().isEmpty
              ? ''
              : _descriptionController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
          photoUrls: photoUrls,
        );

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.incidentReportSubmitted),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.of(context).pop(); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD4A017);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: MediaQuery.of(context).size.height * 0.12,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Stack(
                children: [
                  // Centered title
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.reportIncident,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Back arrow positioned on the left
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Rounded Container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F8ED),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(AppLocalizations.of(context)!.loadingIncidentCategories),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and description
                            Text(
                              AppLocalizations.of(context)!.reportRouteIncident,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.provideIncidentDetails,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Form content
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Incident Category
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.incidentCategory,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: bgColor.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        hint: Text(AppLocalizations.of(context)!.selectIncidentCategory),
                                        value: _selectedIncidentCategory,
                                        items: _incidentCategories.map((
                                          category,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: category['title'],
                                            child: Text(category['title']),
                                          );
                                        }).toList(),
                                        onChanged: _onIncidentCategoryChanged,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)!.pleaseSelectIncidentCategory;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Incident Type
                                    if (_showIncidentTypeDropdown) ...[
                                      Text(
                                        AppLocalizations.of(context)!.incidentType,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: bgColor.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          
                                          hint: Text(AppLocalizations.of(context)!.selectIncidentType),
                                          value: _selectedIncidentType,
                                          items: _incidentTypes.map((type) {
                                            return DropdownMenuItem<String>(
                                              value: type['title'],
                                              child: Text(type['title']),
                                            );
                                          }).toList(),
                                          onChanged: _onIncidentTypeChanged,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(context)!.pleaseSelectIncidentType;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    // Car Type (Vehicle Type)
                                    if (_showVehicleTypeDropdown) ...[
                                      Text(
                                        AppLocalizations.of(context)!.carType,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: bgColor.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          
                                          hint: Text(AppLocalizations.of(context)!.selectVehicleType),
                                          value: _selectedVehicleType,
                                          isExpanded: true,
                                          items: _vehicleTypes.map((type) {
                                            return DropdownMenuItem<String>(
                                              value: type['title'],
                                              child: Text(
                                                type['title'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: _onVehicleTypeChanged,
                                          validator: (value) {
                                            if (_showVehicleTypeDropdown &&
                                                (value == null ||
                                                    value.isEmpty)) {
                                              return AppLocalizations.of(context)!.pleaseSelectVehicleType;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    // Description
                                    Text(
                                      AppLocalizations.of(context)!.descriptionOptional,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: bgColor.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextFormField(
                                        controller: _descriptionController,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                          hintText:
                                              "Describe the incident in detail",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Photos section
                                    Text(
                                      AppLocalizations.of(context)!.photosOfIncident,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: bgColor.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: _selectedPhotos.isEmpty
                                          ? GestureDetector(
                                              onTap: _pickImageFromCamera,
                                              child: SizedBox(
                                                height: 150,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/add_image.png",
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      AppLocalizations.of(context)!.photoRequired,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                children: [
                                                  GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 8,
                                                          mainAxisSpacing: 8,
                                                        ),
                                                    itemCount:
                                                        _selectedPhotos.length,
                                                    itemBuilder: (context, index) {
                                                      return Stack(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              image: DecorationImage(
                                                                image: FileImage(
                                                                  _selectedPhotos[index],
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 4,
                                                            right: 4,
                                                            child: GestureDetector(
                                                              onTap: () =>
                                                                  _removePhoto(
                                                                    index,
                                                                  ),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      4,
                                                                    ),
                                                                child: const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                  GestureDetector(
                                                    onTap: _pickImageFromCamera,
                                                    child: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.blue,
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.blue,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            AppLocalizations.of(context)!.addMorePhotos,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Location section
                                    Text(
                                      AppLocalizations.of(context)!.locationOfIncident,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: bgColor.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          if (_latitude != null &&
                                              _longitude != null) ...[
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.green,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${AppLocalizations.of(context)!.locationObtained}\n${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            // Background location update indicator
                                            if (_isUpdatingUserLocation) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 12,
                                                    width: 12,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.green
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          strokeWidth: 1.5,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    AppLocalizations.of(context)!.updatingLocation,
                                                    style: TextStyle(
                                                      color: Colors.green
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ] else ...[
                                            Image.asset(
                                              "assets/images/location.png",
                                              height: 80,
                                              width: 80,
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!.locationMandatory,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: _isGettingLocation
                                                    ? null
                                                    : _getCurrentPosition,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: _isGettingLocation
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : Text(
                                                        AppLocalizations.of(context)!.getLocation,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                          if (_locationError != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              _locationError!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40),

                                    // Action buttons
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isUploadingPhotos
                                                ? null
                                                : _submitReport,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  _isUploadingPhotos
                                                  ? Colors.grey
                                                  : bgColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: _isUploadingPhotos
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        AppLocalizations.of(context)!.uploadingPhotos,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    AppLocalizations.of(context)!.reportNow,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bgColor
                                                  .withValues(alpha: 0.3),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.cancel,
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
