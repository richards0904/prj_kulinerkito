import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _username = '';
  String _profileImageUrl = '';
  int _postCount = 0;
  int _favoritesCount = 0;
  List<dynamic> _postImages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        final userDocRef = _firestore.collection('users').doc(_user!.uid);
        final userData = await userDocRef.get();

        if (userData.exists) {
          setState(() {
            _username = userData['displayName'] ?? 'Anonymous';
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _favoritesCount = userData['favorites'] ?? 0;
            _postCount = userData['postCount'] ??
                0; // Ambil jumlah postingan dari FireStore
          });

          // Load gambar-gambar postingan dari Firestore
          final userPostsQuery = await _firestore
              .collection('posts')
              .where('authorId', isEqualTo: _user!.uid)
              .get();

          setState(() {
            _postImages = userPostsQuery.docs
                .map((doc) => doc['imageUrl'] as String)
                .toList();
          });
        } else {
          setState(() {
            _username = _user!.displayName ?? 'Anonymous';
            _profileImageUrl = '';
            _postCount = 0;
            _favoritesCount = 0;
            _postImages = [];
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        setState(() {
          // Handle error state if needed
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _user == null
          ? Center(child: Text('No user logged in'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    // backgroundImage: NetworkImage(_profileImageUrl),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text('$_postCount', style: TextStyle(fontSize: 18)),
                          Text('postingan', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text('$_favoritesCount',
                              style: TextStyle(fontSize: 18)),
                          Text('difavoritkan', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _postImages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Image.network(
                        _postImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
