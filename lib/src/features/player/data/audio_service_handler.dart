import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/player_state_model.dart';

class RadioAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();

  RadioAudioHandler() {
    _init();
  }

  void _init() {
    print("🎧 Initializing RadioAudioHandler...");

    // Initialize playback state
    playbackState.add(PlaybackState(
      controls: [],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    // Listen to audio player state changes
    _player.playerStateStream.listen((playerState) {
      print(
          "🔊 Player state changed: playing=${playerState.playing}, processing=${playerState.processingState}");
      _broadcastState(playerState);
    });

    // Listen to current position for progress updates
    _player.positionStream.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(
        updatePosition: position,
      ));
    });

    print("✅ RadioAudioHandler initialized");
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    List<MediaControl> controls = [];

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      controls = [
        MediaControl.stop,
      ];
    } else if (processingState != ProcessingState.completed) {
      controls = [
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ];
    }

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[processingState] ??
          AudioProcessingState.idle,
      playing: isPlaying,
      updatePosition: _player.position,
    ));
  }

  @override
  Future<void> play() async {
    try {
      print("▶️ Resuming playback...");
      await _player.play();
    } catch (e) {
      print('❌ Error playing audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      print("⏸️ Pausing playback...");
      await _player.pause();
    } catch (e) {
      print('❌ Error pausing audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      print("⏹️ Stopping playback...");
      await _player.stop();

      // Clear the current media item
      mediaItem.add(null);

      // Set stopped state
      playbackState.add(PlaybackState(
        controls: [],
        systemActions: const {
          MediaAction.play,
        },
        androidCompactActionIndices: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ));

      print("✅ Playback stopped successfully");
    } catch (e) {
      print('❌ Error stopping audio: $e');
      rethrow;
    }
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> playStation(
      String streamUrl, String title, String artist, String? artUri) async {
    try {
      print("📻 Setting up radio station: $title");

      // Set media item for system UI first
      final mediaItem = MediaItem(
        id: streamUrl,
        album: 'Turkish Radio',
        title: title,
        artist: artist,
        artUri: artUri != null && artUri.isNotEmpty ? Uri.parse(artUri) : null,
        playable: true,
        duration: Duration.zero, // Radio streams don't have duration
        extras: {
          'isLive': true,
          'streamUrl': streamUrl,
        },
      );

      // Update media item
      this.mediaItem.add(mediaItem);

      // Set loading state
      playbackState.add(PlaybackState(
        controls: [MediaControl.stop],
        systemActions: const {
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.loading,
        playing: false,
        updatePosition: Duration.zero,
      ));

      // Set the audio source
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: mediaItem,
        ),
      );

      print("🎵 Audio source set, starting playback...");

      // Start playing
      await _player.play();

      print("✅ Radio station started successfully");
    } catch (e) {
      print('❌ Error setting up station: $e');

      // Set error state
      playbackState.add(PlaybackState(
        controls: [MediaControl.play],
        systemActions: const {
          MediaAction.play,
        },
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.error,
        playing: false,
        updatePosition: Duration.zero,
      ));

      throw e;
    }
  }

  // Get current player state
  PlayerStateModel get currentPlayerState {
    final playerState = _player.playerState;
    final currentMedia = mediaItem.value;

    return PlayerStateModel(
      isPlaying: playerState.playing,
      isLoading: playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering,
      currentStation: currentMedia != null
          ? CurrentStationInfo(
              id: currentMedia.id,
              name: currentMedia.title,
              artist: currentMedia.artist ?? '',
              logoUrl: currentMedia.artUri?.toString(),
            )
          : null,
      position: _player.position,
      error: null,
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    print("🗑️ Task removed - continuing background playback");
    // Don't stop playback when task is removed (background support)
    // Only stop if user explicitly stops from notification
  }

  @override
  Future<void> onNotificationDeleted() async {
    print("🗑️ Notification deleted - stopping playback");
    await stop();
  }

  void disposePlayer() {
    print("🔄 Disposing audio player...");
    _player.dispose();
  }
}
