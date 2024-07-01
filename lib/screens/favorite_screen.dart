import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:prj_kulinerkito/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<Post> _favoritePosts = [];
  late String _userPhotoUrl = ''; // URL foto profil pengguna

  @override
  void initState() {
    super.initState();
    _fetchUserPhoto();
    _loadFavoritePosts();
  }

  Future<void> _fetchUserPhoto() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userPhotoUrl = user.photoURL ?? ''; // Ambil URL foto profil pengguna
      });
    }
  }

  Future<void> _loadFavoritePosts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('bookmarkedBy', arrayContains: userId)
        .get();

    List<Post> posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      _favoritePosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
        
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Daftar Tempat Favorit Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _favoritePosts.length,
              itemBuilder: (context, index) {
                var post = _favoritePosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          post: post,
                          onFavorite: () => {}, // Implement if needed
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Text(post.username[0]),
                            ),
                            title: Text(post.username),
                          ),
                          Image.network(
                            post.imageUrl,
                            fit: BoxFit.cover,
                            height: 250,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              post.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                       
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
