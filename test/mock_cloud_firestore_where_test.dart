import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  MockCloudFirestore mcf;
  setUp(() {
    mcf = MockCloudFirestore(getTestRecursiveWhere());
  });

  test('using recursive where', () async {
    MockCollectionReference col = mcf.collection("users");
    Query q = col.where("name", isEqualTo: "Vinicius").where("type", isEqualTo: "2");
    expect(q, isNotNull);
    QuerySnapshot first = await q.snapshots().first;
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["id"], "1");
    expect(docSnap.data["name"], "Vinicius");
    expect(docSnap.data["type"], "2");
  });
}