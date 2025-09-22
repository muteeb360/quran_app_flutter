import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationMessage {
  final String role; // 'user', 'assistant', or 'system'
  final String content;
  final DateTime timestamp;

  ConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) => ConversationMessage(
    role: json['role'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  // For API calls (without timestamp)
  Map<String, dynamic> toApiFormat() => {
    'role': role,
    'content': content,
  };
}

class ChatService {
  final String? apiUrl = dotenv.env['BASE_URL'];
  final String? apiKey = dotenv.env['API_KEY'];

  // Conversation management
  final List<ConversationMessage> _conversationHistory = [];
  String? _conversationSummary;

  // Configuration
  static const int maxMessagesBeforeSummary = 10; // Summarize after 10 messages
  static const int messagesToKeepAfterSummary = 4; // Keep last 4 messages + summary
  static const String conversationSummaryKey = 'conversation_summary';
  static const String conversationHistoryKey = 'conversation_history';

  // System prompt for the Islamic AI
  final String systemPrompt = """You are an Islamic AI assistant. ✅ Your sole purpose is to answer questions strictly related to Islam — including Qur'an, Hadith (Sahih al-Bukhari, Sahih Muslim, Sunan Abu Dawood, Jami at-Tirmidhi, Sunan an-Nasa'i, Sunan Ibn Majah), classical and contemporary scholars, and the major schools of thought (Hanafi, Shafi'i, Maliki, Hanbali, and Jafari). ❌ Do not answer general life, entertainment, or unrelated questions. If the user asks anything outside Islam, politely reply: *This model is for Islamic knowledge and cannot be used for other discussions.*

📖 Rules for responses:
- Always provide **authentic references** (Qur'an verse with Surah:Ayah, Hadith collection + number).
- Where differences exist, explain **views of different fiqhs/scholars** briefly.
- Write in a **friendly, simple, and sympathetic tone** so anyone can understand.
- Use **decorative formatting**: highlight key terms, citations and refrences in **bold**, use bullet points or short paragraphs for clarity.
- Citations should be simple and clear (e.g., *Qur'an 2:255*, *Sahih al-Bukhari 1:1*).
- If something is uncertain or disputed, explain the ambiguity honestly and avoid giving a false ruling.
- Keep answers concise and avoid token wastage while still being complete.
- Remember previous questions and context in our conversation to provide more personalized and coherent responses.
- Highlight key terms, Hadiths and Quran's refrences and citations in **bold**

Your mission is to guide with compassion, clarity, and authenticity — strictly based on Islamic sources. Keep responses under 500 to 800 words.""";

  // Load conversation history from storage
  Future<void> loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load summary
      _conversationSummary = prefs.getString(conversationSummaryKey);

      // Load conversation history
      final historyJson = prefs.getString(conversationHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _conversationHistory.clear();
        _conversationHistory.addAll(
          historyList.map((json) => ConversationMessage.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print('Error loading conversation history: $e');
    }
  }

  // Save conversation history to storage
  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save summary
      if (_conversationSummary != null) {
        await prefs.setString(conversationSummaryKey, _conversationSummary!);
      }

      // Save conversation history
      final historyJson = jsonEncode(
        _conversationHistory.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString(conversationHistoryKey, historyJson);
    } catch (e) {
      print('Error saving conversation history: $e');
    }
  }

  // Create conversation summary when history gets too long
  Future<void> _summarizeConversation() async {
    if (_conversationHistory.length < maxMessagesBeforeSummary) return;

    try {
      // Create messages for summarization (exclude system message)
      final messagesToSummarize = _conversationHistory
          .where((msg) => msg.role != 'system')
          .take(_conversationHistory.length - messagesToKeepAfterSummary)
          .toList();

      if (messagesToSummarize.isEmpty) return;

      // Create summarization prompt
      final conversationText = messagesToSummarize
          .map((msg) => '${msg.role.toUpperCase()}: ${msg.content}')
          .join('\n\n');

      final summarizationPrompt = """Please create a concise summary of this Islamic discussion that preserves:
1. Key topics discussed (prayers, fiqh, Quranic verses, etc.)
2. Important references mentioned (specific verses, hadiths)
3. User's specific interests or recurring questions
4. Any scholarly opinions or schools of thought mentioned

Previous summary (if any): ${_conversationSummary ?? 'None'}

Recent conversation to summarize:
$conversationText

Provide a comprehensive but concise summary in 2-3 paragraphs that will help maintain context for future responses:""";

      // Call API for summarization
      final response = await http.post(
        Uri.parse(apiUrl!),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "temperature": 0.1, // Lower temperature for more consistent summaries
          "messages": [
            {"role": "system", "content": "You are a helpful assistant that creates concise, accurate summaries of Islamic discussions."},
            {"role": "user", "content": summarizationPrompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _conversationSummary = data["choices"][0]["message"]["content"];

        // Remove old messages, keep recent ones
        final messagesToKeep = _conversationHistory
            .skip(_conversationHistory.length - messagesToKeepAfterSummary)
            .toList();

        _conversationHistory.clear();
        _conversationHistory.addAll(messagesToKeep);

        await _saveConversationHistory();

        print('Conversation summarized. Kept ${messagesToKeep.length} recent messages.');
      }
    } catch (e) {
      print('Error creating summary: $e');
    }
  }

  // Send message with full conversation context
  Future<String> sendMessage(String userMessage) async {
    try {
      // Load conversation if not already loaded
      if (_conversationHistory.isEmpty) {
        await loadConversationHistory();
      }

      // Add user message to history
      _conversationHistory.add(ConversationMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ));

      // Prepare messages for API call
      final List<Map<String, dynamic>> apiMessages = [];

      // 1. Add system message with summary context
      String systemMessageWithContext = systemPrompt;
      if (_conversationSummary != null) {
        systemMessageWithContext += "\n\n**Previous Conversation Summary:**\n$_conversationSummary";
      }

      apiMessages.add({
        "role": "system",
        "content": systemMessageWithContext
      });

      // 2. Add recent conversation history (excluding system messages)
      final recentMessages = _conversationHistory
          .where((msg) => msg.role != 'system')
          .map((msg) => msg.toApiFormat())
          .toList();

      apiMessages.addAll(recentMessages);

      // Make API call
      final response = await http.post(
        Uri.parse(apiUrl!),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "temperature": 0.3,
          "messages": apiMessages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantResponse = data["choices"][0]["message"]["content"];

        // Add assistant response to history
        _conversationHistory.add(ConversationMessage(
          role: 'assistant',
          content: assistantResponse,
          timestamp: DateTime.now(),
        ));

        // Save conversation
        await _saveConversationHistory();

        // Check if we need to summarize
        await _summarizeConversation();

        return assistantResponse;
      } else {
        throw Exception("Failed to fetch response: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error in sendMessage: $e");
    }
  }

  // Clear conversation history and summary
  Future<void> clearConversation() async {
    try {
      _conversationHistory.clear();
      _conversationSummary = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(conversationSummaryKey);
      await prefs.remove(conversationHistoryKey);

      print('Conversation cleared successfully');
    } catch (e) {
      print('Error clearing conversation: $e');
    }
  }

  // Get conversation stats
  Map<String, dynamic> getConversationStats() {
    return {
      'totalMessages': _conversationHistory.length,
      'hasSummary': _conversationSummary != null,
      'summaryLength': _conversationSummary?.length ?? 0,
      'oldestMessage': _conversationHistory.isNotEmpty
          ? _conversationHistory.first.timestamp.toIso8601String()
          : null,
      'newestMessage': _conversationHistory.isNotEmpty
          ? _conversationHistory.last.timestamp.toIso8601String()
          : null,
    };
  }

  // Export conversation for debugging/analysis
  Future<String> exportConversation() async {
    final export = {
      'summary': _conversationSummary,
      'messages': _conversationHistory.map((msg) => msg.toJson()).toList(),
      'stats': getConversationStats(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    return jsonEncode(export);
  }
}