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

  static Evento fromList(String title, int id, String descripcion) {
    return Evento(title: title, id: id, descripcion: descripcion);
  }
}