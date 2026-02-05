// lib/presentation/widgets/chat_widget.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:xtra_neo/core/theme/app_theme.dart';
import 'package:xtra_neo/data/datasources/emotes/emotes_datasource.dart';

class ChatWidget extends StatefulWidget {
  final String channelId;
  final String channelName;
  final Stream<ChatMessage> messageStream;
  
  const ChatWidget({
    Key? key,
    required this.channelId,
    required this.channelName,
    required this.messageStream,
  }) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final EmotesDataSource _emotesDataSource = EmotesDataSource();
  
  Map<String, Emote> _emotes = {};
  bool _autoScroll = true;
  bool _showTimestamps = false;
  
  @override
  void initState() {
    super.initState();
    _loadEmotes();
    _listenToMessages();
  }
  
  void _loadEmotes() async {
    try {
      final emotes = await _emotesDataSource.getAllEmotes(widget.channelId);
      setState(() {
        _emotes = emotes;
      });
    } catch (e) {
      print('Failed to load emotes: $e');
    }
  }
  
  void _listenToMessages() {
    widget.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
        
        // Limit chat history
        if (_messages.length > 500) {
          _messages.removeAt(0);
        }
      });
      
      if (_autoScroll) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.chatBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }
  
  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, size: 20),
          const SizedBox(width: 8),
          Text(
            'Chat - ${widget.channelName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          
          // Auto-scroll toggle
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.arrow_downward : Icons.pause,
              size: 20,
            ),
            tooltip: _autoScroll ? 'Pause auto-scroll' : 'Resume auto-scroll',
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
            },
          ),
          
          // Settings
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'timestamps',
                checked: _showTimestamps,
                child: const Text('Show timestamps'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat'),
              ),
            ],
            onSelected: (value) {
              if (value == 'timestamps') {
                setState(() {
                  _showTimestamps = !_showTimestamps;
                });
              } else if (value == 'clear') {
                setState(() {
                  _messages.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessages() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final isAtBottom = _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50;
          
          if (_autoScroll != isAtBottom) {
            setState(() {
              _autoScroll = isAtBottom;
            });
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return _buildChatMessage(_messages[index]);
        },
      ),
    );
  }
  
  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp (optional)
          if (_showTimestamps)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ),
          
          // Badges
          if (message.badges.isNotEmpty)
            ...message.badges.map((badge) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CachedNetworkImage(
                imageUrl: badge,
                width: 18,
                height: 18,
              ),
            )),
          
          // Username
          Text(
            '${message.username}: ',
            style: TextStyle(
              color: message.color ?? AppTheme.chatUsername,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          
          // Message with emotes
          Expanded(
            child: _buildMessageContent(message),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageContent(ChatMessage message) {
    final parts = _parseMessageWithEmotes(message.message);
    
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        if (part is String) {
          return Text(
            part,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          );
        } else if (part is Emote) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CachedNetworkImage(
              imageUrl: part.url,
              height: 28,
              width: 28,
              placeholder: (context, url) => const SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Text(
                part.name,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          );
        }
        return const SizedBox();
      }).toList(),
    );
  }
  
  List<dynamic> _parseMessageWithEmotes(String message) {
    final parts = <dynamic>[];
    final words = message.split(' ');
    
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      
      if (_emotes.containsKey(word)) {
        parts.add(_emotes[word]!);
      } else {
        parts.add(word);
      }
      
      if (i < words.length - 1) {
        parts.add(' ');
      }
    }
    
    return parts;
  }
  
  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Send a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.darkGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              _showEmotePicker();
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppTheme.twitchPurple,
            onPressed: () {
              // Send message
            },
          ),
        ],
      ),
    );
  }
  
  void _showEmotePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardGrey,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Emotes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _emotes.length,
                  itemBuilder: (context, index) {
                    final emote = _emotes.values.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        // Insert emote into text field
                        Navigator.pop(context);
                      },
                      child: CachedNetworkImage(
                        imageUrl: emote.url,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

// ============ CHAT MESSAGE MODEL ============

class ChatMessage {
  final String username;
  final String message;
  final Color? color;
  final List<String> badges;
  final DateTime timestamp;
  
  ChatMessage({
    required this.username,
    required this.message,
    this.color,
    this.badges = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
