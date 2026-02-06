// lib/presentation/widgets/video_player_widget.dart

// import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xtra_neo/core/theme/app_theme.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String streamUrl;
  final String channelName;
  final bool audioOnly;
  final Function(bool)? onFullscreenChanged;
  final VoidCallback? onMuteToggle;
  final bool isMuted;
  
  const VideoPlayerWidget({
    Key? key,
    required this.streamUrl,
    required this.channelName,
    this.audioOnly = false,
    this.onFullscreenChanged,
    this.onMuteToggle,
    this.isMuted = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  double _brightness = 0.5;
  double _volume = 1.0;
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  void _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.streamUrl,
        liveStream: true,
        useAsmsSubtitles: false,
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 1000,
          bufferForPlaybackAfterRebufferMs: 2000,
        ),
      );
      
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableMute: true,
          enableFullscreen: true,
          enablePlayPause: true,
          enableProgressBar: false, // Live stream
          enableSkips: false,
          enablePlaybackSpeed: false,
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onPlayerVisibilityChanged) {
            return CustomPlayerControls(
              controller: controller,
              onVisibilityChanged: onPlayerVisibilityChanged,
              channelName: widget.channelName,
              onMuteToggle: widget.onMuteToggle,
            );
          },
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Stream error occurred';
            });
          }
        },
      );
      
      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: dataSource,
      );
      
      await _betterPlayerController!.setupDataSource(dataSource);
      
      if (widget.isMuted) {
        _betterPlayerController!.setVolume(0);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load stream: $e';
      });
    }
  }
  
  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.streamUrl != widget.streamUrl) {
      _initializePlayer();
    }
    
    if (oldWidget.isMuted != widget.isMuted && _betterPlayerController != null) {
      _betterPlayerController!.setVolume(widget.isMuted ? 0 : _volume);
    }
  }
  
  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.twitchPurple,
          ),
        ),
      );
    }
    
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.accentRed,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Unknown error',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializePlayer,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Left side = brightness, right side = volume
        final screenWidth = MediaQuery.of(context).size.width;
        final isLeftSide = details.localPosition.dx < screenWidth / 2;
        
        if (isLeftSide) {
          // Brightness control
          setState(() {
            _brightness -= details.delta.dy / 500;
            _brightness = _brightness.clamp(0.0, 1.0);
          });
          // Apply brightness (would need platform channel for Android)
        } else {
          // Volume control
          setState(() {
            _volume -= details.delta.dy / 500;
            _volume = _volume.clamp(0.0, 1.0);
            _betterPlayerController?.setVolume(_volume);
          });
        }
      },
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        children: [
          BetterPlayer(controller: _betterPlayerController!),
          
          // Audio-only overlay
          if (widget.audioOnly)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.headphones,
                      size: 64,
                      color: AppTheme.twitchPurple.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Audio Only Mode',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
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
}

// ============ CUSTOM CONTROLS ============

class CustomPlayerControls extends StatelessWidget {
  final BetterPlayerController controller;
  final Function(bool) onVisibilityChanged;
  final String channelName;
  final VoidCallback? onMuteToggle;
  
  const CustomPlayerControls({
    Key? key,
    required this.controller,
    required this.onVisibilityChanged,
    required this.channelName,
    this.onMuteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: AppTheme.liveIndicator,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        channelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Open quality settings
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Center play/pause
          Center(
            child: IconButton(
              icon: Icon(
                controller.isPlaying() ?? false
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
              onPressed: () {
                if (controller.isPlaying() ?? false) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
            ),
          ),
          
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      controller.isPlaying() ?? false
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (controller.isPlaying() ?? false) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.white),
                    onPressed: onMuteToggle,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () {
                      controller.toggleFullScreen();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
