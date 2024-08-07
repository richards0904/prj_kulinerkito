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
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true; // Set loading to true before uploading
    });

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

      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'locationLink':
            'https://www.google.com/maps/search/?api=1&query=${_pickedLocation?.latitude},${_pickedLocation?.longitude}',
        'hours': _hoursController.text,
        'username': user.displayName ?? 'Anonymous',
        'authorId': user.uid,
      });

      // Navigate to home screen after successful post
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload post')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after uploading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.orange,
                          width: 1.0,
                        ),
                      ),
                      child: SizedBox(
                        width: 500,
                        child: InkWell(
                          onTap: () => _pickImage(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            child: const Text(
                              'Pilih Gambar',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_image != null)
                    Center(
                      child: FutureBuilder(
                        future: Future.delayed(const Duration(seconds: 3)),
                        builder: (c, s) => s.connectionState == ConnectionState.done
                            ? Image.file(
                                _image!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi Tempat',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(
                              8), // Optional: untuk memberi sudut border
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 36,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan deskripsi tempat ...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Tempat',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                          height:
                              8), // Untuk memberi sedikit jarak antara judul dan baris berikutnya
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(
                              8), // Optional: untuk memberi sudut border
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Ratakan ke kiri
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan Lokasi Tempat ...',
                                  border: InputBorder
                                      .none, // Hilangkan border TextField
                                ),
                                onTap: _pickLocation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jam Operasional',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(
                              8), // Optional: untuk memberi sudut border
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _hoursController,
                                decoration: const InputDecoration(
                                  hintText: '___:___',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 130),
                  Center(
                    child: SizedBox(
                      width: 500, // Sesuaikan lebarnya sesuai kebutuhan
                      child: ElevatedButton(
                        onPressed: _uploadPost,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue // Mengatur warna latar belakang tombol
                            ),
                        child: const Text('Posting',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
