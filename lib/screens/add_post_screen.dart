import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prj_kulinerkito/screens/map_screen.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final picker = ImagePicker();
  LatLng? _pickedLocation;

  Future<void> _pickImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                _getImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                _getImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _pickLocation() async {
    final location = Location();
    final currentLocation = await location.getLocation();
    final initialLocation =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: initialLocation,
          onLocationPicked: (location) {
            _pickedLocation = location;
            _locationController.text =
                'Lat: ${location.latitude}, Lng: ${location.longitude}';
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _locationController.text =
            'Lat: ${result.latitude}, Lng: ${result.longitude}';
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_image == null ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _hoursController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now()}.jpg');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to post')),
        );
        return;
      }

      FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'locationLink':
            'https://www.google.com/maps/search/?api=1&query=${_pickedLocation?.latitude},${_pickedLocation?.longitude}',
        'hours': _hoursController.text,
        'username': user.email ?? 'Anonymous',
      });

      // Navigate to home screen after successful post
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                clearImage();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => _pickImage(context),
                  child: const Text('Pilih Gambar'),
                ),
              ),
              const SizedBox(height: 20),
              if (_image != null)
                Center(
                  child: FutureBuilder(
                    future: Future.delayed(const Duration(seconds: 3)),
                    builder: (c, s) => s.connectionState == ConnectionState.done
                        ? Image.file(_image!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,)
                        : const CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Tempat',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      onTap: _pickLocation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Jam Operasional',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadPost,
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
