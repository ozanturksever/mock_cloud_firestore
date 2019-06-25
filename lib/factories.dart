import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:mockito/mockito.dart';

MockQuerySnapshot createMockQuerySnapshot(Map<String, dynamic> colData,
    {List<Map<String, dynamic>> added = const [], modified = const [], removed = const []}) {
  MockQuerySnapshot s = MockQuerySnapshot();
  List<MockDocumentChange> docChangeList = [];
  List<MockDocumentSnapshot> docSnapList = [];
  colData.forEach((String key, dynamic value) {
    MockDocumentReference dr = MockDocumentReference();
    when(dr.documentID).thenReturn(key);
    MockDocumentSnapshot ds = createDocumentSnapshot(dr, value);
    when(ds.reference).thenReturn(dr);
    docSnapList.add(ds);
  });
  added.forEach((value) {
    MockDocumentChange dc =
    createDocumentChange(value, DocumentChangeType.added);
    docChangeList.add(dc);
  });
  modified.forEach((value) {
    MockDocumentChange dc =
    createDocumentChange(value, DocumentChangeType.modified);
    docChangeList.add(dc);
  });
  when(s.documentChanges).thenAnswer((_) => docChangeList);
  when(s.documents).thenAnswer((_) => docSnapList);
  return s;
}

MockDocumentReference createDocumentReferance(Map<String, dynamic> value) {
  MockDocumentReference r = MockDocumentReference();
  MockDocumentSnapshot s = createDocumentSnapshot(r, value);
  when(r.get()).thenAnswer((_) => Future.value(s));
  return r;
}

MockDocumentChange createDocumentChange(
    Map<String, dynamic> value, DocumentChangeType type) {
  MockDocumentChange dc = MockDocumentChange();
  MockDocumentSnapshot ds = createDocumentSnapshot(null, value);
  when(dc.oldIndex).thenReturn(-1);
  when(dc.newIndex).thenReturn(-1);
  when(dc.type).thenReturn(type);
  when(dc.document).thenReturn(ds);
  return dc;
}

MockDocumentSnapshot createDocumentSnapshot(MockDocumentReference r, Map<String, dynamic> value) {
  MockDocumentSnapshot ds = MockDocumentSnapshot();
  if (value != null && value.containsKey("id"))
    when(ds.documentID).thenReturn(value["id"]);
  when(ds.reference).thenReturn(r);
  when(ds.data).thenReturn(value);
  when(ds.exists).thenReturn(value != null);
  return ds;
}
