import 'package:fluteryl/common/db/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:fluteryl/productos/modelos/producto.dart';
import 'package:intl/intl.dart';

class Precios extends StatefulWidget {
  final Producto producto;

  Precios(this.producto) : super();

  @override
  State<StatefulWidget> createState() {
    return new PreciosState();
  }
}

class PreciosState extends State<Precios> {
  var db = new DatabaseHelper();
  List<ProductPrecio> listaPrecios = [];
  bool isLoading = true;
  MyCustomForm formulario;

  PreciosState() : super();

  @override
  void initState() {
    super.initState();
    getData().then((snapshot) {
      print('initState initState initState');
      setState(() => this.isLoading  = false);
    });
  }

  Future<List<ProductPrecio>> getData() async {
    this.listaPrecios = [];
    List precios = await this.db.getAllWhere(db.tableProductPrecio, widget.producto.idproductos, db.productosidproductos);
    precios.forEach((product) {
      var pre = ProductPrecio.fromMap(product);
      this.listaPrecios.add(pre);
    });
    this.listaPrecios.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    const oneSecond = Duration(milliseconds: 1);
    final response = Future.delayed(oneSecond, () => this.listaPrecios);
    print(response);
    // compute function to run parsePosts in a separate isolate
    return response;
  }

  void setFormulario(MyCustomForm formulario){
    this.formulario = formulario;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: () async {
          ProductPrecio nuevoPrecio = new ProductPrecio();
          nuevoPrecio.idProdPrecio = null;
          return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    'Nuevo precio'
                ),
                content: Container(
                  height: 170.0,
                  child: new ListView(
                    padding: const EdgeInsets.all(0.0),
                    children: <Widget>[
                      new MyCustomForm(this, nuevoPrecio),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      child: const Text('CANCELAR'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }
                  ),
                  FlatButton(
                      child: const Text('GUARDAR'),
                      onPressed: ()async {
                        bool isValid = formulario.intancia._formKey.currentState.validate();
                        if (isValid) {
                          nuevoPrecio.productosidproductos = widget.producto.idproductos;
                          var result = await db.save(db.tableProductPrecio, nuevoPrecio.toMap());
                          nuevoPrecio.idProdPrecio = result;
                          this.listaPrecios.add(nuevoPrecio);
                          this.listaPrecios.sort((a, b) {
                            return b.date.compareTo(a.date);
                          });
                          setState(() {
                          });
                          Navigator.of(context).pop(true);
                        }
                      }
                  )
                ],
              );
            },
          ) ?? false;
        },
        backgroundColor: theme.primaryColor,
        //if you set mini to true then it will make your floating button small
        mini: false,
        child: new Icon(Icons.add),
      ),
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
          title: new Text(widget.producto.nombre)
      ),
      body: !isLoading
          ? builLista()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget builLista() {
    final f = new DateFormat('MMMM dd, yyyy');
    return new ListView.builder(
      padding: const EdgeInsets.only(top: 10.00, bottom: 80),
      itemCount: this.listaPrecios.length,
      itemBuilder: (BuildContext context, int index) {
        return new Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            elevation: 5.0,
            child: new InkWell(
                onTap: (){},
                child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: new Column(
                children: <Widget>[
                  Container (
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  'Tasa: ' + this.listaPrecios[index].tasa.toString() + ' bs',
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w800
                                  )
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.attach_money, color: Colors.blueGrey, size: 18.0,),
                                  Text(
                                      this.listaPrecios[index].getPrecioEnDolar(),
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w800
                                      )
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container (
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  f.format(this.listaPrecios[index].date),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0
                                  )
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                  'Bs ' + this.listaPrecios[index].monto.toString(),
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w800
                                  )
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
          );
      },
    );
  }
}

// Define a Custom Form Widget
class MyCustomForm extends StatefulWidget {
  _MyCustomFormState intancia;
  PreciosState precioInstance;
  ProductPrecio nuevoPrecio;
  MyCustomForm(this.precioInstance, this.nuevoPrecio);


  @override
  _MyCustomFormState createState() {
    this.intancia = _MyCustomFormState();
    precioInstance.setFormulario(this);
    return this.intancia;
  }
}


class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final precioController = TextEditingController();
  final tasaController = TextEditingController();
  bool _hasprecio = false;
  bool _hastasa = false;
  bool _saveNeeded = false;

  Future<bool> _onWillPop() async {
    _saveNeeded = _hasprecio || _hastasa || _saveNeeded;
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
    precioController.addListener(_precioListener);
    tasaController.addListener(_tasaListener);
  }

  _precioListener(){
    _hasprecio = precioController.text.isNotEmpty;
    if (_hasprecio) {
      widget.nuevoPrecio.monto = double.parse(precioController.text);
    }
  }

  _tasaListener(){
    _hastasa = tasaController.text.isNotEmpty;
    if (_hastasa) {
      widget.nuevoPrecio.tasa = double.parse(tasaController.text);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    precioController.dispose();
    tasaController.dispose();
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
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Campo requerido';
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'Precio',
                          hintText: 'nuevo Precio'
                      )
                  )
              ),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: TextFormField(
                      controller: tasaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Tasa',
                          hintText: 'Nueva tasa'
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Campo requerido';
                        }
                      }
                  )),
            ],
          ),
        )
    );
  }
}