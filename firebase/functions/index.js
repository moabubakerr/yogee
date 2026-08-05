const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
  await firestore.collection("users").doc(user.uid).delete();
});

// A deleted post leaves its replies orphaned: they are a separate top-level
// collection pointing back at the post, so removing the post document does not
// touch them. Clients cannot delete comments (the rules deny it), so the
// cascade runs here with admin privileges, which bypass security rules.
exports.onPostDeleted = functions.firestore
    .document("posts/{postId}")
    .onDelete(async (snap, context) => {
      const firestore = admin.firestore();
      const postRef = firestore.doc("posts/" + context.params.postId);

      const comments = await firestore
          .collection("comments")
          .where("postref", "==", postRef)
          .get();

      if (comments.empty) {
        return;
      }

      // A write batch caps out at 500 operations, so commit in chunks rather
      // than assuming a post has few replies.
      const chunkSize = 400;
      for (let i = 0; i < comments.docs.length; i += chunkSize) {
        const batch = firestore.batch();
        comments.docs
            .slice(i, i + chunkSize)
            .forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
      }

      console.log(
          "Deleted " + comments.size + " comment(s) for post " +
          context.params.postId,
      );
    });
