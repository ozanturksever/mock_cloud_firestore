import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/factories.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreInstance extends Mock implements Firestore {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockCollectionReference extends Mock implements CollectionReference {
  String collectionName;
  Map<String, dynamic> colData;
  Map<String, dynamic> whereData;
  StreamController<QuerySnapshot> controller =
      StreamController<QuerySnapshot>.broadcast();

  MockCollectionReference(this.collectionName, this.colData, this.whereData);

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
    MockQuerySnapshot mqs = createMockQuerySnapshot(newColData, removed: [doc]);
    controller.add(mqs);
  }

  Query where(
    dynamic field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    dynamic arrayContainsAny,
    dynamic whereIn,
    bool isNull,
  }) {
    Map<String, dynamic> data;
    List<String> conditions = [];
    if (isEqualTo != null) {
      conditions.add(field + " == " + isEqualTo);
    }
    if (isLessThan != null) {
      conditions.add(field + " < " + isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      conditions.add(field + " =< " + isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) {
      conditions.add(field + " > " + isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      conditions.add(field + " => " + isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      conditions.add(field + " array-contains " + json.encode(arrayContains));
    }
    if (isNull != null) {
      conditions.add(field + " == null");
    }
    String path = conditions.join(" & ");
    data = whereData[path];
    if (data != null) {
      var newWhereData = data["__where__"];
      if (newWhereData != null)
        data.remove("__where__");
      else
        newWhereData = this.whereData;

      return createCollectionReference(this.collectionName, data, newWhereData);
    }
    return null;
  }
}

class MockDocumentReference extends Mock implements DocumentReference {
  StreamController<DocumentSnapshot> controller =
      StreamController<DocumentSnapshot>.broadcast();

  void dispose(filename) {
    controller.close();
  }
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockDocumentChange extends Mock implements DocumentChange {}

class MockQuery extends Mock implements Query {}
