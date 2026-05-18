import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/voice_chat_service.dart';
import '../services/chat_storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _voiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
    _initializeAndStart();
  }

  Future<void> _initializeAndStart() async {
    // 1. Initialize voice services
    _voiceInitialized = await VoiceChatService.initializeVoiceServices();
    
    if (mounted) {
      setState(() {});
    }

    // 2. Initial greeting if conversation is empty
    if (messages.isEmpty) {
      const greeting = "أهلاً يا بطل! أنا رفيق، المساعد الذكي بتاعك.. تحب نتكلم في إيه النهاردة؟";
      setState(() {
        messages.add({'bot': greeting});
        _isLoading = false;
      });
      
      // 3. (Removed) Speak the greeting and then start listening automatically
      // if (_voiceInitialized) {
      //   await VoiceChatService.speak(greeting);
      //   _voiceChat(); // Start listening automatically
      // }
    }
  }

  /// Load saved chat messages from storage
  Future<void> _loadChatMessages() async {
    final savedMessages = await ChatStorageService.loadChatMessages();
    if (mounted) {
      setState(() {
        messages.clear();
        messages.addAll(savedMessages);
      });
    }
  }

  /// Save current chat messages to storage
  Future<void> _saveChatMessages() async {
    await ChatStorageService.saveChatMessages(messages);
  }

  void send() async {
    final userMsg = controller.text.trim();
    if (userMsg.isEmpty) return;

    controller.clear();

    setState(() {
      messages.add({'user': userMsg});
      _isLoading = true;
    });

    final reply = await ChatService.sendMessage(userMsg);

    setState(() {
      messages.add({'bot': reply});
      _isLoading = false;
    });

    // Save messages after bot reply
    await _saveChatMessages();
  }

  Future<void> _voiceChat() async {
    if (!_voiceInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خدمة الصوت غير متاحة')),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });

    try {
      // Listen to user voice
      String? userMessage = await VoiceChatService.startListening();

      if (userMessage == null || userMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('لم أتمكن من سماعك، يرجى المحاولة مرة أخرى')),
        );
        return;
      }

      setState(() {
        messages.add({'user': userMessage});
        _isLoading = true;
        // Auto-populate input field with recognized speech
        controller.text = userMessage;
        _isListening = false;
      });

      // Get AI response
      final reply = await ChatService.sendMessage(userMessage);

      setState(() {
        messages.add({'bot': reply});
        _isLoading = false;
      });

      // Speak the response (Removed auto-speak)
      // await VoiceChatService.speak(reply);

      // Save messages
      await _saveChatMessages();
    } catch (e) {
      setState(() {
        _isListening = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في المحادثة الصوتية')),
      );
    }
  }

  /// Show confirmation dialog to clear chat
  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح المحادثة'),
          content: const Text('هل أنت متأكد من أنك تريد مسح جميع الرسائل؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ChatStorageService.clearChatMessages();
                if (mounted) {
                  setState(() {
                    messages.clear();
                  });
                }
              },
              child: const Text('مسح', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اسأل رفيق"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () => _showClearChatDialog(context),
            tooltip: 'مسح المحادثة',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[100]!,
                              Colors.grey[50]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "الرفيق: جاري الرد...",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = messages[index];
                  if (msg.containsKey('user')) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['user']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[100]!,
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.transparent,
                                child: Image.asset('assets/images/robot_avatar.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "الرفيق",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_voiceInitialized)
                                          GestureDetector(
                                            onTap: () => VoiceChatService.speak(msg['bot']!),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.volume_up_rounded,
                                                size: 16,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['bot']!,
                                      style: const TextStyle(
                                        color: Color(0xFF2D3748),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "اكتب رسالتك هنا",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _isListening
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Voice button
                  if (_voiceInitialized)
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [Colors.red, Colors.redAccent]
                              : [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary)
                                .withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed:
                            (_isLoading || _isListening) ? null : _voiceChat,
                        tooltip: 'تحدث الآن',
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading ? null : send,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
