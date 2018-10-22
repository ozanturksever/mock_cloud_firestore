Mock Cloud Firestore

The best way i found to test cloud_firestore is to use `Firestore.channel.setMockMethodCallHandler`.
But this requires knowledge of firebase protocol. This implementation tries to provide easier way.

## First define the firestore data as json

```dart
  String source = r"""
{
	"goals": {
		"1": {
			"$": "Goal",
			"id": "1",
			"taskId": "1",
			"projectId": "1",
			"profileId": "1",
			"state": "ASSIGNED"
		}
	},
	"projects": {
		"1": {
			"id": "1",
			"$": "Project",
			"title": "test title",
			"description": "description",
			"contributors": ["2"],
			"creatorProfileId": "3",
			"state": "INCOMPLETE"
		}
	},
	"tasks": {
		"1": {
			"id": "1",
			"$": "Task",
			"projectId": "123",
			"description": "test desc",
			"closeReason": "",
			"closeReasonDescription": "",
			"creatorProfileId": "123",
			"assigneeProfileId": "123",
			"state": "INCOMPLETE"
		}
	}
}
""";

```
## create the mock

```dart
  MockCloudFirestore mcf = MockCloudFirestore(source);
```

## now you can

```dart
main() {
  test("get a document", () async {
      MockCollectionReference col = mcf.collection("projects");
      MockDocumentReference docSnapshot = col.document("1");
      MockDocumentSnapshot docSnapshot = await doc.get();
      expect(docSnapshot.data["id"], "1");
      expect(docSnapshot.data["title"], "test project 1");
  });
}
```

```dart
main() {
  test("get snapshots", () async {
      MockCollectionReference col = mcf.collection("projects");
      Stream<QuerySnapshot> snapshots = col.snapshots();
      QuerySnapshot first = await snaphosts.first;
      expect(first, isNotNull);
      MockDocumentSnapshot docSnap = first.documents[0];
      expect(docSnap.data["id"], "1");
  });
}
```

To test widgets

## create a backend to wrap firestore api
```dart
class BackendApi {
  CollectionGet collectionGet;

  BackendApi(this.collectionGet);

  Future<Map<String, dynamic>> project() async {
    DocumentReference docRef = collectionGet("projects").document("1");
    DocumentSnapshot docSnap = await docRef.get();
    return docSnap.data;
  }
}
```

## remove firestore dependency from widget

```dart
class FirebaseDepWidget extends StatelessWidget {
  BackendApi backend;

  FirebaseDepWidget(this.backend);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: backend.project(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Text("Loading...");
        }
        return Text("${snapshot.data["title"]}");
      },
    );
  }
}
```

## now you can mock out firestore

```dart
void main() {
  MockCloudFirestore mcf = getMockCloudFirestore();

  //BackendApi realBackend = BackendApi(Firestore.instance.collection);
  BackendApi mockBackend = BackendApi(mcf.collection);

  testWidgets('check task info ', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: FirebaseDepWidget(mockBackend),
        ),
      ),
    );
    await tester.pump(Duration.zero); // Duration.zero is required or you get a timer exception
    expect(find.text("test project 1"), findsOneWidget);
  });
}
```
