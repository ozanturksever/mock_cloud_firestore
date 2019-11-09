import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  MockCloudFirestore mcf;
  setUp(() {
    mcf = MockCloudFirestore(getTestData());
  });

  test('get document from collection', () async {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    MockDocumentReference doc = col.document("1");
    expect(doc, isNotNull);
    MockDocumentSnapshot docSnapshot = await doc.get();
    expect(docSnapshot.data["id"], "1");
    expect(docSnapshot.data["title"], "test project 1");
  });
}
