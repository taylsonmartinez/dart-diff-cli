import 'package:dio/dio.dart';
import '../services/gestor_api.dart';

class GestorService {
  final Dio _dio;
  GestorService(this._dio);
  String _formatUrl(String template, Map<String, dynamic> params) {
    var url = template;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', Uri.encodeComponent(value.toString()));
    });
    return url;
  }

  Future<Response> getAll(
      {String term = '',
      String role = '',
      num? page,
      num? size,
      String? sort,
      String? direction}) async {
    return _dio.get(GestorApi.getAll, queryParameters: {
      'term': term,
      'role': role,
      if (page != null) 'page': page,
      if (size != null) 'size': size,
      if (sort != null) 'sort': sort,
      if (direction != null) 'direction': direction
    });
  }

  Future<Response> getById(num id) async {
    final url = _formatUrl(GestorApi.getById, {'id': id});
    return _dio.get(url);
  }

  Future<Response> update(
      {required num id,
      required String nome,
      String? sobrenome,
      String? teste,
      String? createdDate,
      String? updatedDate}) async {
    final url = _formatUrl(GestorApi.update, {'id': id});
    return _dio.put(url, data: {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'teste': teste,
      'createdDate': createdDate,
      'updatedDate': updatedDate
    });
  }

  Future<Response> delete(num? id) async {
    final url = _formatUrl(GestorApi.delete, {'id': id});
    return _dio.delete(url);
  }

  Future<Response> create(
      {required String nome, String? createdDate, String? updatedDate}) async {
    return _dio.post(GestorApi.create, data: {
      'nome': nome,
      'createdDate': createdDate,
      'updatedDate': updatedDate
    });
  }

  Future<Response> batch(List<Map<String, dynamic>> values) async {
    return _dio.post(GestorApi.batch, data: {'data': values});
  }
}
