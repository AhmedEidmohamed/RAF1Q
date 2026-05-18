import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html show Blob, Url, AudioElement;
import 'package:flutter/foundation.dart';
import 'stage2_social_gestures_screen.dart';
import 'gesture_quiz_screen.dart';

class GesturePracticeScreen extends StatefulWidget {
  final GestureData gesture;
  final List<GestureData> allGestures;

  const GesturePracticeScreen({
    Key? key,
    required this.gesture,
    required this.allGestures,
  }) : super(key: key);

  @override
  State<GesturePracticeScreen> createState() => _GesturePracticeScreenState();
}

class _GesturePracticeScreenState extends State<GesturePracticeScreen> {
  int _currentIndex = 0;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  final AudioPlayer _player = AudioPlayer();

  final String apiKey = "sk_3aaa6d7ef1d79cae6aba84a6fcf0fa9f53ac64dd81fac576";
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _hasError = false;
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    try {
      String videoUrl = widget.gesture.practiceVideoUrls[_currentIndex];
      bool isAsset = videoUrl.startsWith('assets/');

      _videoPlayerController = isAsset
          ? VideoPlayerController.asset(videoUrl)
          : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Video Player Error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _playGestureVoice() async {
    try {
      final url = Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId");

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": widget.gesture.title}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        if (kIsWeb) {
          final blob = html.Blob([audioBytes], 'audio/mpeg');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final audio = html.AudioElement();
          audio.src = url;
          audio.play();
          audio.onEnded.listen((_) => html.Url.revokeObjectUrl(url));
        } else {
          await _player.setSourceBytes(audioBytes);
          await _player.resume();
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _onNextPressed() {
    if (_currentIndex < widget.gesture.practiceVideoUrls.length - 1) {
      setState(() {
        _currentIndex++;
        _initializePlayer();
      });
    } else {
      // Go to Quiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GestureQuizScreen(
            correctGesture: widget.gesture,
            allGestures: widget.allGestures,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLastVideo = _currentIndex == widget.gesture.practiceVideoUrls.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer for balance
                  Text(
                    widget.gesture.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Video Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _hasError
                        ? Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Text(
                                'لا يمكن تشغيل الفيديو',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : _chewieController != null &&
                                _chewieController!.videoPlayerController.value.isInitialized
                            ? Chewie(controller: _chewieController!)
                            : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                children: [
                  // Audio Button
                  InkWell(
                    onTap: _playGestureVoice,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE3F2FD), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.headphones,
                        color: Color(0xFF2854C5),
                        size: 28,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Next / Test Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2854C5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        isLastVideo ? 'انتقل للاختبار' : 'التالي',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
