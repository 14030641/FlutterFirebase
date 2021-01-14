import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:practica5/src/models/product_dao.dart';
import 'package:practica5/src/providers/firebase_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  AddProduct({Key key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String imagePath;
  File image;
  final picker = ImagePicker();
  FirebaseProvider firestore;
  TextEditingController txtDescription = TextEditingController();
  TextEditingController txtModel = TextEditingController();

  @override
  void initState() {
    super.initState();

    firestore = FirebaseProvider();
  }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    if (data != null) {
      txtModel.text = data['model'];
      txtDescription.text = data['description'];
    }
    return Container(
      child: Scaffold(
        appBar: AppBar(
            title: data == null
                ? Text('Nuevo Producto')
                : Text('Actualizar Producto')),
        body: Center(
          child: Container(
              padding: EdgeInsets.all(30),
              child: ListView(children: <Widget>[
                Text("Selecciona una imagen"),
                SizedBox(height: 30),
                InkWell(
                  child: imagePath != null
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.fill,
                          height: 250.0,
                          width: 250.0,
                        )
                      : (data != null)
                          ? Image.network(
                              data['image'],
                              fit: BoxFit.cover,
                              height: 250.0,
                              width: 250.0,
                            )
                          : Image.network(
                              'https://sainfoinc.com/wp-content/uploads/2018/02/image-not-available.jpg',
                              height: 250.0,
                              width: 250.0,
                            ),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Source'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Gallery source'),
                                onPressed: () async {
                                  final pickedFile = await picker.getImage(
                                      source: ImageSource.gallery);
                                  imagePath = pickedFile.path;
                                  Navigator.pop(context);
                                  setState(() {
                                    imagePath = pickedFile.path;
                                    image = File(pickedFile.path);
                                  });
                                },
                              ),
                              FlatButton(
                                child: Text('Camera source'),
                                onPressed: () async {
                                  final pickedFile = await picker.getImage(
                                      source: ImageSource.camera);
                                  imagePath = pickedFile.path;
                                  Navigator.pop(context);
                                  setState(() {
                                    imagePath = pickedFile.path;
                                    image = File(pickedFile.path);
                                  });
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                SizedBox(height: 30),
                Text("Modelo"),
                SizedBox(height: 30),
                TextFormField(
                  controller: txtModel,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: "Ingrese el modelo del producto",
                      contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                SizedBox(height: 30),
                Text("Descripción"),
                SizedBox(height: 30),
                TextFormField(
                  controller: txtDescription,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: "Ingrese una descripción corta del producto",
                      contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                SizedBox(height: 30),
                RaisedButton(
                    child: data == null
                        ? Text('Crear', style: TextStyle(color: Colors.white))
                        : Text(
                            'Actualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onPressed: () async {
                      if (data == null)
                        uploadProduct(context);
                      else
                        updateProduct(data);
                      Navigator.pop(context);
                    })
              ])),
        ),
      ),
    );
  }

  void uploadProduct(context) async {
    if (txtDescription.text.isNotEmpty &&
        txtModel.text.isNotEmpty &&
        image != null) {
      final Reference postImageProduct =
          FirebaseStorage.instance.ref().child("Images");
      final UploadTask uploadImageTask =
          postImageProduct.child(txtModel.text.trim()).putFile(image);
      var imageUrl = await (await uploadImageTask).ref.getDownloadURL();

      await firestore.saveProduct(ProductDAO(
          model: txtModel.text,
          description: txtDescription.text,
          image: imageUrl));
    } else {
      _showAlert(context);
    }
  }

  void updateProduct(var data) async {
    String urlImage = data['image'];
    // Verificamos si se seleccionó una imagen de la galeria
    if (image != null) {
      // Borramos imagen
      Reference photoRef = FirebaseStorage.instance.refFromURL(data['image']);
      await photoRef.delete();
      // Subimos nueva imagen
      final Reference postImagePark =
          FirebaseStorage.instance.ref().child("Images");
      final UploadTask uploadImageTask =
          postImagePark.child(txtModel.text.trim()).putFile(image);
      var imageUrl = await (await uploadImageTask).ref.getDownloadURL();
      urlImage = imageUrl.toString();
    }

    await firestore.updateProduct(
        ProductDAO(
          model: txtModel.text,
          image: urlImage,
          description: txtDescription.text,
        ),
        data['documentid']);
  }

  void _showAlert(BuildContext context) {
    showCupertinoDialog<String>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Advertencia'),
            content: Text('Todos los campos son obligatorios'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context, 'Cancelar'),
              ),
              CupertinoDialogAction(
                child: Text('Aceptar'),
                onPressed: () => Navigator.pop(context, 'Aceptar'),
              ),
            ],
          );
        });
  }
}
