const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnLikeOrComment = functions.firestore
  .document("posts/{postId}")
  .onUpdate((change, context) => {
    const postId = context.params.postId;
    const post = change.after.data();

    // Mengambil userId penulis dari data post
    const authorId = post.authorId;

    // Mengambil token FCM dari Firestore
    return admin
      .firestore()
      .collection("users")
      .doc(authorId)
      .get()
      .then((userDoc) => {
        const userData = userDoc.data();
        const token = userData.token;

        // Membuat payload notifikasi
        const payload = {
          notification: {
            title: "Your post has new interactions!",
            body: "Someone liked or commented on your post.",
          },
        };

        // Mengirim notifikasi
        return admin.messaging().sendToDevice(token, payload);
      });
  });
