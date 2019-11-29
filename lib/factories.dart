import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mock_cloud_firestore/mock_types.dart';
import 'package:mockito/mockito.dart';

MockQuerySnapshot createMockQuerySnapshot(Map<String, dynamic> colData,
    {List<Map<String, dynamic>> added = const [],
    modified = const [],
    removed = const []}) {
  MockQuerySnapshot s = MockQuerySnapshot();
  List<MockDocumentChange> docChangeList = [];
  List<MockDocumentSnapshot> docSnapList = [];
  colData.forEach((String key, dynamic value) {
    MockDocumentReference dr = MockDocumentReference();
    when(dr.documentID).thenReturn(key);
    MockDocumentSnapshot ds = createDocumentSnapshot(dr, value);
    when(ds.reference).thenReturn(dr);
    docSnapList.add(ds);
  });
  added.forEach((value) {
    MockDocumentChange dc =
        createDocumentChange(value, DocumentChangeType.added);
    docChangeList.add(dc);
  });
  modified.forEach((value) {
    MockDocumentChange dc =
    createDocumentChange(value, DocumentChangeType.modified);
    docChangeList.add(dc);
  });
  removed.forEach((value) {
    MockDocumentChange dc =
    createDocumentChange(value, DocumentChangeType.removed);
    docChangeList.add(dc);
  });
  when(s.documentChanges).thenAnswer((_) => docChangeList);
  when(s.documents).thenAnswer((_) => docSnapList);
  return s;
}

MockDocumentReference createDocumentReferance(Map<String, dynamic> value) {
  MockDocumentReference r = MockDocumentReference();
  MockDocumentSnapshot s = createDocumentSnapshot(r, value);
  when(r.get()).thenAnswer((_) => Future.value(s));
  when(r.snapshots()).thenAnswer((_) {
    Future<Null>.delayed(Duration.zero, () {
      r.controller.add(s);
    });
    return r.controller.stream;
  });

  return r;
}

MockDocumentChange createDocumentChange(
    Map<String, dynamic> value, DocumentChangeType type) {
  MockDocumentChange dc = MockDocumentChange();
  MockDocumentSnapshot ds = createDocumentSnapshot(null, value);
  when(dc.oldIndex).thenReturn(-1);
  when(dc.newIndex).thenReturn(-1);
  when(dc.type).thenReturn(type);
  when(dc.document).thenReturn(ds);
  return dc;
}

_createNestedDocumentReferance(Map<String, dynamic> map) {
  var references = map.keys.where((String val) => val.startsWith("__ref__"));
  if(references.isNotEmpty) {
    Map<String, dynamic> mapList = Map();
    for(String referenceKey in references) {
      dynamic obj = map[referenceKey];
      if(obj is Map<String, dynamic>) {
        _createNestedDocumentReferance(obj);
      }
      String refName = referenceKey.substring(7);
      MockDocumentReference documentReference = createDocumentReferance(obj);
      mapList[refName] = documentReference;
    }
    map.removeWhere((String key, dynamic value) => key.startsWith("__ref__"));
    map.addAll(mapList);
  }
}

MockDocumentSnapshot createDocumentSnapshot(MockDocumentReference r, Map<String, dynamic> value) {
  MockDocumentSnapshot ds = MockDocumentSnapshot();
  if(value != null) {
    _createNestedDocumentReferance(value);
  }
  if (value != null && value.containsKey("id"))
    when(ds.documentID).thenReturn(value["id"]);
  when(ds.reference).thenReturn(r);
  when(ds.data).thenReturn(value);
  when(ds.exists).thenReturn(value != null);
  return ds;
}

MockCollectionReference createCollectionReference(String collectionName,
    Map<String, dynamic> colData, Map<String, dynamic> whereData) {
  MockCollectionReference mcr =
      MockCollectionReference(collectionName, colData, whereData);

  when(mcr.add(any)).thenAnswer((Invocation inv) {
    var value = inv.positionalArguments[0];
    MockDocumentReference mdr = createDocumentReferance(value);

    MockQuerySnapshot mqs = createMockQuerySnapshot(colData, added: [value]);
    mcr.controller.add(mqs);

    return Future.value(mdr);
  });

  MockDocumentReference mdr = createDocumentReferance(null);
  when(mcr.document(any)).thenAnswer((_) => mdr);
  if (colData == null) {
    return mcr;
  }
  colData.forEach((String key, dynamic value) {
    MockDocumentReference mdr = createDocumentReferance(value);
    when(mcr.document(key)).thenAnswer((_) => mdr);
  });

  MockQuerySnapshot mqs = createMockQuerySnapshot(colData);

  when(mcr.snapshots()).thenAnswer((_) {
    Future<Null>.delayed(Duration.zero, () {
      mcr.controller.add(mqs);
    });
    return mcr.controller.stream;
  });
  when(mcr.getDocuments()).thenAnswer((_) {
    return Future<MockQuerySnapshot>.delayed(Duration.zero, () => mqs);
  });

  return mcr;
}
