import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practica5/src/providers/firebase_providers.dart';
import 'package:practica5/src/screens/new_product_screen.dart';
import 'package:practica5/src/views/card_product.dart';

class ListProducts extends StatefulWidget {
  ListProducts({Key key}) : super(key: key);

  @override
  _ListProductsState createState() => _ListProductsState();
}

class _ListProductsState extends State<ListProducts> {
  FirebaseProvider firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          MaterialButton(
              child: Icon(Icons.add_circle, color: Colors.amber),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AddProduct()));
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getAllProducts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return CardProduct(productDocument: document);
              /*ListTile(
                title: Text(document.data()['model']),
                subtitle: Text(document.data()['description']),
              );*/
            }).toList(),
          );
          /*SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: .8),
            delegate: SliverChildBuilderDelegate(BuildContext context, int index){
              return CardProduct(productDocument: snapshot.data.docs[index],);
            },
            childCount: snapshot.data.docs.length
          );*/
        },
      ),
    );
  }
}
