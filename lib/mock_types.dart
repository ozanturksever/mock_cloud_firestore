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
    Map<String, dynamic> newColData = Map<String, dynamic>.from(colData);
    newColData[doc["id"]] = doc;
    MockQuerySnapshot mqs = createMockQuerySnapshot(newColData, added: [doc]);
    controller.add(mqs);
  }

  simulateModifyFromServer(Map<String, dynamic> doc) {
    Map<String, dynamic> newColData = Map<String, dynamic>.from(colData);
    newColData[doc["id"]] = doc;
    MockQuerySnapshot mqs =
    createMockQuerySnapshot(newColData, modified: [doc]);
    controller.add(mqs);
  }

  simulateRemoveFromServer(String id) {
    Map<String, dynamic> newColData = Map<String, dynamic>.from(colData);
    Map<String, dynamic> doc = newColData.remove(id);
    MockQuerySnapshot mqs =
    createMockQuerySnapshot(newColData, removed: [doc]);
    controller.add(mqs);
  }
}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockDocumentChange extends Mock implements DocumentChange {}
