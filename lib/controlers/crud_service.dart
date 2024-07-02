import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService {
  // Save FCM Token ke firestore
  static Future saveUserToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic> data = {
        "userId": user.uid,
        "email": user.email,
        "token": token,
      };

      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection("user_data").doc(user.uid);
        DocumentSnapshot userDocSnapshot = await userDocRef.get();

        if (userDocSnapshot.exists) {
          // Check if the 'isDarkMode' field exists
          Map<String, dynamic>? userDocData =
              userDocSnapshot.data() as Map<String, dynamic>?;
          if (userDocData != null && !userDocData.containsKey('isDarkMode')) {
            // If 'isDarkMode' does not exist, add it with a default value
            data['isDarkMode'] = false;
          }
        } else {
          // If the document does not exist, create it with 'isDarkMode'
          data['isDarkMode'] = false;
        }

        // Save data with merge option to avoid overwriting existing fields
        await userDocRef.set(data, SetOptions(merge: true));
        print("Document Added/Updated ${user.uid}");
      } catch (e) {
        print("Failed saving to firestore");
        print(e.toString());
      }
    }
  }
}
