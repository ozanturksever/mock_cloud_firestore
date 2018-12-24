library mock_cloud_firestore;

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/factories.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:mockito/mockito.dart';

class MockCloudFirestore {
  Map<String, dynamic> sourceParsed;
  Map<String, StreamController<QuerySnapshot>> snapshotStreams = {};
  Map<String, MockCollectionReference> collectionReferenceCache = {};

  MockCloudFirestore(String source) {
    sourceParsed = json.decode(source);
  }

  MockCollectionReference collection(String collectionName) {
    if (collectionReferenceCache[collectionName] != null) {
      return collectionReferenceCache[collectionName];
    }
    Map<String, dynamic> colData = sourceParsed[collectionName];

    MockCollectionReference mcr =
        MockCollectionReference(collectionName, colData);
    collectionReferenceCache[collectionName] = mcr;

    when(mcr.add(any)).thenAnswer((Invocation inv) {
      var value = inv.positionalArguments[0];
      MockDocumentReference mdr = createDocumentReferance(value);

      MockQuerySnapshot mqs = createMockQuerySnapshot(colData, added: [value]);
      mcr.controller.add(mqs);

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
      Future<Null>.delayed(Duration.zero, () {
        mcr.controller.add(mqs);
      });
      return mcr.controller.stream;
    });
    when(mcr.getDocuments()).thenAnswer((_) {
      return Future<MockQuerySnapshot>.delayed(Duration.zero, () => mqs);
    });
    return mcr;
  }
}
