import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Utils/chat_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Add this

// Message model to store chat history
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ChatbotMediumScreen extends StatefulWidget {
  final ChatService chatService; // Using the enhanced chat service

  const ChatbotMediumScreen({Key? key, required this.chatService}) : super(key: key);

  @override
  State<ChatbotMediumScreen> createState() => _ChatbotMediumScreenState();
}

class _ChatbotMediumScreenState extends State<ChatbotMediumScreen>
    with TickerProviderStateMixin {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Speech to text variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize speech recognition
    _initSpeechRecognition();

    // Load both UI history and service conversation history
    _loadChatHistory();
    widget.chatService.loadConversationHistory();

    // Start the typing animation
    _fadeController.repeat();
  }

// Initialize speech recognition
  void _initSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
        setState(() {
          _isListening = _speech.isListening;
        });
      },
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _isListening = false;
        });
      },
    );

    if (available) {
      print('Speech recognition is available');
    } else {
      print('Speech recognition is not available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop(); // Stop speech recognition
    _speech.cancel(); // Cancel any ongoing recognition
    super.dispose();
  }

  // Start listening to user's speech
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = '';
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              _messageController.text = _recognizedText;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          localeId: "en_US", // Set language to English
          onSoundLevelChange: (level) {
            // Optional: Add visual feedback for sound level
          },
        );
      } else {
        print("Speech recognition not available");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    }
  }

// Stop listening
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });

      // If we have recognized text, send it automatically after a short delay
      if (_recognizedText.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendMessage();
        });
      }
    }
  }

// Handle mic button tap
  void _handleMicTap() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history');
    if (historyJson != null) {
      final List<dynamic> historyList = jsonDecode(historyJson);
      setState(() {
        _messages.addAll(
          historyList.map((json) => ChatMessage.fromJson(json)).toList(),
        );
      });
      _scrollToBottom();
    }
  }


  //fetch api key from firestore database
  static Future<String?> fetchApiKey() async {
    try {
      final doc = await _firestore.collection('apikey').doc('apikey').get();
      if (doc.exists) {
        final data = doc.data();
        return data?['apikey'] as String?;
      } else {
        print('⚠️ No API key document found.');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching API key: $e');
      return null;
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(
      _messages.map((message) => message.toJson()).toList(),
    );
    await prefs.setString('chat_history', historyJson);
  }

  // Clear chat history (updated to clear both UI and service history)
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    await widget.chatService.clearConversation();
    setState(() {
      _messages.clear();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _slideController.forward();

    try {
      final response = await widget.chatService.sendMessage(text,fetchApiKey());
      final botMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });

      _saveChatHistory();
      _scrollToBottom();
    } catch (e) {
      print("Exception occured: $e");
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I couldn't process your message. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  // Updated AppBar with conversation stats
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF2E7D32),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Islamic Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Ask about Islam',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Clear history button
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title:  Text('Clear Chat History', style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                content:  Text(
                  'This will clear all messages and conversation memory. Are you sure?',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF2E7D32))),
        ],
      ),
    );
  }

  void _showExportDialog(String exportData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversation Export'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              exportData,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: exportData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              100, // Approximate input area height
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Assalamu Alaikum',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to your Islamic Assistant\nAsk any question about Islam',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestedQuestions(),
            // Add some extra space at the bottom when keyboard is visible
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'How to perform Wudu?',
      'Times of daily prayers',
      'What is Tawheed?',
      'Benefits of reading Quran',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            child: InkWell(
              onTap: () {
                _messageController.text = suggestion;
                _sendMessage();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  Future<void> _shareMessage(String text) async {
    await Share.share(text);
  }

  void _deleteMessage(ChatMessage message) {
    setState(() {
      _messages.remove(message);
    });
    _saveChatHistory(); // Update saved chat
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy"),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.text));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied")),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share"),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareMessage(message.text);
                },
              ),

              //if (message.isUser)  // Only allow deleting user's messages (optional)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete"),
                onTap: () {
                  _deleteMessage(message);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: message.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF2E7D32)
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                        bottomRight: Radius.circular(message.isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: message.isUser
                        ? Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                        : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p:  TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        em: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                        listBullet: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 15,
                        ),
                        h1: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        h2: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        h3: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey[100],
                          color: Colors.black87,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquote: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF2E7D32),
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeInOut,
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(
              0.3 + (0.7 * ((1 + math.cos(_fadeController.value * 2 * math.pi + (index * 0.5))) / 2)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final bool showMicButton = _messageController.text.isEmpty || _isListening;
    final bool showSendButton = _messageController.text.isNotEmpty && !_isListening;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF2E7D32).withOpacity(0.2),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: _isListening ? 'Listening...' : 'Ask about Islam...',
                        hintStyle: TextStyle(
                          color: _isListening
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: _isListening
                            ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.mic,
                            color: const Color(0xFF2E7D32),
                            size: 20,
                          ),
                        )
                            : null,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (text) {
                        // Auto-scroll when typing
                        if (_messages.isNotEmpty) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollToBottom();
                          });
                        }

                        // Update UI when text changes
                        setState(() {});
                      },
                    ),
                    // Add listening animation overlay
                    if (_isListening)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2E7D32).withOpacity(0.3),
                                const Color(0xFF2E7D32),
                                const Color(0xFF2E7D32).withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: const _ListeningAnimation(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Dynamic Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red
                    : const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                    : null,
              ),
              child: IconButton(
                onPressed: () {
                  if (_isListening) {
                    // Stop listening
                    _stopListening();
                  } else if (_messageController.text.isNotEmpty) {
                    // Send message
                    _sendMessage();
                  } else {
                    // Start listening
                    _startListening();
                  }
                },
                icon: _buildDynamicIcon(),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build the dynamic icon
  Widget _buildDynamicIcon() {
    if (_isListening) {
      return const Icon(Icons.stop, size: 20);
    } else if (_messageController.text.isNotEmpty) {
      return const Icon(Icons.send, size: 20);
    } else {
      return const Icon(Icons.mic, size: 20);
    }
  }



  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

}

// Add this widget class inside the same file (outside _ChatbotMediumScreenState)
class _ListeningAnimation extends StatefulWidget {
  const _ListeningAnimation();

  @override
  _ListeningAnimationState createState() => _ListeningAnimationState();
}

class _ListeningAnimationState extends State<_ListeningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: _animation.value * 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}