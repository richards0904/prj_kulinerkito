import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String username;
  final String imageUrl;
  final String description;
  final String location;
  final String locationLink;
  final String hours;
  int likes;
  final List<String> likes_users;
  final List<Comment> comments;
  bool isBookmarked;
  bool isLiked;
  final List<String> bookmarkedBy; // Tambahkan ini untuk menyimpan daftar user ID yang telah memfavoritkan

  Post({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.locationLink,
    required this.hours,
    required this.likes,
    required this.likes_users,
    required this.comments,
    required this.isBookmarked,
    required this.isLiked,
    required this.bookmarkedBy, // Tambahkan ini ke constructor
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      username: data['username'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      locationLink: data['locationLink'] ?? '',
      hours: data['hours'] ?? '',
      likes: data['likes'] ?? 0,
      likes_users: List<String>.from(data['likes_users'] ?? []),
      comments: _parseComments(data['comments'] ?? []),
      isBookmarked: data['isBookmarked'] ?? false,
      isLiked: data['isLiked'] ?? false,
      bookmarkedBy: List<String>.from(data['bookmarkedBy'] ?? []), // Inisialisasi dari data
    );
  }

  static List<Comment> _parseComments(dynamic comments) {
    if (comments == null) {
      return [];
    }
    if (comments is List) {
      return comments.map((comment) {
        if (comment is Map<String, dynamic>) {
          return Comment.fromMap(comment);
        } else {
          return Comment(username: '', text: '');
        }
      }).toList();
    } else {
      return [];
    }
  }

  // Update isLiked ke Firestore
  Future<void> updateFavoriteStatus(bool isLiked) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(id).update({
        'isLiked': isLiked,
      });
    } catch (e) {
      print('Failed to update favorite status: $e');
      throw e;
    }
  }

  // Update isBookmarked dan bookmarkedBy ke Firestore
  Future<void> updateBookmarkStatus(bool isBookmarked, String userId) async {
    try {
      if (isBookmarked) {
        // Tambahkan userId ke bookmarkedBy
        bookmarkedBy.add(userId);
      } else {
        // Hapus userId dari bookmarkedBy
        bookmarkedBy.remove(userId);
      }

      await FirebaseFirestore.instance.collection('posts').doc(id).update({
        'isBookmarked': isBookmarked,
        'bookmarkedBy': bookmarkedBy,
      });
    } catch (e) {
      print('Failed to update bookmark status: $e');
      throw e;
    }
  }
}

class Comment {
  final String username;
  final String text;

  Comment({
    required this.username,
    required this.text,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'] ?? '',
      text: map['text'] ?? '',
    );
  }
}
