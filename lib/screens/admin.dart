import 'package:book_exchange_admin/model/request_model.dart';
import 'package:book_exchange_admin/screens/add_products.dart';
import 'package:flutter/material.dart';
import '../db/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../db/brand.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Firestore _firestore = Firestore.instance;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  List<RequestedProduct> requestedProduct = <RequestedProduct>[];

  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    getRequestedProductFromDatabase();
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("On Launch Called");
    }, onResume: (Map<String, dynamic> msg) {
      print("On Launch Called");
    }, onMessage: (Map<String, dynamic> msg) {
      print("On Launch Called");
    });
    firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("IOS setting registered");
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Requests"),
          actions: [
            IconButton(
                icon: Icon(Icons.dashboard),
                onPressed: () {
                  setState(() => _selectedPage = Page.dashboard);
                }),
            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() => _selectedPage = Page.manage);
                })
          ], /**/
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        var listView = ListView.builder(
            itemCount: requestedProduct.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 12.0, 12.0, 4.0),
                              child: Flexible(
                                child: Text(
                                  requestedProduct[index].requestedProductName,
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 4.0, 12.0, 0.0),
                              child: Text(
                                requestedProduct[index].userName,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      requestedProduct[index].userEmail,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.email),
                                          onPressed: () {
                                            customLaunch(
                                                "mailto:${requestedProduct[index].userEmail}?subject=Regarding your order from Book Exchange \"%20${requestedProduct[index].requestedProductName} \"&body=Dear, %20${requestedProduct[index].userName}");
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      requestedProduct[index].mobileNumber,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.phone),
                                          onPressed: () {
                                            customLaunch(
                                                "tel:+91 \+${requestedProduct[index].mobileNumber}");
                                          })
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 0.0, 12.0, 12.0),
                              child: Flexible(
                                child: Text(
                                  requestedProduct[index].address,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 2.0,
                    color: Colors.grey,
                  )
                ],
              );
            });
        return listView;
        break;
      case Page.manage:
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add Product"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddProduct()));
              },
            ),
            /*Divider(),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Upload Carousel"),
              onTap: () {},
            ),*/
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("Add Category"),
              onTap: () {
                _categoryAlert();
              },
            ),
            /* Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Category list"),
              onTap: () {},
            ),*/
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Add Brand"),
              onTap: () {
                _brandAlert();
              },
            ),
            /*Divider(),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text("brand list"),
              onTap: () {},
            ),*/
            Divider(),
          ],
        );
        break;
      default:
        return Container();
    }
  }

  void _categoryAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Category cannot be empty';
            }
          },
          decoration: InputDecoration(hintText: "Add Category"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (_categoryFormKey.currentState.validate()) {
                _categoryService.createCategory(categoryController.text);
              }
              Fluttertoast.showToast(
                  msg: "Category Created!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.pop(context);
            },
            child: Text('ADD')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void _brandAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Category cannot be empty';
            }
          },
          decoration: InputDecoration(hintText: "Add Brand"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (brandController.text != null) {
                _brandService.createBrand(brandController.text);
              }
              Fluttertoast.showToast(
                  msg: "Brand added",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.pop(context);
            },
            child: Text('ADD')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void getRequestedProductFromDatabase() async {
    List<RequestedProduct> data = await getProducts();
    print("ItemCount " + data.length.toString());
    setState(() {
      requestedProduct = data;
    });
  }

  Future<List<RequestedProduct>> getProducts() =>
      _firestore.collection("requests").getDocuments().then((snap) {
        List<RequestedProduct> list = [];
        print(snap);
        snap.documents
            .forEach((f) => list.add(RequestedProduct.fromSnapshot(f)));
        return list;
      });

  update(String token) {
    Firestore.instance
        .collection("fcm-token")
        .document("tokens")
        .setData({"token": token});
    print("Token is=" + token);
  }

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print(' could not launch $command');
    }
  }
}
