import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryService{
  Firestore _firestore = Firestore.instance;


  void createCategory(String name){
    var id = Uuid();
    String categoryId = id.v1();

    _firestore.collection("categories").document(categoryId).setData({'name': name});
  }

  Future <List<DocumentSnapshot>> getCategories()=>
     _firestore.collection("categories").getDocuments().then((snaps){
      return snaps.documents;
    });

  Future <List<DocumentSnapshot>> getSuggestions(String suggestion) =>
      _firestore.collection("categories").where("category", isEqualTo: suggestion).getDocuments().then((snap){
        return snap.documents;
      });

  }

