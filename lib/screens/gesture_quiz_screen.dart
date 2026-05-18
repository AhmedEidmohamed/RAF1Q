import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'stage2_social_gestures_screen.dart';

class GestureQuizScreen extends StatefulWidget {
  final GestureData correctGesture;
  final List<GestureData> allGestures;

  const GestureQuizScreen({
    Key? key,
    required this.correctGesture,
    required this.allGestures,
  }) : super(key: key);

  @override
  State<GestureQuizScreen> createState() => _GestureQuizScreenState();
}

class _GestureQuizScreenState extends State<GestureQuizScreen> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Map<String, dynamic>> _options = [];
  final List<VideoPlayerController> _controllers = [];
  
  bool _showResult = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    List<Map<String, dynamic>> options = [];
    Random random = Random();

    // 1. Correct option
    String correctVideo = widget.correctGesture.testVideoUrls.isNotEmpty 
        ? widget.correctGesture.testVideoUrls[random.nextInt(widget.correctGesture.testVideoUrls.length)]
        : widget.correctGesture.practiceVideoUrls.first; // Fallback
        
    options.add({
      'videoUrl': correctVideo,
      'isCorrect': true,
      'gesture': widget.correctGesture,
    });

    // 2. Wrong options
    List<GestureData> otherGestures = widget.allGestures.where((g) => g.id != widget.correctGesture.id).toList();
    otherGestures.shuffle(random);
    
    int wrongCount = min(3, otherGestures.length);
    for (int i = 0; i < wrongCount; i++) {
      GestureData wrongGesture = otherGestures[i];
      String wrongVideo = wrongGesture.testVideoUrls.isNotEmpty
          ? wrongGesture.testVideoUrls[random.nextInt(wrongGesture.testVideoUrls.length)]
          : wrongGesture.practiceVideoUrls.first; // Fallback
          
      options.add({
        'videoUrl': wrongVideo,
        'isCorrect': false,
        'gesture': wrongGesture,
      });
    }

    // Shuffle options
    options.shuffle(random);

    setState(() {
      _options = options;
    });

    // Initialize Video Controllers
    for (var option in _options) {
      String url = option['videoUrl'];
      VideoPlayerController controller = url.startsWith('assets/')
          ? VideoPlayerController.asset(url)
          : VideoPlayerController.networkUrl(Uri.parse(url));
          
      _controllers.add(controller);
      
      try {
        await controller.initialize();
        controller.setLooping(true);
        controller.setVolume(0.0); // silent autoplay
        controller.play();
        if (mounted) setState(() {}); // Refresh to show video
      } catch (e) {
        print("Error initializing video in quiz: $e");
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onOptionSelected(int index) {
    if (_showResult) return;

    setState(() {
      _selectedIndex = index;
      _showResult = true;
    });

    bool isCorrect = _options[index]['isCorrect'];
    if (isCorrect) {
      _confettiController.play();
      _playSuccessSound();
      
      // Delay and pop back to social gestures screen
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop(); // Pops Quiz screen
        }
      });
    } else {
      _playErrorSound();
      // Allow them to try again after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showResult = false;
            _selectedIndex = null;
          });
        }
      });
    }
  }

  Future<void> _playSuccessSound() async {
    // In a real scenario, use ElevenLabs or a local success asset
    // Here we'll just try to play if a sound asset exists or silently skip
  }

  Future<void> _playErrorSound() async {
    // Error sound logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar with Close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // spacer
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
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

                // Title
                Text(
                  'أين هو "${widget.correctGesture.title}"؟',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 40),

                // Grid of Videos
                Expanded(
                  child: _options.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0, // square items
                            ),
                            itemCount: _options.length,
                            itemBuilder: (context, index) {
                              bool isSelected = _selectedIndex == index;
                              bool isCorrect = _options[index]['isCorrect'];
                              
                              Color borderColor = Colors.transparent;
                              if (_showResult && isSelected) {
                                borderColor = isCorrect ? Colors.green : Colors.red;
                              }

                              VideoPlayerController? controller;
                              if (index < _controllers.length) {
                                controller = _controllers[index];
                              }

                              return GestureDetector(
                                onTap: () => _onOptionSelected(index),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: borderColor,
                                      width: isSelected ? 4 : 0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: controller != null && controller.value.isInitialized
                                        ? IgnorePointer(
                                            child: AspectRatio(
                                              aspectRatio: controller.value.aspectRatio,
                                              child: VideoPlayer(controller),
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
