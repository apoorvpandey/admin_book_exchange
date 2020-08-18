import 'package:cloud_firestore/cloud_firestore.dart';

class RequestedProduct{
static const String RESUESTEDPRODUCTNAME= "NameOfTheRequestedProduct";
static const String USEREMAIL= "UserEmail";
static const String USERNAME= "UserName";
static const String MOBILENUMBER= "MobileNumber";
static const String ADDRESS= "Address";


String _requestedProductName;
String _userEmail;
String _userName;
String _mobileNumber;
String _address;

String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get mobileNumber => _mobileNumber;

  set mobileNumber(String value) {
    _mobileNumber = value;
  }

  String get requestedProductName => _requestedProductName;

  set requestedProductName(String value) {
    _requestedProductName = value;
  }

String get userEmail => _userEmail;

String get userName => _userName;

  set userName(String value) {
    _userName = value;
  }

  set userEmail(String value) {
    _userEmail = value;
  }

RequestedProduct.fromSnapshot(DocumentSnapshot snapshot){
  Map data = snapshot.data;
  _requestedProductName = data[RESUESTEDPRODUCTNAME];
  _userEmail = data[USEREMAIL];
  _userName = data[USERNAME];
  _mobileNumber = data[MOBILENUMBER];
  _address = data[ADDRESS];
}


}

