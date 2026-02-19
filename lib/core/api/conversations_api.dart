import 'api_client.dart';
import 'api_response.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

class ConversationsApi {
  ConversationsApi(this._client);

  final ApiClient _client;

  /// POST /conversations — Iniciar conversación (body: propertyId).
  Future<ApiResponse<Conversation>> create(String propertyId) async {
    final res = await _client.post<Map<String, dynamic>>('/conversations', data: {'propertyId': propertyId});
    if (!res.success || res.data == null) {
      return ApiResponse<Conversation>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Conversation>(success: true, data: Conversation.fromJson(res.data as Map<String, dynamic>));
  }

  /// GET /conversations — Lista de conversaciones.
  Future<ApiResponse<List<Conversation>>> list() async {
    final res = await _client.get<dynamic>('/conversations');
    if (!res.success) {
      return ApiResponse<List<Conversation>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<Conversation>>(success: true, data: []);
    final list = <Conversation>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(Conversation.fromJson(e));
    }
    return ApiResponse<List<Conversation>>(success: true, data: list);
  }

  /// GET /conversations/:id/messages — Mensajes de una conversación.
  Future<ApiResponse<List<Message>>> getMessages(String conversationId) async {
    final res = await _client.get<dynamic>('/conversations/$conversationId/messages');
    if (!res.success) {
      return ApiResponse<List<Message>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<Message>>(success: true, data: []);
    final list = <Message>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(Message.fromJson(e));
    }
    return ApiResponse<List<Message>>(success: true, data: list);
  }

  /// POST /conversations/:id/messages — Enviar mensaje (body: text).
  Future<ApiResponse<Message>> sendMessage(String conversationId, String text) async {
    final res = await _client.post<Map<String, dynamic>>('/conversations/$conversationId/messages', data: {'text': text});
    if (!res.success || res.data == null) {
      return ApiResponse<Message>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Message>(success: true, data: Message.fromJson(res.data as Map<String, dynamic>));
  }
}
