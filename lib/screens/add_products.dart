import 'dart:io';
import 'package:book_exchange_admin/db/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/category.dart';
import '../db/brand.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = new TextEditingController();
  TextEditingController quantityController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  File _image1;
  File _image2;
  File _image3;
  bool isLoadingButton = true;
  bool isLoadingProgress = false;

  @override
  void initState() {
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      items.insert(
          0,
          DropdownMenuItem(
              child: Text(categories[i].data["category"]),
              value: categories[i].data["category"]));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      items.insert(
          0,
          DropdownMenuItem(
              child: Text(brands[i].data["brand"]),
              value: brands[i].data["brand"]));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        onPressed: () {
                          _selectImage(
                              ImagePicker.pickImage(
                                  source: ImageSource.gallery),
                              1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 40, 14, 40),
                          child: _displayChild1(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        onPressed: () {
                          _selectImage(
                              ImagePicker.pickImage(
                                  source: ImageSource.gallery),
                              2);
                        },
                        child: _displayChild2(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        onPressed: () {
                          _selectImage(
                              ImagePicker.pickImage(
                                  source: ImageSource.gallery),
                              3);
                        },
                        child: _displayChild3(),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(hintText: "Product name"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "You must enter product name";
                    } else if (value.length > 20) {
                      return "Product name can't have more than 20 characters";
                    }
                  },
                ),
              ),

              // Select Category

              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select category:",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  DropdownButton(
                    items: categoriesDropDown,
                    onChanged: changeSelectedCategory,
                    value: _currentCategory,
                  ),
                ],
              ),

              // Select Brand

              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select author:",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  DropdownButton(
                    items: brandsDropDown,
                    onChanged: changeSelectedBrand,
                    value: _currentBrand,
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "Quantity", labelText: "Quantity"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "You must enter quantity";
                    }
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Price", labelText: "Price"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "You must enter price";
                    }
                  },
                ),
              ),

              Visibility(
                visible: isLoadingButton,
                child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("Add Product"),
                  onPressed: () {
                    validateAndUpload();
                  },
                ),
              ),
              Visibility(
                  visible: isLoadingProgress,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Uploading product images..."),
                        ),
                      ]
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropDown();
      _currentCategory = categories[0].data["category"];
    });
  }

  void _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data["brand"];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImg);
        break;

      case 2:
        setState(() => _image2 = tempImg);
        break;

      case 3:
        setState(() => _image3 = tempImg);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: Icon(
          Icons.add,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(
        _image1,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: Icon(
          Icons.add,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(
        _image2,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: Icon(
          Icons.add,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(
        _image3,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  void validateAndUpload() async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoadingButton = false);
      setState(() => isLoadingProgress = true);
      if (_image1 != null && _image2 != null && _image3 != null) {
        String imageUrl1;
        String imageUrl2;
        String imageUrl3;
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task1 =
            storage.ref().child(picture1).putFile(_image1);

        final String picture2 =
            "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task2 =
            storage.ref().child(picture2).putFile(_image2);

        final String picture3 =
            "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task3 =
            storage.ref().child(picture3).putFile(_image3);

        StorageTaskSnapshot snapshot1 =
            await task1.onComplete.then((snapshot) => snapshot);
        StorageTaskSnapshot snapshot2 =
            await task2.onComplete.then((snapshot) => snapshot);

        task3.onComplete.then((snapshot3) async {
          imageUrl1 = await snapshot1.ref.getDownloadURL();
          imageUrl2 = await snapshot2.ref.getDownloadURL();
          imageUrl3 = await snapshot3.ref.getDownloadURL();
          List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];

          productService.uploadProduct(
              productName: productNameController.text,
              brand: _currentBrand,
              category: _currentCategory,
              quantity: int.parse(quantityController.text),
              images: imageList,
              price: double.parse(priceController.text));
          _formKey.currentState.reset();
          FlutterFlexibleToast.showToast(message: "Product added");
          setState(() => isLoadingProgress = false);
        });
      } else {
        FlutterFlexibleToast.showToast(message: "Please select all images");
      }
    }
  }
}
