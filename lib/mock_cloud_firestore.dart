library mock_cloud_firestore;

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/factories.dart';
import 'package:mock_cloud_firestore/mock_types.dart';

class MockCloudFirestore {
  Map<String, dynamic> sourceParsed;
  Map<String, dynamic> whereData = {};
  Map<String, StreamController<QuerySnapshot>> snapshotStreams = {};
  Map<String, MockCollectionReference> collectionReferenceCache = {};

  MockCloudFirestore(String source) {
    sourceParsed = json.decode(source);
    if (sourceParsed != null) {
      whereData = sourceParsed["__where__"];
    }
  }

  MockCollectionReference collection(String collectionName) {
    if (collectionReferenceCache[collectionName] != null) {
      return collectionReferenceCache[collectionName];
    }
    Map<String, dynamic> colData = sourceParsed[collectionName];
    Map<String, dynamic> whereData = {};
    if (colData != null) {
      whereData = colData["__where__"];
      colData.remove("__where__");
    }

    MockCollectionReference mcr =
        createCollectionReference(collectionName, colData, whereData);
    collectionReferenceCache[collectionName] = mcr;

    return mcr;
  }
}
