import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Smart Gallery Screen
/// Voice-controlled image gallery with swipe navigation
class SmartGalleryScreen extends StatefulWidget {
  const SmartGalleryScreen({Key? key}) : super(key: key);

  @override
  State<SmartGalleryScreen> createState() => _SmartGalleryScreenState();
}

class _SmartGalleryScreenState extends State<SmartGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentIndex = 0;

  final String apiKey = "sk_3aaa6d7ef1d79cae6aba84a6fcf0fa9f53ac64dd81fac576";
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  // Default gallery items with categories
  final List<Map<String, dynamic>> _galleryItems = [
    // Animals
    {
      'name': 'قطة',
      'category': 'حيوانات',
      'image':
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400'
    },
    {
      'name': 'كلب',
      'category': 'حيوانات',
      'image':
          'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400'
    },
    {
      'name': 'أسد',
      'category': 'حيوانات',
      'image':
          'https://images.unsplash.com/photo-1614027164847-1b28cfe1df60?w=400'
    },
    {
      'name': 'فيل',
      'category': 'حيوانات',
      'image': 'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=400'
    },
    // Fruits
    {
      'name': 'تفاح',
      'category': 'فواكه',
      'image':
          'https://images.unsplash.com/photo-1584306670957-acf935f5033c?w=400'
    },
    {
      'name': 'موز',
      'category': 'فواكه',
      'image':
          'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=400'
    },
    {
      'name': 'برتقال',
      'category': 'فواكه',
      'image':
          'https://images.unsplash.com/photo-1582979518140-5c15c6fb0ffc?w=400'
    },
    // Vegetables
    {
      'name': 'جزر',
      'category': 'خضروات',
      'image':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400'
    },
    {
      'name': 'طماطم',
      'category': 'خضروات',
      'image':
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400'
    },
  ];

  List<Map<String, dynamic>> get _animals =>
      _galleryItems.where((item) => item['category'] == 'حيوانات').toList();
  List<Map<String, dynamic>> get _fruits =>
      _galleryItems.where((item) => item['category'] == 'فواكه').toList();
  List<Map<String, dynamic>> get _vegetables =>
      _galleryItems.where((item) => item['category'] == 'خضروات').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVoice(String text) async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    try {
      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http.post(
        url,
        headers: {
          "xi-api-key": apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "text": text,
          "model_id": "eleven_monolingual_v1",
          "voice_settings": {"stability": 0.5, "similarity_boost": 0.5},
        }),
      );

      if (response.statusCode == 200) {
        await _audioPlayer.play(BytesSource(response.bodyBytes));
      }
    } catch (e) {
      print('Error playing voice: $e');
    } finally {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _nextItem(List<Map<String, dynamic>> items) {
    if (_currentIndex < items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playVoice(items[_currentIndex]['name']);
    }
  }

  void _previousItem(List<Map<String, dynamic>> items) {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _playVoice(items[_currentIndex]['name']);
    }
  }

  Widget _buildGalleryPage(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد عناصر'));
    }

    final currentItem = items[_currentIndex];

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swipe left - next
          _nextItem(items);
        } else if (details.primaryVelocity! > 0) {
          // Swipe right - previous
          _previousItem(items);
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  currentItem['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    currentItem['name'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _previousItem(items),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('السابق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _playVoice(currentItem['name']),
                        icon: _isPlaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.volume_up),
                        label: const Text('صوت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _nextItem(items),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('التالي'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentIndex + 1} / ${items.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اسحب يمين أو يسار للتنقل',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المعرض الذكي'),
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.pets), text: 'حيوانات'),
              Tab(icon: Icon(Icons.apple), text: 'فواكه'),
              Tab(icon: Icon(Icons.eco), text: 'خضروات'),
              Tab(icon: Icon(Icons.grid_view), text: 'الكل'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGalleryPage(_animals),
            _buildGalleryPage(_fruits),
            _buildGalleryPage(_vegetables),
            _buildGalleryPage(_galleryItems),
          ],
        ),
      ),
    );
  }
}
