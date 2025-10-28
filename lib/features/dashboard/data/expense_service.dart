import 'dart:convert';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class ExpenseService {
  final AuthService auth;
  final String baseUrl = 'https://cash-track-api-production.up.railway.app';

  ExpenseService(this.auth);

  /// Retorna todos os registros de despesas
  Future<List<dynamic>> getAll() async {
    final headers = auth.authHeaders;
    final resp = await http.get(Uri.parse('$baseUrl/expenses'), headers: headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Erro ao buscar despesas: ${resp.statusCode}');
    }
  }

  /// Cria uma nova despesa
  Future<void> create(String label, double value, String type) async {
    final headers = {
      ...auth.authHeaders,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'expenseLabel': label,
      'value': value,
      'type': type,
    });

    final resp = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
      body: body,
    );

    if (resp.statusCode != 201) {
      throw Exception(
        'Erro ao criar despesa: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Atualiza uma despesa existente
  Future<void> update(int id, String label, double value, String type) async {
    final headers = {
      ...auth.authHeaders,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'id': id,
      'expenseLabel': label,
      'value': value,
      'type': type,
    });

    final resp = await http.put(
      Uri.parse('$baseUrl/expenses'),
      headers: headers,
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Erro ao atualizar despesa: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Exclui uma despesa
  Future<void> delete(int id) async {
    final headers = auth.authHeaders;

    final resp = await http.delete(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: headers,
    );

    if (resp.statusCode != 204) {
      throw Exception(
        'Erro ao excluir despesa: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Obtém uma despesa específica
  Future<Map<String, dynamic>> getById(int id) async {
    final headers = auth.authHeaders;

    final resp = await http.get(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: headers,
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Erro ao buscar despesa: ${resp.statusCode}');
    }
  }
}
