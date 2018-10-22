import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';

import 'test_data.dart';

typedef CollectionReference CollectionGet(String path);

class BackendApi {
  CollectionGet collectionGet;

  BackendApi(this.collectionGet);

  Future<Map<String, dynamic>> project() async {
    DocumentReference docRef = collectionGet("projects").document("1");
    DocumentSnapshot docSnap = await docRef.get();
    return docSnap.data;
  }
}

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

MockCloudFirestore getMockCloudFirestore() {
  return MockCloudFirestore(getTestData());
}

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
