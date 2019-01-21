import 'dart:io';

import 'package:fluteryl/common/selectable.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:fluteryl/common/sync.dart';

class Producto extends Selectable with Sync{

  int idproductos;
  String nombre;
  String descripcion;
  String image;
  int imageTipe = 0; // 0 = url; 1 = base64

  Producto({this.idproductos, this.nombre, this.image}){
  }

  Uint8List getImage() {
    return base64Decode(this.image);
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (idproductos != null) {
      map['idproductos'] = idproductos;
    }
    map['nombre'] = nombre;
    map['descripcion'] = descripcion;
    map['image'] = image;
    map['imageTipe'] = imageTipe;
    map['remoteKey'] = remoteKey;
    map['sync'] = sync;
    map['usersSync'] = usersSync;
    map['operacion'] = operacion;

    return map;
  }

  Producto.fromMap(Map<String, dynamic> map) {
    this.idproductos = map['idproductos'];
    this.nombre = map['nombre'];
    this.descripcion = map['descripcion'];
    this.image = map['image'];
    this.imageTipe = map['imageTipe'];
    this.remoteKey = map['remoteKey'];
    this.sync = map['sync'];
    this.usersSync = map['usersSync'];
    this.operacion = map['operacion'];
  }

}

class Response {
  var action;
  Producto producto;
}

enum action {EDIT, SAVE}

class ProductPrecio extends Selectable with Sync{
  int idProdPrecio;
  int productosidproductos;
  double monto = 0;
  double tasa = 0;
  var date = new DateTime.now();

  ProductPrecio({this.idProdPrecio, this.monto, this.tasa}){
  }

  String getPrecioEnDolar() {
    return (this.monto / this.tasa).toString();
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (idProdPrecio != null) {
      map['idProdPrecio'] = idProdPrecio;
    }
    map['productosidproductos'] = productosidproductos;
    map['monto'] = monto;
    map['tasa'] = tasa;
    map['date'] = date.toIso8601String();
    map['sync'] = sync;
    map['usersSync'] = usersSync;
    map['operacion'] = operacion;

    return map;
  }

  ProductPrecio.fromMap(Map<String, dynamic> map) {
    this.idProdPrecio = map['idProdPrecio'];
    this.productosidproductos = map['productosidproductos'];
    this.monto = map['monto'];
    this.tasa = map['tasa'];
    this.date = DateTime.parse(map['date']);
    this.remoteKey = map['remoteKey'];
    this.sync = map['sync'];
    this.usersSync = map['usersSync'];
    this.operacion = map['operacion'];
  }

}

class Cambios extends Selectable with Sync{
  int idCambios;
  double usd;
  double tasa;
  String nota;
  var date;

}