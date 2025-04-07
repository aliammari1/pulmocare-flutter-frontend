import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapSelectionDialog extends StatefulWidget {
  final String initialAddress;
  const MapSelectionDialog({super.key, this.initialAddress = ''});

  @override
  _MapSelectionDialogState createState() => _MapSelectionDialogState();
}

class _MapSelectionDialogState extends State<MapSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
    _searchController.text = widget.initialAddress;
    _getLatLngFromAddress(widget.initialAddress);
  }

  Future<void> _getLatLngFromAddress(String address) async {
    if (address.trim().isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 14),
        );
      }
    } catch (_) {}
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
          _searchController.text = _selectedAddress;
        });
      }
    } catch (_) {}
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 16));
    await _updateAddressFromLatLng(_selectedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search location',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (value) => _getLatLngFromAddress(value),
                  ),
                ),
                // Map
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        controller.setMapStyle('''
                          [
                            {
                              "featureType": "poi",
                              "elementType": "labels",
                              "stylers": [
                                { "visibility": "on" }
                              ]
                            },
                            {
                              "featureType": "road",
                              "elementType": "labels",
                              "stylers": [
                                { "visibility": "on" }
                              ]
                            },
                            {
                              "featureType": "transit",
                              "elementType": "labels",
                              "stylers": [
                                { "visibility": "on" }
                              ]
                            }
                          ]
                        ''');
                      },
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ??
                            const LatLng(37.7749, -122.4194),
                        zoom: 12,
                      ),
                      mapType: _currentMapType,
                      trafficEnabled: _trafficEnabled,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: true,
                      buildingsEnabled: true,
                      onTap: (latLng) async {
                        setState(() => _selectedLocation = latLng);
                        await _updateAddressFromLatLng(latLng);
                      },
                      markers: _selectedLocation == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId('picked_location'),
                                position: _selectedLocation!,
                              ),
                            },
                    ),
                  ),
                ),
              ],
            ),
            // Map Controls
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Type Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _currentMapType == MapType.normal
                            ? Icons.map_outlined
                            : Icons.satellite_alt,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMapType = _currentMapType == MapType.normal
                              ? MapType.satellite
                              : MapType.normal;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Traffic Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.traffic,
                        size: 20,
                        color: _trafficEnabled ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _trafficEnabled = !_trafficEnabled;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Location Button
            Positioned(
              left: 16,
              bottom: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _locateUser,
                ),
              ),
            ),

            // Confirm Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context, _selectedAddress);
                },
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
