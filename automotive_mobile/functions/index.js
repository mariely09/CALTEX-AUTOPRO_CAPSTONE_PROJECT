const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Callable function: deleteUser
 * Only callable by authenticated admin users.
 * Deletes a user from Firebase Auth by UID.
 */
exports.deleteUser = onCall(async (request) => {
  // Must be authenticated
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated.');
  }

  // Check caller is admin
  const callerDoc = await admin.firestore()
    .collection('users')
    .doc(request.auth.uid)
    .get();

  if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
    throw new HttpsError('permission-denied', 'Only admins can delete users.');
  }

  const { uid } = request.data;
  if (!uid) {
    throw new HttpsError('invalid-argument', 'UID is required.');
  }

  // Delete from Firebase Auth
  await admin.auth().deleteUser(uid);

  return { success: true };
});
