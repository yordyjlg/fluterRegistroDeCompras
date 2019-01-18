import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluteryl/navigationDrawer/navigationDrawer.dart';
import 'package:fluteryl/productos/modelos/producto.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class FirstFragment extends StatefulWidget {
  final HomePageState homePageState;

  FirstFragment(this.homePageState) : super();

  @override
  State<StatefulWidget> createState() {
    return new FirstFragmentState(homePageState);
  }
}

class FirstFragmentState extends State<FirstFragment> {
  final HomePageState homePageState;
  List<Producto> productos = [];
  List<int> deleteElements = [];
  int goDetalleId = -1;

  FirstFragmentState(this.homePageState) : super();

  @override
  Widget build(BuildContext context) {
    timeDilation = 3.0; // 1.0 is normal animation speed.
    // TODO: implement build
    return
      new Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.red,
          //if you set mini to true then it will make your floating button small
          mini: false,
          child: new Icon(Icons.timer),
        ),
        body: new FutureBuilder<List<Producto>>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? createCard()
                : Center(child: CircularProgressIndicator());
          },
        ));
  }

  Future<List<Producto>> getData() async {
    for (var i = 1; i < 101; i++) {
      this.productos.add(new Producto(id: i, descripcion: 'Producto $i'));
    }
    const oneSecond = Duration(seconds: 5);
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
              tag: this.productos[index].descripcion,
              child: new Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Image.asset("assets/images/demou.jpg", fit: BoxFit.fitWidth),
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
                        child: valueWidget(this.goDetalleId != index ? this.productos[index].descripcion : ''),
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
                                setState(() => this.goDetalleId  = index);
                                final result = await Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => new Detail(
                                    nama: this.productos[index].descripcion,
                                    gambar: 'assets/images/demou.jpg',
                                  ),
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
            onPressed: () {},
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


class Detail extends StatelessWidget {
  Detail({this.nama, this.gambar});
  final String nama;
  final String gambar;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Container(
              height: 240.0,
              child: new Hero(
                tag: nama,
                child: new Material(
                  child: new InkWell(
                    child: new Image.asset(
                      "$gambar",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
          new BagianNama(
            nama: nama,
          ),
          new BagianIcon(),
          new Keterangan(),
        ],
      ),
    );
  }
}

class BagianNama extends StatelessWidget {
  BagianNama({this.nama});
  final String nama;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  nama,
                  style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                ),
                new Text(
                  "$nama\@gmail.com",
                  style: new TextStyle(fontSize: 17.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          new Row(
            children: <Widget>[
              new Icon(
                Icons.star,
                size: 30.0,
                color: Colors.red,
              ),
              new Text(
                "12",
                style: new TextStyle(fontSize: 18.0),
              )
            ],
          )
        ],
      ),
    );
  }
}

class BagianIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Iconteks(
            icon: Icons.call,
            teks: "Call",
          ),
          new Iconteks(
            icon: Icons.message,
            teks: "Message",
          ),
          new Iconteks(
            icon: Icons.photo,
            teks: "Photo",
          ),
        ],
      ),
    );
  }
}

class Iconteks extends StatelessWidget {
  Iconteks({this.icon, this.teks});
  final IconData icon;
  final String teks;
  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Column(
        children: <Widget>[
          new Icon(
            icon,
            size: 50.0,
            color: Colors.blue,
          ),
          new Text(
            teks,
            style: new TextStyle(fontSize: 18.0, color: Colors.blue),
          )
        ],
      ),
    );
  }
}

class Keterangan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Card(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Text(
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
            style: new TextStyle(fontSize: 18.0),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}