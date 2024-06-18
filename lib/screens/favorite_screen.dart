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

  @override
  void initState() {
    super.initState();
    _loadFavoritePosts();
  }

  Future<void> _loadFavoritePosts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('isBookmarked', isEqualTo: true)
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
        title: Text('Favorite Posts'),
      ),
      body: _favoritePosts.isEmpty
          ? Center(
              child: Text('No favorite posts yet.'),
            )
          : ListView.builder(
              itemCount: _favoritePosts.length,
              itemBuilder: (context, index) {
                Post post = _favoritePosts[index];
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
                          onFavorite: _loadFavoritePosts, // Reload favorites when coming back from detail
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
