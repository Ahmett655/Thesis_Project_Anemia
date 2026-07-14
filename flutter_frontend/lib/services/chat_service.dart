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
      debugPrint('[Chat] server refused (${res.statusCode}) — offline FAQ');
      return _offlineReply(history);
    } catch (e) {
      debugPrint('[Chat] error: $e — offline FAQ');
      return _offlineReply(history);
    }
  }

  // ==========================================================
  //  OFFLINE RULE-BASED FALLBACK
  //  Used when the AI backend is unreachable or has no API key,
  //  so the chatbot always answers something useful (in Somali).
  // ==========================================================

  static ChatReply _offlineReply(List<ChatMessage> history) {
    final lastUser = history.lastWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage('user', ''),
    );
    final q = lastUser.text.toLowerCase();

    final answer = _matchFaq(q);
    return ChatReply.success(
        '$answer\n\n📴 Jawaab kaydsan (AI-ga lama gaarin — internet ama server la\'aan).');
  }

  static bool _hasAny(String q, List<String> keys) =>
      keys.any((k) => q.contains(k));

  static String _matchFaq(String q) {
    if (q.trim().isEmpty ||
        _hasAny(q, ['salaam', 'salam', 'hello', 'hi ', 'iska warran', 'nabad'])) {
      return 'Waad salaaman tahay! 👋 Waxaan kaa caawin karaa su\'aalaha ku '
          'saabsan anemia (yaraanta dhiigga): calaamadaha, cuntooyinka birta '
          'leh, ka-hortagga, iyo sida qiimeynta loo sameeyo.';
    }
    if (_hasAny(q, ['maxay tahay', 'waa maxay', 'what is', 'micnaha'])) {
      return 'Anemia (yaraanta dhiigga) waxay dhacdaa marka hemoglobin-ka '
          'dhiiggaagu hooseeyo, oo jirku helin oksijiin ku filan. Calaamadaha '
          'waxaa ka mid ah daal, madax wareer iyo maqaar cirroobay. Waxaa inta '
          'badan keena bir-yaraan (iron deficiency).';
    }
    if (_hasAny(q, ['calaamad', 'symptom', 'daal', 'wareer', 'astaam'])) {
      return 'Calaamadaha anemia ugu badan:\n'
          '• Daal joogto ah iyo tabar-darro\n'
          '• Madax wareer iyo madax xanuun\n'
          '• Maqaarka/cadaadka indhaha oo cirroobay\n'
          '• Wadne-garaac iyo neef yaraan\n'
          'Haddii aad dareento calaamadahan, samee qiimeynta app-ka ama la '
          'tasho dhakhtar.';
    }
    if (_hasAny(q, ['cunto', 'food', 'bir', 'iron', 'nafaqo', 'raashin'])) {
      return 'Cuntooyinka birta leh ee anemia ka hortaga:\n'
          '• Hilib cas, beer (liver) iyo kalluun\n'
          '• Digir, misir iyo isbinaaj\n'
          '• Ukun iyo timir\n'
          'TALO: Fitamiin C (liin) la cun si birtu u nuugmato, shaahna ha la '
          'qadin cuntada.';
    }
    if (_hasAny(q, ['uur', 'pregnan', 'haween', 'hooyo'])) {
      return 'Haweenka uurka leh waxay u baahan yihiin bir iyo folic acid '
          'dheeraad ah — anemia inta uurka waa khatar hooyada iyo ilmahaba. '
          'Waxaa muhiim ah kaniiniga birta (dhakhtar kula taliyo), cunto '
          'nafaqo leh, iyo baadhitaan dhiig oo joogto ah.';
    }
    if (_hasAny(q, ['carruur', 'cunug', 'child', 'ilmo', 'yar'])) {
      return 'Carruurta 6 bilood ilaa 5 sano waa kooxda ugu khatarta badan. '
          'Calaamadaha: cunto-diid, daal, cirro, iyo koritaan gaabis ah. '
          'Naas-nuujinta, cunto birta leh, iyo shabag kaneeco ayaa ka hortaga. '
          'App-kan qaybta "Carruurta" ayaa lagu qiimeyn karaa.';
    }
    if (_hasAny(q, ['hemoglobin', 'baadhitaan', 'test', 'hb', 'dhiig baar'])) {
      return 'Hemoglobin-ku waa borotiinka oksijiinta qaada. Qiyaasta caadiga '
          'ah: haweenka 12–16 g/dL, ragga 13–17 g/dL, carruurta 11–15 g/dL. '
          'Haddii aad baadhitaan samaysay, qiimaha geli qiimeynta app-ka — '
          'natiijada ayaa noqonaysa mid WHO ku salaysan oo sax ah.';
    }
    if (_hasAny(q, ['qiimeyn', 'assessment', 'isticmaal', 'sameeyaa', 'app'])) {
      return 'Si aad qiimeyn u samayso:\n'
          '1. Guji "Bilaaw Qiimeyn"\n'
          '2. Dooro qaybta (Haween / Rag / Carruur)\n'
          '3. Ka jawaab su\'aalaha\n'
          '4. Natiijada iyo talooyinka ayaad heli doontaa — waa bilaash!';
    }
    if (_hasAny(q, ['khatar sare', 'severe', 'daran', 'degdeg'])) {
      return 'Haddii natiijadaadu tahay "Khatar Sare": ha sugin! Si degdeg ah '
          'xarun caafimaad u tag, natiijada (PDF) qaado oo dhakhtarka tus. '
          'App-ka waxaa ku jira khariidad ku tusinaysa xarumaha kuu dhow '
          '(Xarumaha Caafimaad ee u dhow).';
    }
    return 'Su\'aashaas si buuxda uma fahmin. Waxaan kaa caawin karaa: '
        'calaamadaha anemia, cuntooyinka birta leh, ka-hortagga, carruurta iyo '
        'uurka, iyo sida qiimeynta loo sameeyo. Mid ka mid ah weydii!';
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
