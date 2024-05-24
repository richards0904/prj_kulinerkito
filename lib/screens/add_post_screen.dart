import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/screens/home_screen.dart';

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

  Future getImage(ImageSource source) async {
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
        'hours': _hoursController.text,
        'username': user.email ?? 'Anonymous',
      });

      // Navigate to home screen after successful post
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      print(e);
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
            Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_a_photo, size: 50),
                    onPressed: () => getImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.photo_library, size: 50),
                    onPressed: () => getImage(ImageSource.gallery),
                  ),
                ],
              ),
              if (_image != null) Image.file(_image!),
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
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Tempat',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
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
