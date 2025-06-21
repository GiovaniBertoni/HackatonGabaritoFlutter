import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';
import '../models/prova.dart';
import 'auth_service.dart';

class ApiService {
  // Use o seu endereço IP correto aqui
  static const String _baseUrl = 'http://162.120.186.83:8080'; 

  /// Valida as credenciais guardadas no dispositivo.
  Future<bool> checkAuth() async {
    final credentials = await AuthService().getCredentials();
    if (credentials == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/professor'), 
        headers: <String, String>{'Authorization': credentials},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Tenta fazer login no backend e guarda as credenciais em caso de sucesso.
  Future<bool> login(String email, String password) async {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$email:$password'))}';
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/professor'), 
        headers: <String, String>{'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        await AuthService().saveCredentials(email, password);
        return true;
      } else if (response.statusCode == 401) {
        throw 'Utilizador ou palavra-passe inválidos.';
      } else {
        throw 'Erro de servidor: ${response.statusCode}.';
      }
    } catch (e) {
      throw 'Não foi possível ligar ao servidor. Verifique o IP e se o backend está a correr.';
    }
  }

  /// Busca a lista de todos os alunos do backend.
  Future<List<Aluno>> getAlunos() async {
    final credentials = await AuthService().getCredentials();
    if (credentials == null) throw Exception('Utilizador não autenticado.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/alunos'),
      headers: <String, String>{'Authorization': credentials},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Aluno.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar alunos. Estado: ${response.statusCode}');
    }
  }

  /// Busca a lista de provas associadas ao professor logado.
  Future<List<Prova>> getProvas() async {
    final credentials = await AuthService().getCredentials();
    if (credentials == null) throw Exception('Utilizador não autenticado.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/provas'),
      headers: <String, String>{'Authorization': credentials},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Prova.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar provas.');
    }
  }

  /// Envia as respostas do aluno para a API.
  Future<void> enviarRespostas(int provaId, int alunoId, Map<int, String> respostas) async {
    final credentials = await AuthService().getCredentials();
    if (credentials == null) throw Exception('Utilizador não autenticado.');

    final Map<String, String> respostasFormatadas = 
        respostas.map((key, value) => MapEntry(key.toString(), value));

    final body = jsonEncode({
      'provaId': provaId,
      'alunoId': alunoId,
      'respostas': respostasFormatadas,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/respostas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': credentials,
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao enviar respostas. Estado: ${response.statusCode}');
    }
  }
}