import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/session_tracker.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/video_player_widget.dart';
import 'gesture_practice_screen.dart';

class SocialGesturesScreen extends StatefulWidget {
  const SocialGesturesScreen({Key? key}) : super(key: key);

  @override
  State<SocialGesturesScreen> createState() => _SocialGesturesScreenState();
}

class _SocialGesturesScreenState extends State<SocialGesturesScreen> {
  late SessionTracker _sessionTracker;

  @override
  void initState() {
    super.initState();
    _sessionTracker =
        SessionTracker(stageNumber: 2, activityName: 'Social Gestures');
    _sessionTracker.startSession();
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    super.dispose();
  }

  void _onGestureTap(GestureData gesture) {
    // Log view_item activity
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService().logLearningActivity(
        childId: user.uid,
        activityType: 'view_item',
        itemName: gesture.title,
        category: 'gesture',
      );
    }
  }

  void _playVideoAndPractice(BuildContext context, GestureData gesture, List<GestureData> allGestures) {
    _onGestureTap(gesture);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GesturePracticeScreen(
          gesture: gesture,
          allGestures: allGestures,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    final List<GestureData> gestures = [
      GestureData(
        id: 'hello',
        title: AppLocalizations.t('hello', locale: currentLanguage),
        description: '',
        emoji: '👋',
        imageUrl:
            'https://images.unsplash.com/photo-1758739203060-79d89e818c9a?w=600',
        practiceVideoUrls: ['assets/signs/handshake1.mp4', 'assets/signs/handshake2.mp4', 'assets/signs/handshake3.mp4'],
        testVideoUrls: ['assets/signs/handshake_test1.mp4', 'assets/signs/handshake_test2.mp4'],
      ),
      GestureData(
        id: 'yes',
        title: AppLocalizations.t('yes', locale: currentLanguage),
        description: '',
        emoji: '👍',
        imageUrl:
            'https://images.unsplash.com/photo-1629839423284-9499d8aa4857?w=600',
        practiceVideoUrls: ['assets/signs/yes1.mp4', 'assets/signs/yes2.mp4', 'assets/signs/yes3.mp4'],
        testVideoUrls: ['assets/signs/yes_test1.mp4', 'assets/signs/yes_test2.mp4'],
      ),
      GestureData(
        id: 'no',
        title: AppLocalizations.t('no', locale: currentLanguage),
        description: '',
        emoji: '🙅',
        imageUrl:
            'https://images.unsplash.com/photo-1767858898988-ba0fa7a6c22f?w=600',
        practiceVideoUrls: ['assets/signs/no1.mp4', 'assets/signs/no2.mp4', 'assets/signs/no3.mp4'],
        testVideoUrls: ['assets/signs/no_test1.mp4', 'assets/signs/no_test2.mp4'],
      ),
      GestureData(
        id: 'bye',
        title: AppLocalizations.t('bye', locale: currentLanguage),
        description: '',
        emoji: '👋',
        imageUrl:
            'https://images.unsplash.com/photo-1758598738033-2368946ce823?w=600',
        practiceVideoUrls: ['assets/signs/bye1.mp4', 'assets/signs/bye2.mp4', 'assets/signs/bye3.mp4'],
        testVideoUrls: ['assets/signs/bye_test1.mp4', 'assets/signs/bye_test2.mp4'],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: CustomAppBar(
        title: AppLocalizations.t('social_gestures', locale: currentLanguage),
        subtitle: AppLocalizations.t('learn_communicate_gestures', locale: currentLanguage),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeroSection(context, gestures.first, gestures),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gestures.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return GestureCardWidget(
                    gesture: gestures[index],
                    allGestures: gestures,
                    onPlay: () => _playVideoAndPractice(context, gestures[index], gestures),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, GestureData firstGesture, List<GestureData> allGestures) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Blue Part
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF234C9E), 
              borderRadius: BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFFB0D5FF),
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'جرب الإشارات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'الذكاء الاصطناعي سيحلل حركتك الآن!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => GesturePracticeScreen(
                             gesture: firstGesture,
                             allGestures: allGestures,
                           ),
                         ),
                       );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF2FD),
                      foregroundColor: const Color(0xFF234C9E),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'جرب الآن',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom White Part
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مستوى التقدم:\n0%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                    ),
                    Row(
                      children: [
                        const Text(
                          'تدريب: الإشارات\nالاجتماعية',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF234C9E),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.back_hand, color: Color(0xFF234C9E), size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.05,
                    minHeight: 8,
                    backgroundColor: Color(0xFFF0F5FF),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF234C9E)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ساعد طفلك على فهم الإشارات الاجتماعية من خلال مجموعة مختارة من التمارين التفاعلية المدعومة بالصور والفيديوهات. واصل التدريب لتحقيق الاتقان!',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class GestureCardWidget extends StatefulWidget {
  final GestureData gesture;
  final List<GestureData> allGestures;
  final VoidCallback onPlay;

  const GestureCardWidget({
    Key? key,
    required this.gesture,
    required this.allGestures,
    required this.onPlay,
  }) : super(key: key);

  @override
  State<GestureCardWidget> createState() => _GestureCardWidgetState();
}

class _GestureCardWidgetState extends State<GestureCardWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    String url = widget.gesture.practiceVideoUrls.first;
    _controller = url.startsWith('assets/')
        ? VideoPlayerController.asset(url)
        : VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing thumbnail video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Thumbnail with Video Badge and Play Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _controller != null && _controller!.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              ),
              // Overlay Dark tint
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              // Video Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FD).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'فيديو',
                    style: TextStyle(
                      color: Color(0xFF234C9E),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Play Icon
              Positioned.fill(
                child: Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 80,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Text(
              widget.gesture.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          
          // Button
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onPlay,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF234C9E),
                  side: const BorderSide(color: Color(0xFF234C9E), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'ابدأ التدريب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GestureData {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String imageUrl;
  final List<String> practiceVideoUrls;
  final List<String> testVideoUrls;

  GestureData({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.imageUrl,
    required this.practiceVideoUrls,
    required this.testVideoUrls,
  });
}
