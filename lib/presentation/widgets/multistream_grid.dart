// lib/presentation/widgets/multistream_grid.dart

import 'package:flutter/material.dart';
import 'package:xtra_neo/core/theme/app_theme.dart';

class MultiStreamGrid extends StatefulWidget {
  const MultiStreamGrid({Key? key}) : super(key: key);

  @override
  State<MultiStreamGrid> createState() => _MultiStreamGridState();
}

class _MultiStreamGridState extends State<MultiStreamGrid> {
  final List<StreamData> _streams = [];
  final Set<int> _mutedStreams = {};
  GridLayout _currentLayout = GridLayout.single;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.amoledBlack,
      appBar: AppBar(
        title: const Text('Multistream'),
        actions: [
          // Layout selector
          PopupMenuButton<GridLayout>(
            icon: const Icon(Icons.grid_view),
            onSelected: (layout) {
              setState(() {
                _currentLayout = layout;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GridLayout.single,
                child: Row(
                  children: [
                    Icon(Icons.crop_square),
                    SizedBox(width: 8),
                    Text('1x1 Single'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.twoVertical,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda),
                    SizedBox(width: 8),
                    Text('2x1 Vertical'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.twoHorizontal,
                child: Row(
                  children: [
                    Icon(Icons.view_day),
                    SizedBox(width: 8),
                    Text('1x2 Horizontal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.fourGrid,
                child: Row(
                  children: [
                    Icon(Icons.grid_4x4),
                    SizedBox(width: 8),
                    Text('2x2 Grid'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GridLayout.pip,
                child: Row(
                  children: [
                    Icon(Icons.picture_in_picture),
                    SizedBox(width: 8),
                    Text('Picture in Picture'),
                  ],
                ),
              ),
            ],
          ),
          
          // Add stream button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _canAddStream() ? _showAddStreamDialog : null,
          ),
        ],
      ),
      body: _streams.isEmpty
          ? _buildEmptyState()
          : _buildStreamGrid(),
    );
  }
  
  bool _canAddStream() {
    return _streams.length < _getMaxStreamsForLayout(_currentLayout);
  }
  
  int _getMaxStreamsForLayout(GridLayout layout) {
    switch (layout) {
      case GridLayout.single:
        return 1;
      case GridLayout.twoVertical:
      case GridLayout.twoHorizontal:
      case GridLayout.pip:
        return 2;
      case GridLayout.fourGrid:
        return 4;
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No streams added',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddStreamDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Stream'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreamGrid() {
    switch (_currentLayout) {
      case GridLayout.single:
        return _buildSingleStream();
      case GridLayout.twoVertical:
        return _buildTwoVertical();
      case GridLayout.twoHorizontal:
        return _buildTwoHorizontal();
      case GridLayout.fourGrid:
        return _buildFourGrid();
      case GridLayout.pip:
        return _buildPictureInPicture();
    }
  }
  
  Widget _buildSingleStream() {
    if (_streams.isEmpty) return const SizedBox();
    
    return _buildStreamCard(0, fullSize: true);
  }
  
  Widget _buildTwoVertical() {
    return Column(
      children: [
        Expanded(child: _buildStreamCard(0)),
        if (_streams.length > 1) Expanded(child: _buildStreamCard(1)),
      ],
    );
  }
  
  Widget _buildTwoHorizontal() {
    return Row(
      children: [
        Expanded(child: _buildStreamCard(0)),
        if (_streams.length > 1) Expanded(child: _buildStreamCard(1)),
      ],
    );
  }
  
  Widget _buildFourGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildStreamCard(0)),
              if (_streams.length > 1) Expanded(child: _buildStreamCard(1)),
            ],
          ),
        ),
        if (_streams.length > 2)
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildStreamCard(2)),
                if (_streams.length > 3) Expanded(child: _buildStreamCard(3)),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildPictureInPicture() {
    return Stack(
      children: [
        // Main stream (background)
        _buildStreamCard(0, fullSize: true),
        
        // PiP stream (foreground)
        if (_streams.length > 1)
          Positioned(
            right: 16,
            bottom: 16,
            width: 160,
            height: 90,
            child: _buildStreamCard(1, isPip: true),
          ),
      ],
    );
  }
  
  Widget _buildStreamCard(int index, {bool fullSize = false, bool isPip = false}) {
    if (index >= _streams.length) {
      return Container(
        margin: const EdgeInsets.all(2),
        color: AppTheme.darkGrey,
      );
    }
    
    final stream = _streams[index];
    final isMuted = _mutedStreams.contains(index);
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: AppTheme.twitchPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          VideoPlayerWidget(
            streamUrl: stream.streamUrl,
            channelName: stream.channelName,
            audioOnly: stream.audioOnly,
            isMuted: isMuted,
            onMuteToggle: () {
              setState(() {
                if (isMuted) {
                  _mutedStreams.remove(index);
                } else {
                  _mutedStreams.add(index);
                }
              });
            },
          ),
          
          // Controls overlay
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                // Mute toggle
                _buildControlButton(
                  icon: isMuted ? Icons.volume_off : Icons.volume_up,
                  onPressed: () {
                    setState(() {
                      if (isMuted) {
                        _mutedStreams.remove(index);
                      } else {
                        _mutedStreams.add(index);
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                
                // Audio-only toggle
                _buildControlButton(
                  icon: stream.audioOnly ? Icons.headphones : Icons.videocam,
                  onPressed: () {
                    setState(() {
                      _streams[index] = stream.copyWith(
                        audioOnly: !stream.audioOnly,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                
                // Remove stream
                _buildControlButton(
                  icon: Icons.close,
                  onPressed: () {
                    setState(() {
                      _streams.removeAt(index);
                      _mutedStreams.remove(index);
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Channel name
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    stream.platform == StreamPlatform.twitch
                        ? Icons.play_arrow
                        : Icons.sports_esports,
                    size: 16,
                    color: stream.platform == StreamPlatform.twitch
                        ? AppTheme.twitchPurple
                        : AppTheme.kickGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stream.channelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        iconSize: 20,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        onPressed: onPressed,
      ),
    );
  }
  
  void _showAddStreamDialog() {
    final platformController = ValueNotifier<StreamPlatform>(StreamPlatform.twitch);
    final usernameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text('Add Stream'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Platform selector
            ValueListenableBuilder<StreamPlatform>(
              valueListenable: platformController,
              builder: (context, platform, _) {
                return SegmentedButton<StreamPlatform>(
                  segments: const [
                    ButtonSegment(
                      value: StreamPlatform.twitch,
                      label: Text('Twitch'),
                      icon: Icon(Icons.play_arrow),
                    ),
                    ButtonSegment(
                      value: StreamPlatform.kick,
                      label: Text('Kick'),
                      icon: Icon(Icons.sports_esports),
                    ),
                  ],
                  selected: {platform},
                  onSelectionChanged: (Set<StreamPlatform> newSelection) {
                    platformController.value = newSelection.first;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Username input
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Channel Username',
                hintText: 'Enter username...',
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                _addStream(
                  username,
                  platformController.value,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _addStream(String username, StreamPlatform platform) {
    // This would fetch the actual stream URL from the datasource
    // For now, using placeholder
    setState(() {
      _streams.add(StreamData(
        channelName: username,
        streamUrl: 'https://example.com/stream.m3u8', // Placeholder
        platform: platform,
      ));
    });
    
    // TODO: Actually fetch stream URL from TwitchDataSource or KickDataSource
  }
}

// ============ MODELS ============

enum GridLayout {
  single,
  twoVertical,
  twoHorizontal,
  fourGrid,
  pip,
}

enum StreamPlatform {
  twitch,
  kick,
}

class StreamData {
  final String channelName;
  final String streamUrl;
  final StreamPlatform platform;
  final bool audioOnly;
  
  StreamData({
    required this.channelName,
    required this.streamUrl,
    required this.platform,
    this.audioOnly = false,
  });
  
  StreamData copyWith({
    String? channelName,
    String? streamUrl,
    StreamPlatform? platform,
    bool? audioOnly,
  }) {
    return StreamData(
      channelName: channelName ?? this.channelName,
      streamUrl: streamUrl ?? this.streamUrl,
      platform: platform ?? this.platform,
      audioOnly: audioOnly ?? this.audioOnly,
    );
  }
}
