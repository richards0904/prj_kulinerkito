import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:prj_kulinerkito/screens/detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _currentUser;
  late List<Post> _userPosts = [];
  late List<Post> _likedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _loadUserPosts();
      await _loadLikedPosts();
    }
  }

  Future<void> _loadUserPosts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: _currentUser!.uid)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      _userPosts = posts;
    });
  }

  Future<void> _loadLikedPosts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('bookmarkedBy', arrayContains: _currentUser!.uid)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      _likedPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: _currentUser == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                _buildUserInfo(),
                _buildUserPosts(),
              ],
            ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            child: Text(
              _currentUser!.displayName![0],
              style: TextStyle(fontSize: 35),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _currentUser!.displayName ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _currentUser!.email ?? 'Email not available',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Postingan: ${_userPosts.length}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 20),
              Text('Favoritkan: ${_likedPosts.length}',
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosts() {
    return _userPosts.isEmpty
        ? const Center(
            child: Text('No posts yet.'),
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _userPosts.length,
            itemBuilder: (context, index) {
              Post post = _userPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        post: post,
                        onFavorite: _loadLikedPosts,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
  }
}
