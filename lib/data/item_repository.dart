import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/lost_item.dart';

class ItemRepository {
  ItemRepository({String? projectUrl, String? publishableKey})
    : _projectUrl =
          (projectUrl ??
                  const String.fromEnvironment(
                    'SUPABASE_URL',
                    defaultValue: 'https://dsjxfkqitrdyjpahsqau.supabase.co',
                  ))
              .replaceFirst(RegExp(r'/+$'), ''),
      _publishableKey =
          publishableKey ??
          const String.fromEnvironment(
            'SUPABASE_PUBLISHABLE_KEY',
            defaultValue: 'sb_publishable_QgoQ1HitOrk58XD2Wyvcaw_YP6lQq8A',
          );

  final String _projectUrl;
  final String _publishableKey;

  bool get isConfigured => _projectUrl.isNotEmpty && _publishableKey.isNotEmpty;

  Uri get _itemsUri {
    if (!isConfigured) {
      throw const ItemRepositoryException(
        'O armazenamento ainda não foi configurado. Consulte o README.',
      );
    }
    return Uri.parse('$_projectUrl/rest/v1/items');
  }

  Future<List<LostItem>> fetchItems() async {
    final response = await _send(
      'GET',
      _itemsUri.replace(
        queryParameters: {'select': '*', 'order': 'created_at.desc'},
      ),
    );
    final decoded = jsonDecode(response) as List<dynamic>;
    return decoded
        .map((row) => LostItem.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<LostItem> createItem(LostItem item) async {
    final response = await _send('POST', _itemsUri, body: item.toJson());
    final rows = jsonDecode(response) as List<dynamic>;
    if (rows.isEmpty) {
      throw const ItemRepositoryException(
        'O serviço não confirmou o cadastro. Tente novamente.',
      );
    }
    return LostItem.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<String> _send(String method, Uri uri, {Object? body}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 15));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set('apikey', _publishableKey);
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.headers.set('Prefer', 'return=representation');
        request.write(jsonEncode(body));
      }
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseText = await utf8
          .decodeStream(response)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ItemRepositoryException(_readableError(responseText));
      }
      return responseText;
    } on ItemRepositoryException {
      rethrow;
    } on SocketException {
      throw const ItemRepositoryException(
        'Sem conexão com o serviço. Verifique a internet e tente novamente.',
      );
    } on TimeoutException {
      throw const ItemRepositoryException(
        'O serviço demorou para responder. Tente novamente.',
      );
    } on FormatException {
      throw const ItemRepositoryException(
        'A resposta do serviço está inválida. Tente novamente mais tarde.',
      );
    } catch (_) {
      throw const ItemRepositoryException(
        'Não foi possível comunicar com o serviço. Tente novamente.',
      );
    } finally {
      client.close(force: true);
    }
  }

  String _readableError(String response) {
    try {
      final body = jsonDecode(response) as Map<String, dynamic>;
      final message = body['message'] ?? body['hint'];
      if (message is String && message.isNotEmpty) {
        return 'Não foi possível acessar os registros: $message';
      }
    } on FormatException {
      // Respostas que não são JSON usam a mensagem padrão abaixo.
    }
    return 'Não foi possível acessar os registros. Confira a configuração e tente novamente.';
  }
}

class ItemRepositoryException implements Exception {
  const ItemRepositoryException(this.message);

  final String message;
}
