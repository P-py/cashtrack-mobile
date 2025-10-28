import 'dart:convert';
import 'package:cashtrack_mobile/core/app_config.dart';
import 'package:cashtrack_mobile/core/utils/api_service.dart';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';

class IncomeService {
  final ApiService _api;

  IncomeService(AuthService auth)
      : _api = ApiService(
          baseUrl: AppConfig.baseUrl,
          auth: auth,
        );

  Future<List<dynamic>> getAll() async {
    final resp = await _api.get('/incomes');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    throw Exception('Erro ao carregar entradas: ${resp.statusCode}');
  }

  Future<void> create(String label, double value, String type) async {
    final resp = await _api.post('/incomes', {
      "incomeLabel": label,
      "value": value,
      "type": type,
    });

    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar entrada: ${resp.statusCode}');
    }
  }

  Future<void> update(int id, String label, double value, String type) async {
    final resp = await _api.put('/incomes', {
      "id": id,
      "incomeLabel": label,
      "value": value,
      "type": type,
    });

    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar entrada: ${resp.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final resp = await _api.delete('/incomes/$id');

    if (resp.statusCode != 204) {
      throw Exception('Erro ao excluir entrada: ${resp.statusCode}');
    }
  }
}
