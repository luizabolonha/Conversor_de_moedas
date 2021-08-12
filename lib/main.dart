import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white)));
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

void _realChanged (String text){
  double real = double.parse(text);
  dolarController.text = (real/dolar).toStringAsFixed(2);
  euroController.text = (real/euro).toStringAsFixed(2);
}

void _dolarChanged (String text){
  double dolar = double.parse(text);
  realController.text = (dolar * this.dolar).toStringAsFixed(2);
  euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
}

void _euroChanged (String text){
  double euro = double.parse(text);
  realController.text = (euro * this.euro).toStringAsFixed(2);
  dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("\$ Conversor de Moedas \$"),
            backgroundColor: Colors.amber,
            centerTitle: true),
        body: FutureBuilder<Map>(
            //constroe o builder dependendo do que tem no future
            future: getData(),
            builder: (context, snapshot) {
              //cópia momentanea dos dados de getData, como uma foto
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text("Carregando dados...",
                          style: TextStyle(color: Colors.amber, fontSize: 20.0),
                          textAlign: TextAlign.center));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erro ao Carregar Dados",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 25.0),
                            textAlign: TextAlign.center));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.monetization_on,
                              color: Colors.amber, size: 150.0),
                          Divider(height: 7.0),
                          buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dolar", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          buildTextField("Euro", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

buildTextField(String label, String prefixo, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefixo,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 20.0),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  //retorna um mapa do futuro
  http.Response response = await http.get(request);
  return json.decode(response.body);
}