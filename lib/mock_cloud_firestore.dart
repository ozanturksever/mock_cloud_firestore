library mock_cloud_firestore;

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:mockito/mockito.dart';

class MockCloudFirestore {
  Map<String, dynamic> sourceParsed;
  Map<String, StreamController<QuerySnapshot>> snapshotStreams = {};

  MockCloudFirestore(String source) {
    sourceParsed = json.decode(source);
  }

  MockCollectionReference collection(String collectionName) {
    MockCollectionReference mcr = MockCollectionReference();
    Map<String, dynamic> colData = sourceParsed[collectionName];

    when(mcr.add(any)).thenAnswer((Invocation inv) {
      var value = inv.positionalArguments[0];
      MockDocumentReference mdr =
          createDocumentReferance(value);

      MockQuerySnapshot mqs = createMockQuerySnapshot(colData, added: [value]);
      snapshotStreams[collectionName].add(mqs);

      return Future.value(mdr);
    });

    MockDocumentReference mdr = createDocumentReferance(null);
    when(mcr.document(any)).thenAnswer((_) => mdr);
    if (colData == null) {
      return mcr;
    }
    colData.forEach((String key, dynamic value) {
      MockDocumentReference mdr = createDocumentReferance(value);
      when(mcr.document(key)).thenAnswer((_) => mdr);
    });

    MockQuerySnapshot mqs = createMockQuerySnapshot(colData);

    when(mcr.snapshots()).thenAnswer((_) {
      if (snapshotStreams[collectionName] == null) {
        snapshotStreams[collectionName] =
            StreamController<QuerySnapshot>.broadcast();
      }
      snapshotStreams[collectionName].add(mqs);
      return snapshotStreams[collectionName].stream;
    });
    return mcr;
  }

  MockDocumentReference createDocumentReferance(Map<String, dynamic> value) {
    MockDocumentReference r = MockDocumentReference();
    MockDocumentSnapshot s = MockDocumentSnapshot();
    when(s.data).thenReturn(value);
    when(r.get()).thenAnswer((_) => Future.value(s));
    return r;
  }

  MockQuerySnapshot createMockQuerySnapshot(Map<String, dynamic> colData,
      {List<Map<String, dynamic>> added = const []}) {
    MockQuerySnapshot s = MockQuerySnapshot();
    List<MockDocumentChange> docChangeList = [];
    List<MockDocumentSnapshot> docSnapList = [];
    colData.forEach((String key, dynamic value) {
      MockDocumentSnapshot ds = createDocumentSnapshot(value);
      docSnapList.add(ds);
    });
    added.map((value) {
      MockDocumentChange dc = createDocumentChange(value, DocumentChangeType.added);
      docChangeList.add(dc);
    });
    when(s.documentChanges).thenAnswer((_) => docChangeList);
    when(s.documents).thenAnswer((_) => docSnapList);
    return s;
  }

  MockDocumentChange createDocumentChange(Map<String, dynamic> value, DocumentChangeType type) {
    MockDocumentChange dc = MockDocumentChange();
    MockDocumentSnapshot ds = createDocumentSnapshot(value);
    when(dc.oldIndex).thenReturn(-1);
    when(dc.newIndex).thenReturn(-1);
    when(dc.type).thenReturn(type);
    when(dc.document).thenReturn(ds);
    return dc;
  }

  MockDocumentSnapshot createDocumentSnapshot(Map<String, dynamic> value) {
    MockDocumentSnapshot ds = MockDocumentSnapshot();
    when(ds.data).thenReturn(value);
    return ds;
  }
}
