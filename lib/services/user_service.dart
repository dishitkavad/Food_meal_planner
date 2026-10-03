
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

Future<void> createUserProfile({
required String uid,
required String name,
required String email,
}) async {
await _firestore.collection('users').doc(uid).set({
'name': name.trim(),
'email': email.trim(),
'createdAt': FieldValue.serverTimestamp(),
});
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
String uid,
) async {
return await _firestore
    .collection('users')
    .doc(uid)
    .get();
}

Future<void> updateUserProfile({
required String uid,
required String name,
}) async {
await _firestore.collection('users').doc(uid).set(
{
'name': name.trim(),
},
SetOptions(merge: true),
);
}
}

