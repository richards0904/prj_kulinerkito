import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadPost() async {
    if (_image == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image and description are required')),
      );
      return;
    }

    String imageUrl;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now()}.jpg');
      await ref.putFile(_image!);
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email ?? 'Anonymous';

    FirebaseFirestore.instance.collection('posts').add({
      'imageUrl': imageUrl,
      'description': _descriptionController.text,
      'timestamp': Timestamp.now(),
      'username': username, // Hardcoded username, you can replace this with actual user data
    });

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 100)
                    : Image.file(_image!),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
