import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  MockCloudFirestore mcf;

  test('using __ref__ for DocumentReference', () async {
    mcf = MockCloudFirestore(getTestDocumentReference());

    QuerySnapshot querySnapshot = await mcf.collection("users").getDocuments();
    MockDocumentSnapshot docSnap = querySnapshot.documents.first;
    expect(docSnap.data["id"], "1");
    expect(docSnap.data["name"], "Vinicius");
    MockDocumentReference reference = docSnap.data["login"];
    DocumentSnapshot login = await reference.get();
    expect(login.data["username"], "v1pi");
    expect(login.data["password"], "123");
  });

  test('using nested __ref__ for DocumentReference', () async {
    mcf = MockCloudFirestore(getTestDocumentReferenceNested());
    
    QuerySnapshot querySnapshot = await mcf.collection("users").getDocuments();
    MockDocumentSnapshot docSnap = querySnapshot.documents.first;
    expect(docSnap.data["id"], "1");
    expect(docSnap.data["name"], "Vinicius");
    MockDocumentReference reference = docSnap.data["login"];
    DocumentSnapshot login = await reference.get();
    expect(login.data["username"], "v1pi");
    expect(login.data["password"], "123");

    MockDocumentReference referenceAddress = login.data["address"];
    DocumentSnapshot address = await referenceAddress.get();
    expect(address.data["address1"], "Av unknown");

  });
}