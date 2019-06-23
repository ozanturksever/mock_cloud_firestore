import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';

import 'test_data.dart';

MockCloudFirestore getMockCloudFirestore() {
  return MockCloudFirestore(getTestData());
}

void main() {
  MockCloudFirestore mcf = getMockCloudFirestore();

  test('docRef snapshots() should return document snapshot', () async {
    DocumentReference docRef = mcf.collection("projects").document("1");
    DocumentSnapshot snap = await docRef.snapshots().first;

    expect(snap, isNotNull);
    expect(snap.data["title"], "test project 1");
  });
}
