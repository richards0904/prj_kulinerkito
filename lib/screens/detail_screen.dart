import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj_kulinerkito/controlers/notification_service.dart';
import 'package:prj_kulinerkito/models/post.dart';
import 'package:url_launcher/url_launcher.dart';

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
    String userId = FirebaseAuth.instance.currentUser!.uid;
    print(userId);
    isLiked = widget.post.likes_users.contains(userId);
    print(widget.post.likes_users);
    // Check if the current post is bookmarked
    isBookmarked = widget.post.bookmarkedBy.contains(userId);
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleLike() {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    String userId = FirebaseAuth.instance.currentUser!.uid;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange),
            borderRadius: BorderRadius.circular(
                8), // Optional: untuk memberi sudut border
          ),
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
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 5),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                _launchURL(Uri.parse(widget.post.locationLink)),
                            child: Text(
                              widget.post.locationLink,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        //
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.comment,
                            color: Colors.blue,
                          ),
                        ),
                        //
                        Text(widget.post.comments.length.toString()),
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
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
        return Container(
          decoration: BoxDecoration(
            border:
                Border.all(color: Colors.orange), // Atur warna border di sini
            borderRadius:
                BorderRadius.circular(10), // Atur sudut border di sini
          ),
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(comment.username),
            subtitle: Text(comment.text),
          ),
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

  Future<String?> _getUserToken(String authorId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(authorId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return userData['token'];
      }
    } catch (e) {
      print('Failed to get user token: $e');
    }
    return null;
  }

  void _addComment() async {
    String commentText = commentController.text;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String username = FirebaseAuth.instance.currentUser!.displayName ?? 'User';

    if (commentText.isNotEmpty) {
      String commentId =
          FirebaseFirestore.instance.collection('posts').doc().id;
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'id': commentId,
            'userId': userId,
            'username': username,
            'text': commentText,
          }
        ])
      }).then((_) async {
        // Get authorID from the post
        String authorID = widget.post.authorId;

        // Get the token of the author
        String? authorToken = await _getUserToken(authorID);

        if (authorToken != null) {
          PushNotification.sendNotificationToSelectedDriver(
              authorToken, context, "comment", widget.post.id);
        }

        // Update local UI immediately
        setState(() {
          widget.post.comments
              .add(Comment(username: username, text: commentText));
          commentController.clear();
        });
      }).catchError((error) {
        print('Failed to add comment: $error');
      });
    }
  }

  void _toggleBookmark() {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (isBookmarked) {
      postRef.update({
        'bookmarkedBy': FieldValue.arrayRemove([userId]),
        'isBookmarked': false,
      }).then((_) {
        setState(() {
          isBookmarked = false;
        });
        // Notify parent (FavoriteScreen) to refresh its data
        widget.onFavorite();
      }).catchError((error) {
        print('Failed to remove bookmark: $error');
      });
    } else {
      postRef.update({
        'bookmarkedBy': FieldValue.arrayUnion([userId]),
        'isBookmarked': true,
      }).then((_) {
        setState(() {
          isBookmarked = true;
        });
        // Notify parent (FavoriteScreen) to refresh its data
        widget.onFavorite();
      }).catchError((error) {
        print('Failed to add bookmark: $error');
      });
    }
  }
}
