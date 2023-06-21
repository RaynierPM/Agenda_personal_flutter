import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista personal",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      color: Colors.orange,
      
      home: const Agenda(),
      
    );
  }
}

class Agenda extends StatefulWidget {
  const Agenda({super.key});

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String tituloEvento = "";

  List _datos = [];
  int _index = 0;
  
  final String fileName = "data.json";

  Future<Directory> getlocalDir() async {
    return getApplicationDocumentsDirectory();
  }



  Future<void> readJson() async {
    Directory dir = await getlocalDir();
    File file = File("${dir.path}/$fileName");
    String datos;
    if (!file.existsSync()) {
      file.writeAsStringSync(json.encode({"autoIncrement": 0, "eventos":[]})); // Default values
      setState(() {
        _datos = [];
        _index = 0;
      });
    }else {

      datos = file.readAsStringSync();
      Map data = jsonDecode(datos);
      setState(() {
        _datos = data["eventos"];
        _index = data["autoIncrement"];
      });

    }

  }

  Future<void> eliminarEvento(int id) async {
    setState(() => _datos = _datos.where((element) => element["ID"] != id).toList());
    writeJson();
  }

  Future<void> writeJson() async {

    final File file;

    Directory? dir = await getApplicationDocumentsDirectory();
    
    file = File("${dir.path}/$fileName");

    Map<String, dynamic> jsonFileData = {};
    jsonFileData["eventos"] = _datos;
    jsonFileData["autoIncrement"] = _index;

    file.writeAsStringSync(json.encode(jsonFileData));
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }


  Future<void> clearData() async {
    Directory dir = await getlocalDir();
    File file = File("${dir.path}/$fileName");

    file.writeAsStringSync(json.encode({"autoIncrement": 0, "eventos":[]}));
    setState(() {
      _datos = [];
      _index = 0;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de eventos"),
        backgroundColor: Colors.orange[900],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Inserte un evento'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserte un evento';
                      }else if (value.length > 30) {
                        return "Titulo de evento demasiado largo. Maximo 30";
                      }
                      tituloEvento = value;
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                          onPressed: () => agregarEvento(), 
                          child: const Text("Agregar evento")),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900]),
                          onPressed: () => clearData(), 
                          child: const Text("Eliminar todo")),
                      )
                    ],
                  )
                  
                ],
              ),
            ),
            _datos.isNotEmpty ? Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Column(
              children: _datos.map((e) => Container(
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 4.0, spreadRadius: 2.0, offset: Offset(3.0, 3.0))
                  ]
                ),
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(20.0),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("${e['title']}"), 
                    TextButton(
                      onPressed: () => eliminarEvento(e['ID']), 
                      child: const Icon(Icons.delete, color: Colors.white,)
                      )
                    ],),
              )).toList(),
            )
            ) :
            Container(
              padding: const EdgeInsets.all(25.0),
              child: const Center(
                child: Text("No se han agregado eventos", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16.0),),
              ),
            )
          ],
        ),
      ),
    );
  }


  void agregarEvento() {
    if (_formKey.currentState!.validate()) {
      setState(() => _datos.add({"ID": ++_index, "title": tituloEvento}));

      writeJson();
    }
  }
}
