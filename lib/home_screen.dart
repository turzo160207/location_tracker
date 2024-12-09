import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    listenCurrentLocation();
  }

  void listenCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();

      if (isServiceEnabled) {
        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          updateLocationOnMap(pos);
        });
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        listenCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  void updateLocationOnMap(Position pos) {
    final newLatLng = LatLng(pos.latitude, pos.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newLatLng),
    );

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: newLatLng,
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet: 'Lat: ${pos.latitude}, Lon: ${pos.longitude}',
        ),
        onTap: () {
          _mapController?.showMarkerInfoWindow(const MarkerId('current_location'));
        },
      ),
    );

    if (_polylineCoordinates.isNotEmpty) {
      _polylineCoordinates.add(newLatLng);
    } else {
      _polylineCoordinates.add(newLatLng);
    }

    setState(() {
      position = pos;
    });
  }

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();

      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition();
        updateLocationOnMap(p);
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> checkGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracker'),
      ),
      body: position == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(position!.latitude, position!.longitude),
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('location_path'),
            color: Colors.blue,
            width: 5,
            points: _polylineCoordinates,
          ),
        },
      ),
    );
  }
}