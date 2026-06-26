import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

/// Calls the backend anemia Q&A chatbot (/api/chat), which proxies to Claude.
class ChatService {
  static String get _url => '${ApiConfig.apiBase}/chat';

  /// Sends the full conversation [history] and returns the assistant reply.
  static Future<ChatReply> send(List<ChatMessage> history) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      final token = AuthService.authToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http
          .post(
            Uri.parse(_url),
            headers: headers,
            body: jsonEncode({
              'messages':
                  history.map((m) => {'role': m.role, 'content': m.text}).toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ChatReply.success(data['reply'] as String? ?? '');
      }
      return ChatReply.failure(
          data['message'] as String? ?? 'Chatbot-ku ma jawaabin.');
    } catch (e) {
      debugPrint('[Chat] error: $e');
      return ChatReply.failure(
          'Lama gaarin server-ka. Hubi internetka oo isku day mar kale.');
    }
  }
}

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  ChatMessage(this.role, this.text);

  bool get isUser => role == 'user';
}

class ChatReply {
  final bool ok;
  final String text;
  ChatReply._(this.ok, this.text);
  factory ChatReply.success(String t) => ChatReply._(true, t);
  factory ChatReply.failure(String t) => ChatReply._(false, t);
}
