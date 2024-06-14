import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final void Function(LatLng) onLocationPicked;

  const MapScreen({
    required this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 16,
        ),
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('picked-location'),
                  position: _pickedLocation!,
                ),
              },
        onTap: (location) {
          setState(() {
            _pickedLocation = location;
          });
          widget.onLocationPicked(location);
          Navigator.of(context).pop(location);
        },
      ),
    );
  }
}
