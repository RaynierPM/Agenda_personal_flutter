class Evento {
  Evento({required this.title, required this.id, this.descripcion});


  final int id;
  String title;
  String? descripcion;

  Map<String, dynamic> toList() {
    return {
      "ID": id,
      "title": title,
      "descripcion": descripcion
    };
  }

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(title: json["title"], id: json["ID"], descripcion: json["descripcion"]);
}