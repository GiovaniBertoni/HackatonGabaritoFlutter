import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../models/prova.dart';
import '../services/api_service.dart';
import 'answer_sheet_screen.dart';

class TestSelectionScreen extends StatefulWidget {
  final Aluno aluno;
  const TestSelectionScreen({super.key, required this.aluno});

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  late Future<List<Prova>> _provasFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _provasFuture = _apiService.getProvas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a Prova'),
      ),
      body: FutureBuilder<List<Prova>>(
        future: _provasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma prova encontrada para este professor.'));
          }

          final provas = snapshot.data!;
          return ListView.builder(
            itemCount: provas.length,
            itemBuilder: (context, index) {
              final prova = provas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(prova.titulo),
                  subtitle: Text('${prova.numeroDeQuestoes} questões'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              AnswerSheetScreen(aluno: widget.aluno, prova: prova)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
