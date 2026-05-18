import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorageService {
  static const String _chatHistoryKey = 'chat_history';
  
  /// Save chat messages to local storage
  static Future<void> saveChatMessages(List<Map<String, String>> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages);
      await prefs.setString(_chatHistoryKey, messagesJson);
    } catch (e) {
      print('Error saving chat messages: $e');
    }
  }
  
  /// Load chat messages from local storage
  static Future<List<Map<String, String>>> loadChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_chatHistoryKey);
      
      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        return messagesList.map((msg) => Map<String, String>.from(msg)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading chat messages: $e');
      return [];
    }
  }
  
  /// Clear all chat messages
  static Future<void> clearChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      print('Error clearing chat messages: $e');
    }
  }
}
