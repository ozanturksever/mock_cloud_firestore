library mock_cloud_firestore;

import 'dart:convert';

import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:mockito/mockito.dart';

class MockCloudFirestore {
  Map<String, dynamic> sourceParsed;

  MockCloudFirestore(String source) {
    sourceParsed = json.decode(source);
  }

  MockCollectionReference collection(String collectionName) {
    MockCollectionReference mcr = MockCollectionReference();
    Map<String, dynamic> colData = sourceParsed[collectionName];

    MockDocumentReference mdr = createDocumentReferance(null);
    when(mcr.document(any)).thenAnswer((_) => mdr);
    if(colData==null) {
      return mcr;
    }
    colData.forEach((String key, dynamic value) {
      MockDocumentReference mdr = createDocumentReferance(value);
      when(mcr.document(key)).thenAnswer((_) => mdr);
    });

    MockQuerySnapshot mqs = createMockQuerySnapshot(colData);

    when(mcr.snapshots()).thenAnswer((_) => Stream.fromIterable([mqs]));
    return mcr;
  }

  MockDocumentReference createDocumentReferance(Map<String, dynamic> value) {
    MockDocumentReference r = MockDocumentReference();
    MockDocumentSnapshot s = MockDocumentSnapshot();
    when(s.data).thenReturn(value);
    when(r.get()).thenAnswer((_) => Future.value(s));
    return r;
  }

  MockQuerySnapshot createMockQuerySnapshot(Map<String, dynamic> colData) {
    MockQuerySnapshot s = MockQuerySnapshot();
    List<MockDocumentChange> docChangeList = [];
    List<MockDocumentSnapshot> docSnapList = [];
    colData.forEach((String key, dynamic value) {
      MockDocumentChange dc = createDocumentChange(value);
      docChangeList.add(dc);

      MockDocumentSnapshot ds = createDocumentSnapshot(value);
      docSnapList.add(ds);
    });
    when(s.documentChanges).thenAnswer((_) => docChangeList);
    when(s.documents).thenAnswer((_) => docSnapList);
    return s;
  }

  MockDocumentChange createDocumentChange(Map<String, dynamic> value) {
    MockDocumentChange dc = MockDocumentChange();
    MockDocumentSnapshot ds = createDocumentSnapshot(value);
    when(dc.document).thenReturn(ds);
    return dc;
  }

  MockDocumentSnapshot createDocumentSnapshot(Map<String, dynamic> value) {
    MockDocumentSnapshot ds = MockDocumentSnapshot();
    when(ds.data).thenReturn(value);
    return ds;
  }
}
