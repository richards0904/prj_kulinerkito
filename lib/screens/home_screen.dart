import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prj_kulinerkito/controlers/notification_service.dart';
import 'package:prj_kulinerkito/screens/sign_in_screen.dart';
import 'package:prj_kulinerkito/screens/detail_screen.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _favorites = [];
  Set<String> _likedPosts = {};
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<void> signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _addToFavorites(String username, String imageUrl, String description,
      String location, String hours) {
    setState(() {
      _favorites.add({
        'username': username,
        'imageUrl': imageUrl,
        'description': description,
        'location': location,
        'hours': hours,
      });
    });
  }

  void _toggleLike(String postId, bool isLiked) {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (isLiked) {
      postRef.update({
        'likes_users':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.uid]),
        'likes': FieldValue.increment(-1),
      });
      setState(() {
        _likedPosts.remove(postId);
      });
    } else {
      postRef.update({
        'likes_users':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
        'likes': FieldValue.increment(1),
      });
      setState(() {
        _likedPosts.add(postId);
      });
    }
  }

  Future<void> _fetchLikedPosts() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      var likedPosts = await FirebaseFirestore.instance
          .collection('posts')
          .where('likes_users', arrayContains: userId)
          .get();

      setState(() {
        _likedPosts = likedPosts.docs.map((doc) => doc.id).toSet();
      });
    }
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery.toLowerCase();
    });
  }

  @override
  void initState() {
    _fetchLikedPosts();
    PushNotification.getDeviceToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Image.asset(
          'images/logo.png',
          width: 50,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(
                    8), // Optional: untuk memberi sudut border
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari tempat kuliner...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onChanged: _updateSearchQuery,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  var description =
                      (data['description'] ?? '').toString().toLowerCase();
                  var location =
                      (data['location'] ?? '').toString().toLowerCase();
                  var title = (data['title'] ?? '').toString().toLowerCase();
                  return description.contains(_searchQuery) ||
                      location.contains(_searchQuery) ||
                      title.contains(_searchQuery);
                }).toList();
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var document = filteredDocs[index];
                    var data = document.data() as Map<String, dynamic>;
                    if (!data.containsKey('likes')) {
                      data['likes'] = 0;
                    }
                    if (!data.containsKey('comments')) {
                      data['comments'] = [];
                    }
                    var post = Post.fromDocument(document);
                    bool isLiked = _likedPosts.contains(post
                        .id); // Cek apakah postingan sudah disukai oleh user
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              post: post,
                              onFavorite: () => _addToFavorites(
                                post.username,
                                post.imageUrl,
                                post.description,
                                post.location,
                                post.hours,
                              ),
                            ),
                          ),
                        ).then(
                          (_) {
                            setState(() {
                              _fetchLikedPosts();
                            });
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  return child;
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked ? Colors.red : null,
                                          ),
                                          onPressed: () =>
                                              _toggleLike(post.id, isLiked),
                                        ),
                                        Text(post.likes.toString()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.comment,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailScreen(
                                                  post: post,
                                                  onFavorite: () =>
                                                      {}, // Implement if needed
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Text(post.comments.length.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
