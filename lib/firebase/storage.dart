// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(File file, String name) async {
  try {
    final Reference storage = FirebaseStorage.instance.ref();
    final UploadTask task = storage.child(name).putBlob(file);
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    return 'failed';
  }
}

void deleteFile(String name) {
  final Reference storage = FirebaseStorage.instance.ref();
  storage.child(name).delete();
}
