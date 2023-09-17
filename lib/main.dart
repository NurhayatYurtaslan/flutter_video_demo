import 'dart:core';

import 'package:flutter/material.dart';
import 'package:native_video_player/native_video_player.dart';

class ExampleVideoSource {
  final String path;
  final VideoSourceType type;

  ExampleVideoSource({
    required this.path,
    required this.type,
  });
}

final videoSources = [
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  ExampleVideoSource(path: 'assets/video/01.mp4', type: VideoSourceType.asset),
  // ExampleVideoSource(path: 'assets/video/07.webm', type: VideoSourceType.asset),
  ExampleVideoSource(
    path:
        'https://file-examples.com/storage/fea8fc38fd63bc5c39cf20b/2017/04/file_example_MP4_480_1_5MG.mp4',
    type: VideoSourceType.network,
  ),
];

void main() {
  runApp(
    const AppView(),
  );
}

enum AppRoute {
  videoPlayer,
  videoList,
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  var _appRoute = AppRoute.videoPlayer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _buildBodyView(),
        bottomNavigationBar: BottomNavigationView(
          selectedAppRoute: _appRoute,
          onAppRouteSelected: (appRoute) {
            setState(() {
              _appRoute = appRoute;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBodyView() {
    switch (_appRoute) {
      case AppRoute.videoPlayer:
        return const VideoPlayerScreenView();
      case AppRoute.videoList:
        return const VideoListScreenView();
    }
  }
}

class BottomNavigationView extends StatelessWidget {
  final AppRoute selectedAppRoute;
  final void Function(AppRoute) onAppRouteSelected;

  const BottomNavigationView({
    super.key,
    required this.selectedAppRoute,
    required this.onAppRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_display),
          label: 'Video Player',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_stream),
          label: 'Video List',
        ),
      ],
      currentIndex: selectedAppRoute.index,
      onTap: (index) => onAppRouteSelected(AppRoute.values[index]),
    );
  }
}

class VideoPlayerScreenView extends StatefulWidget {
  const VideoPlayerScreenView({super.key});

  @override
  State<VideoPlayerScreenView> createState() => _VideoPlayerScreenViewState();
}

class _VideoPlayerScreenViewState extends State<VideoPlayerScreenView> {
  var _selectedVideoSource = videoSources.first;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: VideoPlayerView(
                videoSource: _selectedVideoSource,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: VideoCarouselView(
                onVideoSourceSelected: (videoSource) {
                  setState(() {
                    _selectedVideoSource = videoSource;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class VideoCarouselView extends StatelessWidget {
  final void Function(ExampleVideoSource) onVideoSourceSelected;

  const VideoCarouselView({
    super.key,
    required this.onVideoSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: videoSources.length,
      itemBuilder: (context, index) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              NativeVideoPlayerView(
                onViewReady: (controller) async {
                  final videoSource = await VideoSource.init(
                    type: videoSources[index].type,
                    path: videoSources[index].path,
                  );
                  await controller.loadVideoSource(videoSource);
                },
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onVideoSourceSelected(videoSources[index]);
                  },
                  child: Container(),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(width: 8);
      },
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  final ExampleVideoSource videoSource;

  const VideoPlayerView({
    super.key,
    required this.videoSource,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  NativeVideoPlayerController? _controller;

  bool isAutoplayEnabled = false;
  bool isPlaybackLoopEnabled = false;

  @override
  void didUpdateWidget(VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _loadVideoSource();
    }
  }

  Future<void> _initController(NativeVideoPlayerController controller) async {
    _controller = controller;

    _controller?. //
        onPlaybackStatusChanged
        .addListener(_onPlaybackStatusChanged);
    _controller?. //
        onPlaybackPositionChanged
        .addListener(_onPlaybackPositionChanged);
    _controller?. //
        onPlaybackSpeedChanged
        .addListener(_onPlaybackSpeedChanged);
    _controller?. //
        onVolumeChanged
        .addListener(_onPlaybackVolumeChanged);
    _controller?. //
        onPlaybackReady
        .addListener(_onPlaybackReady);
    _controller?. //
        onPlaybackEnded
        .addListener(_onPlaybackEnded);

    await _loadVideoSource();
  }

  Future<void> _loadVideoSource() async {
    final videoSource = await _createVideoSource();
    await _controller?.loadVideoSource(videoSource);
  }

  Future<VideoSource> _createVideoSource() async {
    return VideoSource.init(
      path: widget.videoSource.path,
      type: widget.videoSource.type,
    );
  }

  @override
  void dispose() {
    _controller?. //
        onPlaybackStatusChanged
        .removeListener(_onPlaybackStatusChanged);
    _controller?. //
        onPlaybackPositionChanged
        .removeListener(_onPlaybackPositionChanged);
    _controller?. //
        onPlaybackSpeedChanged
        .removeListener(_onPlaybackSpeedChanged);
    _controller?. //
        onVolumeChanged
        .removeListener(_onPlaybackVolumeChanged);
    _controller?. //
        onPlaybackReady
        .removeListener(_onPlaybackReady);
    _controller?. //
        onPlaybackEnded
        .removeListener(_onPlaybackEnded);
    _controller = null;
    super.dispose();
  }

  void _onPlaybackReady() {
    setState(() {});
    if (isAutoplayEnabled) {
      _controller?.play();
    }
  }

  void _onPlaybackStatusChanged() {
    setState(() {});
  }

  void _onPlaybackPositionChanged() {
    setState(() {});
  }

  void _onPlaybackSpeedChanged() {
    setState(() {});
  }

  void _onPlaybackVolumeChanged() {
    setState(() {});
  }

  void _onPlaybackEnded() {
    if (isPlaybackLoopEnabled) {
      _controller?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: isAutoplayEnabled,
              onChanged: (value) {
                setState(() => isAutoplayEnabled = value ?? false);
              },
            ),
            const Text('Autoplay'),
            const SizedBox(width: 24),
            Checkbox(
              value: isPlaybackLoopEnabled,
              onChanged: (value) {
                setState(() => isPlaybackLoopEnabled = value ?? false);
              },
            ),
            const Text('Playback loop'),
          ],
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: NativeVideoPlayerView(
            onViewReady: _initController,
          ),
        ),
        Slider(
          // min: 0,
          max: (_controller?.videoInfo?.duration ?? 0).toDouble(),
          value: (_controller?.playbackInfo?.position ?? 0).toDouble(),
          onChanged: (value) => _controller?.seekTo(value.toInt()),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              formatDuration(
                Duration(seconds: _controller?.playbackInfo?.position ?? 0),
              ),
            ),
            const Spacer(),
            Text(
              formatDuration(
                Duration(seconds: _controller?.videoInfo?.duration ?? 0),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _controller?.play(),
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => _controller?.pause(),
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _controller?.stop(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.fast_rewind),
              onPressed: () => _controller?.seekBackward(5),
            ),
            IconButton(
              icon: const Icon(Icons.fast_forward),
              onPressed: () => _controller?.seekForward(5),
            ),
            const Spacer(),
            _buildPlaybackStatusView(),
          ],
        ),
        Row(
          children: [
            Text('''
Volume: ${_controller?.playbackInfo?.volume.toStringAsFixed(2)}'''),
            Expanded(
              child: Slider(
                value: _controller?.playbackInfo?.volume ?? 0,
                onChanged: (value) => _controller?.setVolume(value),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('''
Speed: ${_controller?.playbackInfo?.speed.toStringAsFixed(2)}'''),
            Expanded(
              child: Slider(
                value: _controller?.playbackInfo?.speed ?? 1,
                onChanged: (value) => _controller?.setPlaybackSpeed(value),
                min: 0.25,
                max: 2,
                divisions: (2 - 0.25) ~/ 0.25,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackStatusView() {
    const size = 16.0;
    final color = Colors.black.withOpacity(0.3);
    switch (_controller?.playbackInfo?.status) {
      case PlaybackStatus.playing:
        return Icon(Icons.play_arrow, size: size, color: color);
      case PlaybackStatus.paused:
        return Icon(Icons.pause, size: size, color: color);
      case PlaybackStatus.stopped:
        return Icon(Icons.stop, size: size, color: color);
      default:
        return Container();
    }
  }
}

class VideoListScreenView extends StatelessWidget {
  const VideoListScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const VideoListView();
  }
}

class VideoListView extends StatelessWidget {
  const VideoListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return VideoListItemView(
          videoSource: videoSources[index],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: videoSources.length,
    );
  }
}

class VideoListItemView extends StatefulWidget {
  final ExampleVideoSource videoSource;

  const VideoListItemView({
    super.key,
    required this.videoSource,
  });

  @override
  State<VideoListItemView> createState() => _VideoListItemViewState();
}

class _VideoListItemViewState extends State<VideoListItemView> {
  NativeVideoPlayerController? _controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          NativeVideoPlayerView(
            onViewReady: (controller) async {
              _controller = controller;
              await _controller?.setVolume(1);
              await _loadVideoSource();
            },
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _togglePlayback,
              child: Center(
                child: FutureBuilder(
                  future: _isPlaying,
                  initialData: false,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    final isPlaying = snapshot.data ?? false;
                    return Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 64,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVideoSource() async {
    final videoSource = await VideoSource.init(
      type: widget.videoSource.type,
      path: widget.videoSource.path,
    );
    await _controller?.loadVideoSource(videoSource);
  }

  Future<void> _togglePlayback() async {
    final isPlaying = await _isPlaying;
    if (isPlaying) {
      await _controller?.pause();
    } else {
      await _controller?.play();
    }
    setState(() {});
  }

  Future<bool> get _isPlaying async => await _controller?.isPlaying() ?? false;
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
