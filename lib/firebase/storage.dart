import 'dart:html';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(File file, String name) async {
  try {
    final Reference storage = FirebaseStorage.instance.ref();
    final UploadTask task = storage.child('$name.jpg').putBlob(file);
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    return 'failed';
  }
}