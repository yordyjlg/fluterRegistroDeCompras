import 'dart:async';
import 'dart:io';

import 'package:fluteryl/common/db/databaseHelper.dart';
import 'package:fluteryl/common/picture/image_picker_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluteryl/navigationDrawer/navigationDrawer.dart';
import 'package:fluteryl/productos/modelos/producto.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:fluteryl/productos/detail/detail.dart';

class FirstFragment extends StatefulWidget {
  final HomePageState homePageState;

  FirstFragment(this.homePageState) : super();

  @override
  State<StatefulWidget> createState() {
    return new FirstFragmentState(homePageState);
  }
}

class FirstFragmentState extends State<FirstFragment>{
  var db = new DatabaseHelper();
  final HomePageState homePageState;
  List<Producto> productos = [];
  List<int> deleteElements = [];
  int goDetalleId = -1;
  bool isLoading = true;

  FirstFragmentState(this.homePageState) : super();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    timeDilation = 3.0; // 1.0 is normal animation speed.
    // TODO: implement build
    return
      new Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            final Response result = await Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context)
              => new Detail(new Producto(idproductos: null, nombre: '', image: 'assets/images/demou.jpg')),
            ));
            if (result.action == action.SAVE) {
              this.productos.add(result.producto);
            }
          },
          backgroundColor: theme.primaryColor,
          //if you set mini to true then it will make your floating button small
          mini: false,
          child: new Icon(Icons.add),
        ),
        body: !isLoading
            ? createCard()
            : Center(child: CircularProgressIndicator())
      );
  }

  @override
  initState() {
    super.initState();
    getData().then((snapshot) {
      print('initState initState initState');
      setState(() => this.isLoading  = false);
    });
  }

  Future<List<Producto>> getData() async {
    this.productos = [];
    List productos = await this.db.getAll(db.tableProductos);
    productos.forEach((product) {
      var pro = Producto.fromMap(product);
      this.productos.add(pro);
    });
    const oneSecond = Duration(milliseconds: 1);
    final response = Future.delayed(oneSecond, () => this.productos);
    print(response);
    // compute function to run parsePosts in a separate isolate
    return response;
  }

  GridView createCard() {
    print('createCard createCard createCard');
    return new GridView.builder(
      itemCount: this.productos.length,
      gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            elevation: 5.0,
            child: new Hero(
              tag: this.productos[index].idproductos.toString() + 'tag',
              child: new Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  this.productos[index].imageTipe == 0
                      ? new Image.asset(this.productos[index].image, fit: BoxFit.cover)
                      : new Image.memory(this.productos[index].getImage(), fit: BoxFit.cover),
                  this.productos[index].isSelect
                      ? new Positioned(
                      top: 0,
                      right: 2.0,
                      left: 0,
                      bottom: 0,
                      child: new Container(
                        decoration: badgeDecoration(),
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                      ))
                      : new Positioned(
                      top: null,
                      right: 2.0,
                      left: 0,
                      bottom: 0,
                      child: new Container(
                        decoration: this.goDetalleId != index ? badgeDecoration() : new BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: valueWidget(this.goDetalleId != index ? this.productos[index].nombre : ''),
                      )),
                  new Positioned.fill(
                      child: new Material(
                          color: Colors.transparent,
                          child: new InkWell(
                            onLongPress: () {
                              this.markElement(index);
                            },
                            onTap: () async  {
                              if (this.countDeleteElements() > 0) {
                                this.markElement(index);
                              } else {
                                this.goDetalleId  = index;
                                final result = await Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => new Detail(this.productos[index]),
                                ));
                                const ms = const Duration(milliseconds: 30);

                                var duration = ms;
                                new Timer(duration, () {
                                  print('Timer Timer Timer');
                                  setState(() => this.goDetalleId  = -1);
                                });
                              }
                            },
                          )
                      )
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int countDeleteElements() {
    return this.deleteElements.length;
  }

  void markElement(index) {
    if (this.deleteElements.contains(index)) {
      this.deleteElements.remove(index);
      this.productos[index].deselect();
    } else {
      this.deleteElements.add(index);
      this.productos[index].select();
    }
    this.showDeleteIcon();
  }

  void showDeleteIcon() {
    if (this.countDeleteElements() <= 0) {
      this.homePageState.setActions(<Widget>[]);
      return;
    }

    this.homePageState.setActions(<Widget>[
      new Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          IconButton(
            onPressed: () async {
              print(this.deleteElements);
              this.deleteElements.forEach((index) async {
                var result1 = await this.db.delete(this.db.tableProductPrecio, this.productos[index].idproductos, this.db.productosidproductos);
                var result = await this.db.delete(this.db.tableProductos, this.productos[index].idproductos, this.db.idproductos);
                this.productos.removeAt(index);
              });
              setState(() {});
              this.homePageState.setActions(<Widget>[]);
            },
            icon: Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Eliminar',
          ),
          new Positioned(
              top: 0.0,
              right: null,
              left: 0,
              bottom: null,
              child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: new BorderRadius.circular(100.0)),
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: new Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: new Text(
                    this.countDeleteElements().toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ))
        ],
      )
    ]);
  }

  void showAlert(context, text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        child: new CupertinoAlertDialog(
          title: new Column(
            children: <Widget>[
              new Text("GridView"),
              new Icon(
                Icons.favorite,
                color: Colors.red,
              ),
            ],
          ),
          content: new Text(text),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("OK"))
          ],
        ));
  }

  Padding valueWidget(String value) {
    return new Padding(
      padding: const EdgeInsets.all(2.5),
      child: new Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  BoxDecoration badgeDecoration() {
    return new BoxDecoration(
      color: Colors.black.withOpacity(0.5),
    );
  }
}