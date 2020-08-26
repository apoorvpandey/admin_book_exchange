import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BrandService{
  Firestore _firestore = Firestore.instance;

  void createBrand(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection("brands").document(brandId).setData({'brand': name});
  }

  Future <List<DocumentSnapshot>> getBrands() =>
       _firestore.collection("brands").getDocuments().then((snaps){
      return snaps.documents;
    });

  Future <List<DocumentSnapshot>> getSuggestions(String suggestion) =>
      _firestore.collection("brands").where("brand", isEqualTo: suggestion).getDocuments().then((snap){
        return snap.documents;
      });

}
