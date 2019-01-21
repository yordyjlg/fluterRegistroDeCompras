import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fluteryl/common/db/databaseHelper.dart';
import 'package:fluteryl/common/picture/image_picker_handler.dart';
import 'package:fluteryl/productos/precios/precios.dart';
import 'package:flutter/material.dart';
import 'package:fluteryl/productos/modelos/producto.dart';

class Detail extends StatefulWidget {
  final Producto producto;

  Detail(this.producto) : super();

  @override
  State<StatefulWidget> createState() {
    return new DetailState(this.producto);
  }
}

class DetailState extends State<Detail> with TickerProviderStateMixin, ImagePickerListener{
  var db = new DatabaseHelper();
  DetailState(this.producto);
  MyCustomForm formulario;
  final Producto producto;
  Producto originalProducto;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  bool _hasImage = false;

  @override
  void initState() {
    this.originalProducto = null;
    this.originalProducto = this.cloneData(this.producto);
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    imagePicker = new ImagePickerHandler(this,_controller);
    imagePicker.init();

  }

  Producto cloneData(Producto original) {
    Producto copy = new Producto(idproductos: original.idproductos, nombre: original.nombre, image: original.image);
    copy.descripcion = original.descripcion;
    copy.imageTipe = original.imageTipe;
    return copy;
  }

  void descartarCambios() {
    setState(() {
      this.producto.nombre = this.originalProducto.nombre;
      this.producto.descripcion = this.originalProducto.descripcion;
      this.producto.image = this.originalProducto.image;
      this.producto.imageTipe = this.originalProducto.imageTipe;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  userImage(File _image) {
    List<int> imageBytes = _image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    this._hasImage = true;
    setState(() {
      this.producto.imageTipe = 1;
      this.producto.image = base64Image;
    });
  }

  void setFormulario(MyCustomForm formulario){
    this.formulario = formulario;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    return new Scaffold(
      body: new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.monetization_on, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context)
                        => new Precios(this.producto),
                      ));
                    }
                ),
                IconButton(
                    icon:  Icon(Icons.check_circle, color: Colors.white),
                    onPressed: () async {
                      bool isValid = formulario.intancia._formKey.currentState.validate();
                      if (isValid) {

                        Response resp = new Response();
                        resp.producto = this.producto;
                        if (this.producto.idproductos != null) {
                          var result = await db.updateNote(db.tableProductos, this.producto.idproductos, db.idproductos, this.producto.toMap());
                          resp.action = action.EDIT;
                        } else {
                          var result = await db.save(db.tableProductos, this.producto.toMap());
                          this.producto.idproductos = result;
                          resp.action = action.SAVE;
                        }
                        Navigator.pop(context, resp);
                      }
                    }
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxWidth: width - 150,
                      maxHeight: 25.0,
                    ),
                    child: Text(this.producto.nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                  ),
                  background: new Container(
                      height: 240.0,
                      child: new Hero(
                        tag: this.producto.idproductos.toString() + 'tag',
                        child: new Material(
                          child: new InkWell(
                            onTap: () {
                              imagePicker.showDialog(context);
                            },
                            child: this.producto.imageTipe == 0
                                ? new Image.asset(this.producto.image, fit: BoxFit.cover)
                                : new Image.memory(this.producto.getImage(), fit: BoxFit.cover)
                          ),
                        ),
                      )
                  ),
              ),
            ),
          ];
        },
        body:  new ListView(
          children: <Widget>[
            new MyCustomForm(this),
          ],
        ),
      ),
    );
  }
}

// Define a Custom Form Widget
class MyCustomForm extends StatefulWidget {
  final DetailState detail;
  MyCustomForm(this.detail){}
  _MyCustomFormState intancia;

  @override
  _MyCustomFormState createState() {
    this.intancia = _MyCustomFormState();
    this.detail.setFormulario(this);
   return this.intancia;
  }
}


class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  bool _hasNombre = false;
  bool _hasdescripcion = false;
  bool _saveNeeded = false;

  Future<bool> _onWillPop() async {
    _saveNeeded = _hasNombre || _hasdescripcion || _saveNeeded || widget.detail._hasImage;
    bool isValid = _formKey.currentState.validate();
    if (!_saveNeeded && isValid)
      return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'Desea descartar los cambios',
              style: dialogTextStyle
          ),
          actions: <Widget>[
            FlatButton(
                child: const Text('CANCELAR'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Pops the confirmation dialog but not the page.
                }
            ),
            FlatButton(
                child: const Text('DESCARTAR'),
                onPressed: () {
                  widget.detail.descartarCambios();
                  nombreController.text = widget.detail.producto.nombre;
                  descripcionController.text = widget.detail.producto.descripcion;
                  Navigator.of(context).pop(true); // Returning true to _onWillPop will pop again.
                }
            )
          ],
        );
      },
    ) ?? false;
  }

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.detail.producto.nombre;
    nombreController.addListener(_nombreListener);
    descripcionController.text = widget.detail.producto.descripcion;
  }

  _nombreListener(){
    _hasNombre = nombreController.text.isNotEmpty;
    widget.detail.setState((){
      widget.detail.producto.nombre = nombreController.text;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: TextFormField(
                      controller: nombreController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Porfavor ingrese un nombre';
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingrese el nombre del producto'
                      )
                  )
              ),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        hintText: 'Ingrese la descripcion del producto'
                    ),
                    onChanged: (String value){
                      _hasdescripcion = value.isNotEmpty;
                      widget.detail.producto.descripcion = value;
                    }
                  )),
            ],
          ),
        )
    );
  }
}

/*class BagianIcon extends StatelessWidget {
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
}*/

/*class Iconteks extends StatelessWidget {
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
}*/

/*class Keterangan extends StatelessWidget {
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
}*/

/*
class FormWidget extends StatelessWidget {
  var nombre = new TextEditingController();
  bool _hasNombre;
  final DetailState detail;

  FormWidget({this.detail}){
    this.nombre.text = this.detail.producto.nombre;
    */
/*this.nombre.addListener(() {
      this.detail.producto.nombre = this.nombre.text;
    });*//*

  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Form(
        onWillPop: () {
          const oneSecond = Duration(milliseconds: 1);
          return Future.delayed(oneSecond, () => true);
        },
        child: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: TextField(
                      controller: nombre,
                      decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingrese el nombre del producto'
                      ))),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        hintText: 'Ingrese la descripcion del producto'
                    ),
                    */
/*onChanged: (String value) {
                        setState(() {
                          _hasLocation = value.isNotEmpty;
                        });
                      }*//*

                  )),
            ].map<Widget>((Widget child) {
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  height: 70.0,
                  child: child);
            }).toList()));
  }
}*/
