import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/factories.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreInstance extends Mock implements Firestore {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockCollectionReference extends Mock implements CollectionReference {
  String collectionName;
  Map<String, dynamic> colData;
  StreamController<QuerySnapshot> controller =
      StreamController<QuerySnapshot>.broadcast();

  MockCollectionReference(String this.collectionName, this.colData);

  simulateAddFromServer(Map<String, dynamic> doc) {
    Map<String, dynamic> newColData = colData;
    newColData[doc["id"]] = doc;
    MockQuerySnapshot mqs =
        createMockQuerySnapshot(colData, added: [doc]);
    controller.add(mqs);
  }
}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockDocumentChange extends Mock implements DocumentChange {}
