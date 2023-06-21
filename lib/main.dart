import 'dart:convert';
import 'dart:io';

import 'package:agenda_personal/evento.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gestor de actividades",
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


  final eventoTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  //States
  List<Evento> _datos = [];
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
      clearData();
      setState(() {
        _datos = [];
        _index = 0;
      });
    }else {

      datos = file.readAsStringSync();
      Map data = jsonDecode(datos);
      setState(() {
        List eventos = data["eventos"];
        _datos = eventos.map((evento) => Evento.fromList(evento["title"], evento["ID"], evento["descripcion"])).toList();
        _index = data["autoIncrement"];
      });

    }

  }

  Future<void> eliminarEvento(int id) async {
    setState(() => _datos = _datos.where((evento) => evento.id != id).toList());
    writeJson();
  }

  Future<void> writeJson() async {

    final File file;

    Directory? dir = await getApplicationDocumentsDirectory();
    
    file = File("${dir.path}/$fileName");

    Map<String, dynamic> jsonFileData = {};
    jsonFileData["eventos"] = _datos.map((evento) => evento.toList()).toList();
    jsonFileData["autoIncrement"] = _index;

    file.writeAsStringSync(json.encode(jsonFileData));
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override 
  void dispose() {
    super.dispose();
    eventoTextController.dispose();
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
                    controller: eventoTextController,
                    decoration: const InputDecoration(hintText: 'Inserte un evento'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserte un evento';
                      }else if (value.length > 30) {
                        return "Titulo de evento demasiado largo. Maximo 30";
                      }
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
                padding: const EdgeInsets.only(top: 5.0 , bottom: 5.0, left:15.0 , right:10.5 ),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(e.title), 
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => eliminarEvento(e.id), 
                            child: const Icon(Icons.delete, color: Colors.white,)
                            ),
                          TextButton(
                            onPressed: () {showDialog(context: context, builder: (context) => Center(child: Text("Prueba"),));}, 
                            child: const Icon(Icons.edit, color: Colors.white))
                        ],
                      )
                    ],
                  ),
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
      setState(() => _datos.add(Evento(title: eventoTextController.text, id: ++_index)));
      writeJson();
      eventoTextController.text = "";
    }
  }
}
