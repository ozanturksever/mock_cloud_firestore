import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:test/test.dart';

void main() {
  String source;
  MockCloudFirestore mcf;
  setUp(() {
    source = """
{
  "goal": {
    "1": {
      "id":"1",
      "taskId": "1",
      "projectId": "2"
    }
  },
  "projects": {
    "1": {
      "id": "1",
      "title": "test project 1",
      "due": "${Timestamp.now().toString()}",
      "tasks": {
        "101": {
          "id": "101",
          "taskId": "1",
          "projectPriority": true
        },
        "102": {
          "id": "102",
          "taskId": "2",
          "projectPriority": false
        }
      }
    },
    "2": {
      "id": "2",
      "title": "test project 2"
    },
    "__where__": {
      "id == 2": {
       "2": {"id": "2", "description": "test desctiontion 2"}
     },
      "id < 5 & id > 2": {
       "2": {"id": "2", "description": "test desctiontion 2"}
     },
     "id array-contains [\\"1\\",\\"2\\"]": {
       "2": {"id": "2", "description": "test desctiontion 2"}
     }
   }    
  },
  "tasks": {
    "1": {
      "id": "1",
      "description": "test description 1"
    },
    "2": {
      "id": "2",
      "description": "test description 2"
    }
  }
}
    """;
    mcf = MockCloudFirestore(source);
  });

  test('construct', () {
    expect(mcf, isNotNull);
  });

  test('loads json', () {
    expect(mcf.sourceParsed, isNotNull);
  });

  test('get collection', () {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
  });
  test('get not exist collection', () {
    MockCollectionReference col = mcf.collection("not exists");
    expect(col, isNotNull);
  });
  test('get collection if cached', () {
    MockCollectionReference col1 = mcf.collection("projects");
    MockCollectionReference col2 = mcf.collection("projects");
    expect(col1, col2);
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

  test('getDocuments from collection', () async {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    MockQuerySnapshot docs = await col.getDocuments();
    expect(docs, isNotNull);
  });

  test('get not exist document from collection', () async {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    MockDocumentReference doc = col.document("not exists");
    expect(doc, isNotNull);
    MockDocumentSnapshot docSnapshot = await doc.get();
    expect(docSnapshot, isNotNull);
    expect(docSnapshot.data, isNull);
    expect(docSnapshot.exists, false);
  });

  test('get document snaphots from collection', () async {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    Stream<QuerySnapshot> snapshots = col.snapshots();
    expect(snapshots, isNotNull);
    QuerySnapshot first = await snapshots.first;
    expect(first, isNotNull);
//    MockDocumentChange docChange = first.documentChanges[0];
//    expect(docChange.document.data["id"], "1");

    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["id"], "1");
    expect(docSnap.exists, true);
    expect(docSnap.documentID, "1");
    expect(docSnap.reference, isNotNull);
  });

  test('get document snaphots with stingified timestamp', () async {
    source = '''
      "projects": {
        "1": {
          "id": "1",
          "title": "test project 1",
          "due": "${Timestamp.now().toString()}"
        }
      }
    ''';
    mcf = MockCloudFirestore(source);
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    Stream<QuerySnapshot> snapshots = col.snapshots();
    expect(snapshots, isNotNull);
    QuerySnapshot first = await snapshots.first;
    expect(first, isNotNull);
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["due"] is Timestamp, true);
  });

  test('get document snaphots with encoded timestamp', () async {
    source = json.encode({
      "projects": {
        "1": {
          "id": "1",
          "title": "test project 1",
          "due": Timestamp.now()
        }
      }
    });
    mcf = MockCloudFirestore(source);
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    Stream<QuerySnapshot> snapshots = col.snapshots();
    expect(snapshots, isNotNull);
    QuerySnapshot first = await snapshots.first;
    expect(first, isNotNull);
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["due"] is Timestamp, true);
  });

  test('get sub-collection from document', () {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    MockDocumentReference doc = col.document("1");
    expect(doc, isNotNull);
    // MockDocumentSnapshot docSnapshot = await doc.get();
    // expect(docSnapshot, isNotNull);

    CollectionReference cr = doc.collection("tasks");
    expect(cr, isNotNull);
    Stream<QuerySnapshot> qs = cr.snapshots();
    expect(qs, isNotNull);
  });

  test('get document from collection', () {
    MockCollectionReference col = mcf.collection("projects");
    expect(col, isNotNull);
    MockDocumentReference r = col.document("1");
    expect(r, isNotNull);
    expect(r.documentID, "1");
  });

  test('add new document', () async {
    MockCollectionReference col = mcf.collection("projects");

    bool hasData = false;
    col.snapshots().listen((QuerySnapshot snapshot) {
      hasData = true;
    });

    Map<String, dynamic> data = {"id": "1000", r"$": "Project"};
    await col.add(data);

    expect(hasData, true);
  });

  test("add new document from server", () async {
    MockCollectionReference col = mcf.collection("projects");

    col.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.documentChanges.length > 0) {
        DocumentSnapshot doc = snapshot.documents[0];
        expect(doc.data, isNotNull);

        DocumentSnapshot doc1 = snapshot.documents[1];
        expect(doc1.data, isNotNull);

        DocumentChange change = snapshot.documentChanges[0];
        expect(change.type, DocumentChangeType.added);
      }
    });

    Map<String, dynamic> data = {"id": "1000", r"$": "Project"};
    col.simulateAddFromServer(data);
  });

  test("remove document from server", () async {
    MockCollectionReference col = mcf.collection("projects");

    col.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.documentChanges.length > 0) {
        DocumentSnapshot doc = snapshot.documents[0];
        expect(doc.data, isNotNull);

        DocumentChange change = snapshot.documentChanges[0];
        expect(change.type, DocumentChangeType.removed);
      }
    });

    col.simulateRemoveFromServer("1");
  });

  test("update document from server", () async {
    MockCollectionReference col = mcf.collection("projects");

    col.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.documentChanges.length > 0) {
        DocumentSnapshot doc = snapshot.documents[0];
        expect(doc.data, isNotNull);

        DocumentChange change = snapshot.documentChanges[0];
        expect(change.type, DocumentChangeType.modified);
      }
    });

    Map<String, dynamic> data = {"id": "1", "title": "modified"};
    col.simulateModifyFromServer(data);
  });

  test("delete document from server", () async {
    MockCollectionReference col = mcf.collection("projects");

    col.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.documentChanges.length > 0) {
        expect(snapshot.documents.length, 1);

        DocumentChange change = snapshot.documentChanges[0];
        expect(change.type, DocumentChangeType.removed);
      }
    });

    col.simulateRemoveFromServer("1");
  });

  test('using where on collection', () async {
    MockCollectionReference col = mcf.collection("projects");
    Query q = col.where("id", isEqualTo: "2");
    expect(q, isNotNull);
    QuerySnapshot first = await q.snapshots().first;
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["id"], "2");
  });

  test('using where on collection, multiple contition', () async {
    MockCollectionReference col = mcf.collection("projects");
    Query q = col.where("id", isGreaterThan: "2", isLessThan: "5");
    expect(q, isNotNull);
    QuerySnapshot first = await q.snapshots().first;
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["id"], "2");
  });

  test('using where on collection, array-contains', () async {
    MockCollectionReference col = mcf.collection("projects");
    Query q = col.where("id", arrayContains: ["1", "2"]);
    expect(q, isNotNull);
    QuerySnapshot first = await q.snapshots().first;
    MockDocumentSnapshot docSnap = first.documents[0];
    expect(docSnap.data["id"], "2");
  });
}
