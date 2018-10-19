import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreInstance extends Mock implements Firestore {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockDocumentChange extends Mock implements DocumentChange {}
