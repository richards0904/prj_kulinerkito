import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:flutter/widgets.dart';


class DetailScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onFavorite;

  const DetailScreen({
    required this.post,
    required this.onFavorite,
    Key? key,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  TextEditingController commentController = TextEditingController();
  late bool isLiked;
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    // Check if the current user has liked this post
    String userId = FirebaseAuth.instance.currentUser!.uid ;
    isLiked = widget.post.likesUsers.contains(userId);
    // Check if the current post is bookmarked
    isBookmarked = widget.post.isBookmarked;
  }

  void _toggleLike() {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
        String userId = FirebaseAuth.instance.currentUser!.uid ;

    if (isLiked) {
      postRef.update({
        'likes_users': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      }).then((_) {
        setState(() {
          widget.post.likes--;
          isLiked = false;
        });
      }).catchError((error) {
        print('Failed to remove like: $error');
      });
    } else {
      postRef.update({
        'likes_users': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      }).then((_) {
        setState(() {
          widget.post.likes++;
          isLiked = true;
        });
      }).catchError((error) {
        print('Failed to add like: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.post.imageUrl,
              fit: BoxFit.cover,
              height: 250,
              width: MediaQuery.of(context).size.width,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.description,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.post.location,
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.post.hours,
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
                        ),
                        onPressed: () {
                          _toggleLike();
                        },
                      ),
                      Text(widget.post.likes.toString()),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.blue),
                        onPressed: () {
                          _showCommentDialog(context);
                        },
                      ),
                      Text(widget.post.comments.length.toString()),
                      IconButton(
                        icon: Icon(
                          isBookmarked ?  Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.black : null,
                        ),
                        onPressed: () {
                          _toggleBookmark();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Form komentar
                  _buildCommentForm(),
                  const SizedBox(height: 20),
                  // Daftar komentar
                  _buildCommentList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentForm() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Enter your comment...',
              ),
            ),
          ),
          SizedBox(width: 10),
          TextButton(
            onPressed: () {
              _addComment();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.post.comments.length,
      itemBuilder: (context, index) {
        Comment comment = widget.post.comments[index];
        return ListTile(
          title: Text(comment.username),
          subtitle: Text(comment.text),
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: 'Enter your comment...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addComment();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addComment() {
    String commentText = commentController.text;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String username = FirebaseAuth.instance.currentUser!.displayName ?? 'User';

    if (commentText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'username': username,
            'text': commentText,
          }
        ])
      });

      // Update local UI immediately
      setState(() {
        widget.post.comments
            .add(Comment(username: username, text: commentText));
        commentController.clear();
      });
    }
  }

  void _toggleBookmark() async {
    bool newIsBookmarked = !isBookmarked;

    // Update isBookmarked locally
    setState(() {
      isBookmarked = newIsBookmarked;
    });

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'isBookmarked': newIsBookmarked,
      });

      // Update local UI and add to favorites
      setState(() {
        if (newIsBookmarked) {
          widget.onFavorite(); // Add to favorites
        } else {
          widget.onFavorite(); // Remove from favorites
        }
      });
    } catch (error) {
      // Revert back isBookmarked locally if update fails
      setState(() {
        isBookmarked = !newIsBookmarked;
      });
      print('Failed to update bookmark: $error');
    }
  }
}
