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
      "title": "test project 1"
    },
    "2": {
      "id": "2",
      "title": "test project 2"
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
      if(snapshot.documentChanges.length > 0) {
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

  test("update document from server", () async {
    MockCollectionReference col = mcf.collection("projects");

    col.snapshots().listen((QuerySnapshot snapshot) {
      if(snapshot.documentChanges.length > 0) {
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
      if(snapshot.documentChanges.length > 0) {
        expect(snapshot.documents.length, 0);

        DocumentChange change = snapshot.documentChanges[0];
        expect(change.type, DocumentChangeType.removed);
      }
    });

    col.simulateRemoveFromServer("1");
  });

}
