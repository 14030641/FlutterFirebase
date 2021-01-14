import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:practica5/src/providers/firebase_providers.dart';

class CardProduct extends StatelessWidget {
  const CardProduct({Key key, @required this.productDocument})
      : super(key: key);

  final DocumentSnapshot productDocument;

  @override
  Widget build(BuildContext context) {
    FirebaseProvider firestore = FirebaseProvider();
    final _card = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: FadeInImage(
            placeholder: AssetImage('assets/activity_indicator.gif'),
            image: productDocument.data()['image'] != ''
                ? NetworkImage(productDocument.data()['image'])
                : NetworkImage(
                    'https://sainfoinc.com/wp-content/uploads/2018/02/image-not-available.jpg'),
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 100),
            height: 230.0,
          ),
        ),
        Opacity(
          opacity: .6,
          child: Container(
            height: 55.0,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  productDocument['model'],
                  style: TextStyle(color: Colors.white),
                ),
                FlatButton(
                    child: Icon(Icons.update, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/update', arguments: {
                        "model": productDocument['model'],
                        "description": productDocument['description'],
                        "image": productDocument['image'],
                        "documentid": productDocument.id
                      });
                    }),
                FlatButton(
                    child: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Eliminar'),
                              content: Text(
                                  '¿Esta seguro de que desea eliminar el producto?'),
                              actions: [
                                FlatButton(
                                  child: Text('Si'),
                                  onPressed: () async {
                                    await firestore
                                        .deleteProduct(productDocument.id);
                                    Reference photoRef = FirebaseStorage
                                        .instance
                                        .refFromURL(productDocument['image']);
                                    await photoRef.delete();
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    }),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.all(15.0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(.2),
            offset: Offset(0.0, 5.0),
            blurRadius: 1.0)
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: _card,
      ),
    );
  }
}
