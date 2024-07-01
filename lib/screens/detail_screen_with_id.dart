import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:prj_kulinerkito/screens/detail_screen.dart';

class DetailScreenWithId extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String postId = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Post Not Found'),
            ),
            body: Center(
              child: Text('Post not found'),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var post = Post.fromDocument(snapshot.data!);

        return DetailScreen(
          post: post,
          onFavorite: () {}, // Implement if needed
        );
      },
    );
  }
}
