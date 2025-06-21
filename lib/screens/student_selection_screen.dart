import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../services/api_service.dart';
import 'test_selection_screen.dart'; // <<< MUDANÇA: Importa a nova tela

class StudentSelectionScreen extends StatefulWidget {
  const StudentSelectionScreen({super.key});
  @override
  _StudentSelectionScreenState createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  late Future<List<Aluno>> _alunosFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _alunosFuture = _apiService.getAlunos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Selecione o Aluno') ),
      body: FutureBuilder<List<Aluno>>(
        future: _alunosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum aluno encontrado.'));
          }

          final alunos = snapshot.data!;
          return ListView.builder(
            itemCount: alunos.length,
            itemBuilder: (context, index) {
              final aluno = alunos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(aluno.nome[0])),
                  title: Text(aluno.nome),
                  subtitle: Text('RA: ${aluno.ra}'),
                  onTap: () {
                    // <<< MUDANÇA: Navega para a seleção de PROVA, não mais para o gabarito.
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TestSelectionScreen(aluno: aluno)),
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