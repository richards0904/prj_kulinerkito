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
        .where('likes_users', arrayContains: _currentUser!.uid)
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
        title: Text('Profile'),
      ),
      body: _currentUser == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                _buildUserInfo(),
                _buildUserPosts(),
                _buildLikedPosts(),
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
          Text(_currentUser!.displayName ?? 'User',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Posts: ${_userPosts.length}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Favorite: ${_likedPosts.length}',
              style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildUserPosts() {
    return _userPosts.isEmpty
        ? const Center(
            child: Text('No posts yet.'),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _userPosts.length,
            itemBuilder: (context, index) {
              Post post = _userPosts[index];
              return ListTile(
                title: Text(post.username),
                subtitle: Text(post.description),
                leading: Image.network(post.imageUrl),
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
              );
            },
          );
  }

  Widget _buildLikedPosts() {
    return _likedPosts.isEmpty
        ? const Center(
            child: Text('No liked posts yet.'),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _likedPosts.length,
            itemBuilder: (context, index) {
              Post post = _likedPosts[index];
              return ListTile(
                title: Text(post.username),
                subtitle: Text(post.description),
                leading: Image.network(post.imageUrl),
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
              );
            },
          );
  }
}
