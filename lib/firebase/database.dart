import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

// Realtime
// SELECT
Future<Map<String, dynamic>> selectRealtime(String? path) async {
  try {
    DataSnapshot snapshot = await FirebaseDatabase.instance.ref(path).get();
    return snapshot.value as Map<String, dynamic>;
  } catch (e) {
    print('Realtime 문서 가져오기 오류: $e');
    return {};
  }
}

// INSERT
void insertRealtime(String path, Map<String, dynamic> data) {
  FirebaseDatabase.instance.ref(path).set(data).catchError((error) {
    print('Realtime 데이터 추가 실패: $error');
  });
}

// DELETE
void deleteRealtime(String path) {
  FirebaseDatabase.instance.ref(path).remove().catchError((error) {
    print('Realtime 데이터 삭제 실패: $error');
  });
}

// Firestore
// SELECT
Future<List<Map<String, dynamic>>> selectFirestore(
    CollectionReference collection) async {
  try {
    QuerySnapshot snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    print('Firestore 문서 가져오기 오류: $e');
    return [];
  }
}

// INSERT
Future<void> insertFirestore(
    CollectionReference collection, Map<String, dynamic> data) async {
  try {
    await collection.add(data);
  } catch (e) {
    print('Firestore 문서 추가 오류: $e');
  }
}

// UPDATE
Future<void> updateFirestore(CollectionReference collection, String documentId,
    Map<String, dynamic> data) async {
  try {
    await collection.doc(documentId).update(data);
  } catch (e) {
    print('Firestore 문서 업데이트 오류: $e');
  }
}

// DELETE
Future<void> deleteFirestore(
    CollectionReference collection, String documentId) async {
  try {
    await collection.doc(documentId).delete();
  } catch (e) {
    print('Firestore 문서 삭제 오류: $e');
  }
}
