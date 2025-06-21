class Prova {
  final int id;
  final String titulo;
  final int numeroDeQuestoes;

  Prova({required this.id, required this.titulo, required this.numeroDeQuestoes});

  factory Prova.fromJson(Map<String, dynamic> json) {
    return Prova(
      id: json['id'],
      titulo: json['titulo'],
      numeroDeQuestoes: json['numeroDeQuestoes'],
    );
  }
}