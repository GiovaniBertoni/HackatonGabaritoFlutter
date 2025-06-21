import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../models/prova.dart'; // <<< MUDANÇA: Importa o novo modelo
import '../services/api_service.dart';

class AnswerSheetScreen extends StatefulWidget {
  final Aluno aluno;
  final Prova prova; // <<< MUDANÇA: Recebe o objeto Prova que foi selecionado

  // <<< MUDANÇA: Construtor atualizado para receber também a prova
  const AnswerSheetScreen({super.key, required this.aluno, required this.prova});

  @override
  _AnswerSheetScreenState createState() => _AnswerSheetScreenState();
}

class _AnswerSheetScreenState extends State<AnswerSheetScreen> {
  final ApiService _apiService = ApiService();
  late final int _numeroDeQuestoes; // <<< MUDANÇA: Não é mais 'final' e fixo
  final Map<int, String> _respostas = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // <<< MUDANÇA: O número de questões agora vem dinamicamente do objeto Prova
    _numeroDeQuestoes = widget.prova.numeroDeQuestoes;
  }

  // Função para lidar com o envio do gabarito
  Future<void> _submitAnswers() async {
    // Validação simples para ver se todas as questões foram respondidas
    if (_respostas.length < _numeroDeQuestoes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, responda a todas as questões.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // <<< MUDANÇA: O ID da prova agora é dinâmico
      await _apiService.enviarRespostas(
        widget.prova.id,
        widget.aluno.id,
        _respostas,
      );

      // Feedback de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gabarito enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para a tela de seleção de provas após o sucesso
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Feedback de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // A UI não precisa de mudanças, pois já usa a variável `_numeroDeQuestoes`
    return Scaffold(
      appBar: AppBar(
        // O título da prova agora é dinâmico também
        title: Text(widget.prova.titulo),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Espaço para o botão
        itemCount: _numeroDeQuestoes,
        itemBuilder: (context, index) {
          final int questaoNum = index + 1;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Questão $questaoNum', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ToggleButtons(
                    isSelected: ['A', 'B', 'C', 'D', 'E'].map((letra) => _respostas[questaoNum] == letra).toList(),
                    onPressed: (int buttonIndex) {
                      setState(() {
                        _respostas[questaoNum] = String.fromCharCode('A'.codeUnitAt(0) + buttonIndex);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('A')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('B')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('C')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('D')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('E')),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _isSending
          ? const FloatingActionButton(onPressed: null, child: CircularProgressIndicator(color: Colors.white))
          : FloatingActionButton.extended(
              onPressed: _submitAnswers,
              label: const Text('Enviar Gabarito'),
              icon: const Icon(Icons.send),
            ),
    );
  }
}