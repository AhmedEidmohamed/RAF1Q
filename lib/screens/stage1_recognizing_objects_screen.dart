import '../core/config/app_config.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import for web support
import 'package:universal_html/html.dart' as html show Blob, Url, AudioElement;
import '../widgets/emotion_tracker_wrapper.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/session_tracker.dart';

class RecognizingObjectsScreen extends StatefulWidget {
  const RecognizingObjectsScreen({Key? key}) : super(key: key);

  @override
  State<RecognizingObjectsScreen> createState() => _RecognizingObjectsScreenState();
}

class _RecognizingObjectsScreenState extends State<RecognizingObjectsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  String? selectedPlaceType;
  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> placeProfiles = [];
  bool isLoading = false;
  bool showInputSection = false;
  final AudioPlayer _player = AudioPlayer();
  final FirebaseService _firebaseService = FirebaseService();
  late SessionTracker _sessionTracker;

  int? currentlyPlayingProfileId;
  bool isPlaying = false;

  final String apiKey = AppConfig.elevenLabsApiKey;
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  final List<String> placeTypes = ['خضروات', 'فواكه', 'ألعاب', 'أدوات منزلية', 'حيوانات', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _sessionTracker = SessionTracker(stageNumber: 1, activityName: 'Recognizing Objects');
    _sessionTracker.startSession();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadPlaceProfiles();
    _addDefaultObjects();
    _fetchAssignedActivities();
  }

  void _fetchAssignedActivities() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firebaseService.getAssignedActivities(user.uid, 'object').listen((snapshot) {
        final newProfiles = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'place_type': data['place_type'] ?? '',
            'image_path': data['image_path'],
            'assignedAt': data['assignedAt'],
            'is_assigned': true,
          };
        }).toList();

        setState(() {
          placeProfiles.removeWhere((p) => p['is_assigned'] == true);
          placeProfiles.addAll(newProfiles);
        });
      });
    }
  }

  void _addDefaultObjects() {
    final List<Map<String, dynamic>> defaultObjects = [];
    int currentId = 1;

    String getArabicName(String filename) {
      final lower = filename.toLowerCase();
      if (lower.contains('bear')) return 'دب';
      if (lower.contains('bird')) return 'طائر';
      if (lower.contains('camel')) return 'جمل';
      if (lower.contains('cat')) return 'قطة';
      if (lower.contains('chicken')) return 'دجاجة';
      if (lower.contains('cow')) return 'بقرة';
      if (lower.contains('dog')) return 'كلب';
      if (lower.contains('donkey')) return 'حمار';
      if (lower.contains('duck')) return 'بطة';
      if (lower.contains('elephant')) return 'فيل';
      if (lower.contains('fish')) return 'سمكة';
      if (lower.contains('giraffe')) return 'زرافة';
      if (lower.contains('horse')) return 'حصان';
      if (lower.contains('lion')) return 'أسد';
      if (lower.contains('rabbit')) return 'أرنب';
      if (lower.contains('sheep')) return 'خروف';
      if (lower.contains('tiger')) return 'نمر';
      if (lower.contains('turtle')) return 'سلحفاة';
      if (lower.contains('bread')) return 'خبز';
      if (lower.contains('egg')) return 'بيضة';
      if (lower.contains('milk')) return 'حليب';
      if (lower.contains('apple')) return 'تفاحة';
      if (lower.contains('banana')) return 'موزة';
      if (lower.contains('grapes')) return 'عنب';
      if (lower.contains('mango')) return 'مانجو';
      if (lower.contains('orange')) return 'برتقالة';
      if (lower.contains('pineapple')) return 'أناناس';
      if (lower.contains('strawberry')) return 'فراولة';
      if (lower.contains('watermelon')) return 'بطيخ';
      if (lower.contains('refrigerator')) return 'ثلاجة';
      if (lower.contains('bed')) return 'سرير';
      if (lower.contains('chair')) return 'كرسي';
      if (lower.contains('play')) return 'لعبة';
      if (lower.contains('lemon')) return 'ليمون';
      if (lower.contains('carrot')) return 'جزر';
      if (lower.contains('corn')) return 'ذرة';
      if (lower.contains('cucumber')) return 'خيار';
      if (lower.contains('eggplant')) return 'باذنجان';
      if (lower.contains('onion')) return 'بصل';
      if (lower.contains('pepper')) return 'فلفل';
      if (lower.contains('potatoes')) return 'بطاطس';
      if (lower.contains('tomatoes')) return 'طماطم';
      return filename.split('.')[0];
    }

    final Set<String> addedNames = {};

    void addFromList(List<String> files, String folder, String type) {
      for (var f in files) {
        final name = getArabicName(f);
        if (!addedNames.contains(name)) {
          defaultObjects.add({
            'id': currentId++,
            'name': name,
            'place_type': type,
            'image_path': '$folder/$f',
          });
          addedNames.add(name);
        }
      }
    }

    addFromList([
      'bear1.jpg', 'bear2.jpg', 'bear3.jpg', 'bear_test.jpg', 'bird1.jpg', 'bird2.jpg', 'bird3.jpg', 'bird_test.jpg',
      'camel1.jpg', 'camel2.jpg', 'camel3.jpg', 'camel_test.jpg', 'cat1.jpg', 'cat2.jpg', 'cat3.jpg', 'cat_test.jpg',
      'chicken1.jpg', 'chicken2.jpg', 'chicken3.jpg', 'chicken_test.jpg', 'cow1.jpg', 'cow2.jpg', 'cow3.jpg', 'cow_test.jpg',
      'dog1.jpg', 'dog2.jpg', 'dog3.jpg', 'dog_test.jpg', 'donkey1.jpg', 'donkey2.jpg', 'donkey3.jpg', 'donkey_test.jpg',
      'duck1.jpg', 'duck2.jpg', 'duck3.jpg', 'duck_test.jpg', 'elephant1.jpg', 'elephant2.jpg', 'elephant3.jpg', 'elephant_test.jpg',
      'fish1.jpg', 'fish2.jpg', 'fish3.jpg', 'fish_test.jpg', 'giraffe1.jpg', 'giraffe2.jpg', 'giraffe3.jpg', 'giraffe_test.jpg',
      'horse1.jpg', 'horse2.jpg', 'horse3.jpg', 'horse_test.jpg', 'lion1.jpg', 'lion2.jpg', 'lion3.jpg', 'lion_test.jpg',
      'rabbit1.jpg', 'rabbit2.jpg', 'rabbit3.jpg', 'rabbit_test.jpg', 'sheep1.jpg', 'sheep2.jpg', 'sheep3.jpg', 'sheep_test.jpg',
      'tiger1.jpg', 'tiger2.jpg', 'tiger3.jpg', 'tiger_test.jpg', 'turtle1.jpg', 'turtle2.jpg', 'turtle3.jpg', 'turtle_test.jpg'
    ], 'animals', 'حيوانات');

    addFromList([
      'apple1.jpg', 'apple2.jpg', 'apple3.jpg', 'apple_test.jpg', 'banana1.jpg', 'banana2.jpg', 'banana3.jpg', 'banana_test.jpg',
      'grapes1.jpg', 'grapes2.jpg', 'grapes3.jpg', 'grapes_test.jpg', 'mango1.jpg', 'mango2.jpg', 'mango3.jpg', 'mango_test.jpg',
      'orange1.jpg', 'orange2.jpg', 'orange3.jpg', 'orange_test.jpg', 'pineapple1.jpg', 'pineapple2.jpg', 'pineapple3.jpg', 'pineapple_test.jpg',
      'strawberry1.jpg', 'strawberry2.jpg', 'strawberry3.jpg', 'strawberry_test.jpg', 'watermelon1.jpg', 'watermelon2.jpg', 'watermelon3.jpg', 'watermelon_test.jpg'
    ], 'fruits', 'فواكه');

    addFromList([
      'Lemon1.jpg', 'Lemon2.jpg', 'Lemon3.jpg', 'Lemon_test.jpg', 'carrot1.jpg', 'carrot2.jpg', 'carrot3.jpg', 'carrot_test.jpg',
      'corn1.jpg', 'corn2.jpg', 'corn3.jpg', 'corn_test.jpg', 'cucumber1.jpg', 'cucumber2.jpg', 'cucumber3.jpg', 'cucumber_test.jpg',
      'eggplant1.jpg', 'eggplant2.jpg', 'eggplant3.jpg', 'eggplant_test.jpg', 'onion1.jpg', 'onion2.jpg', 'onion3.jpg', 'onion_test.jpg',
      'pepper1.jpg', 'pepper2.jpg', 'pepper3.jpg', 'pepper_test.jpg', 'potatoes1.jpg', 'potatoes2.jpg', 'potatoes3.jpg', 'potatoes_test.jpg',
      'tomatoes1.jpg', 'tomatoes2.jpg', 'tomatoes3.jpg'
    ], 'vegetables', 'خضروات');

    // Home Tools
    addFromList(['Refrigerator1.jpg', 'Refrigerator2.jpg', 'Refrigerator3.jpg', 'Refrigerator_test.jpg', 'bed1.jpg', 'bed2.jpg', 'bed3.jpg', 'bed_test.jpg', 'chair1.jpg', 'chair2.jpg', 'chair3.jpg', 'chair_test.jpg', 'play1.jpg', 'play2.jpg', 'play_test.jpg'], 'home_tools', 'أدوات منزلية');

    if (placeProfiles.isEmpty) {
      setState(() => placeProfiles = defaultObjects);
    }
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    nameController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPlaceProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('object_profiles') ?? [];
      setState(() {
        placeProfiles = profilesJson.map((json) => Map<String, dynamic>.from(jsonDecode(json))).toList();
      });
    } catch (e) {
      print('Error loading: $e');
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImagePath = image.path);
  }

  Future<void> savePlaceProfile() async {
    if (nameController.text.trim().isEmpty || selectedPlaceType == null || selectedImagePath == null) return;
    setState(() => isLoading = true);
    try {
      final newProfile = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': nameController.text,
        'place_type': selectedPlaceType,
        'image_path': selectedImagePath,
      };
      placeProfiles.insert(0, newProfile);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('object_profiles', placeProfiles.map((p) => jsonEncode(p)).toList());
      setState(() { showInputSection = false; isLoading = false; nameController.clear(); selectedImagePath = null; selectedPlaceType = null; });
    } catch (e) { setState(() => isLoading = false); }
  }

  final tts.FlutterTts _flutterTts = tts.FlutterTts();

  Future<void> playVoiceForProfile(Map<String, dynamic> profile) async {
    setState(() { currentlyPlayingProfileId = profile['id']; isPlaying = true; });
    bool playedSuccessfully = false;

    try {
      final response = await http.post(
        Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId"),
        headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
        body: jsonEncode({"text": profile['name']}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        playedSuccessfully = true;
        for (int i = 0; i < 3; i++) {
          if (kIsWeb) {
            final blob = html.Blob([audioBytes], 'audio/mpeg');
            final url = html.Url.createObjectUrlFromBlob(blob);
            final audio = html.AudioElement()..src = url;
            audio.play();
            await Future.delayed(const Duration(seconds: 2));
            html.Url.revokeObjectUrl(url);
          } else {
            await _player.setSourceBytes(audioBytes);
            await _player.resume();
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    } catch (e) {
      print('ElevenLabs error: $e');
    }

    // Fallback to Flutter TTS if ElevenLabs failed
    if (!playedSuccessfully) {
      await _flutterTts.setLanguage("ar");
      await _flutterTts.setVolume(1.0);
      for (int i = 0; i < 3; i++) {
        await _flutterTts.speak(profile['name']);
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (mounted) setState(() { currentlyPlayingProfileId = null; isPlaying = false; });
  }

  void deleteProfile(Map<String, dynamic> profile) async {
    setState(() => placeProfiles.removeWhere((p) => p['id'] == profile['id']));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('object_profiles', placeProfiles.map((p) => jsonEncode(p)).toList());
  }

  void showEditOptions(Map<String, dynamic> profile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('خيارات التعديل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('تعديل الاسم'),
              onTap: () { Navigator.pop(context); _editName(profile); },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text('تعديل النوع'),
              onTap: () { Navigator.pop(context); _editType(profile); },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.purple),
              title: const Text('تعديل الصورة'),
              onTap: () { Navigator.pop(context); _editImage(profile); },
            ),
          ],
        ),
      ),
    );
  }

  void _editName(Map<String, dynamic> profile) {
    final controller = TextEditingController(text: profile['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'الاسم الجديد')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            setState(() { profile['name'] = controller.text; });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('object_profiles', placeProfiles.map((p) => jsonEncode(p)).toList());
            Navigator.pop(context);
          }, child: const Text('حفظ')),
        ],
      ),
    );
  }

  void _editType(Map<String, dynamic> profile) {
    String? newType = profile['place_type'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل النوع'),
        content: StatefulBuilder(builder: (context, setDialogState) => DropdownButton<String>(
          value: newType,
          isExpanded: true,
          items: placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setDialogState(() => newType = v),
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            setState(() { profile['place_type'] = newType; });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('object_profiles', placeProfiles.map((p) => jsonEncode(p)).toList());
            Navigator.pop(context);
          }, child: const Text('حفظ')),
        ],
      ),
    );
  }

  void _editImage(Map<String, dynamic> profile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() { profile['image_path'] = image.path; });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('object_profiles', placeProfiles.map((p) => jsonEncode(p)).toList());
    }
  }

  Widget _buildObjectImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, width: double.infinity, 
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    } else {
      // Clean path: Ensure it starts with 'assets/' but not 'assets/assets/'
      String cleanPath = path;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/assets/', 'assets/');
      } else if (!cleanPath.startsWith('assets/') && !cleanPath.startsWith('/')) {
        cleanPath = 'assets/$cleanPath';
      }

      if (cleanPath.startsWith('assets/')) {
        return Image.asset(cleanPath, fit: BoxFit.cover, width: double.infinity, 
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
      }
      return Image.file(File(path), fit: BoxFit.cover, width: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التعرف على الأشياء', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF007aff),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              const Tab(icon: Icon(Icons.pets), text: 'حيوانات'), 
              const Tab(icon: Icon(Icons.apple), text: 'فواكه'), 
              const Tab(icon: Icon(Icons.eco), text: 'خضروات'), 
              const Tab(icon: Icon(Icons.home), text: 'أدوات منزلية'),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => setState(() => showInputSection = !showInputSection)),
          ],
        ),
        body: EmotionTrackerWrapper(
          activityTitle: 'التعرف على الأشياء',
          child: Column(
            children: [
              if (showInputSection) _buildInputSection(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildObjectsGrid(placeProfiles.where((p) => p['place_type'] == 'حيوانات').toList()),
                    _buildObjectsGrid(placeProfiles.where((p) => p['place_type'] == 'فواكه').toList()),
                    _buildObjectsGrid(placeProfiles.where((p) => p['place_type'] == 'خضروات').toList()),
                    _buildObjectsGrid(placeProfiles.where((p) => p['place_type'] == 'أدوات منزلية').toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الشيء')),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedPlaceType,
            hint: const Text('اختر النوع'),
            isExpanded: true,
            items: placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => selectedPlaceType = v),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: pickImage, icon: const Icon(Icons.image), label: Text(selectedImagePath == null ? 'اختر صورة' : 'تم اختيار صورة')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: savePlaceProfile, child: const Text('حفظ'))),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => setState(() => showInputSection = false), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text('إلغاء')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectsGrid(List<Map<String, dynamic>> profiles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: profiles.length,
      itemBuilder: (context, index) => _buildObjectCard(profiles[index]),
    );
  }

  Widget _buildObjectCard(Map<String, dynamic> profile) {
    final bool isHomeTool = profile['place_type'] == 'أدوات منزلية';

    Widget cardContent = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => playVoiceForProfile(profile),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: _buildObjectImage(profile['image_path']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(profile['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => showEditOptions(profile)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => deleteProfile(profile)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isHomeTool) {
      return cardContent; // No OpenContainer for home tools
    }

    return OpenContainer(
      closedBuilder: (context, action) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () { playVoiceForProfile(profile); action(); },
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: _buildObjectImage(profile['image_path']),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(profile['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => showEditOptions(profile)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => deleteProfile(profile)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      openBuilder: (context, action) => EmotionTrackerWrapper(
        activityTitle: 'التعرف على: ${profile['name']}',
        child: _ObjectDetailWithQuiz(profile: profile, allProfiles: placeProfiles),
      ),
    );
  }
}

class _ObjectDetailWithQuiz extends StatefulWidget {
  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> allProfiles;
  const _ObjectDetailWithQuiz({Key? key, required this.profile, required this.allProfiles}) : super(key: key);
  @override
  State<_ObjectDetailWithQuiz> createState() => _ObjectDetailWithQuizState();
}

class _ObjectDetailWithQuizState extends State<_ObjectDetailWithQuiz> {
  bool _showQuiz = false;
  List<Map<String, dynamic>> _opts = [];
  int _correctIdx = -1;
  int? _selectedIdx;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildOptions();
  }

  void _buildOptions() {
    final others = widget.allProfiles.where((p) => p['name'] != widget.profile['name']).toList()..shuffle();
    _opts = [widget.profile, ...others.take(3)]..shuffle();
    _correctIdx = _opts.indexWhere((p) => p['name'] == widget.profile['name']);
    _answered = false;
    _selectedIdx = null;
  }

  Widget _buildDetailImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    } else {
      String cleanPath = path;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/assets/', 'assets/');
      } else if (!cleanPath.startsWith('assets/') && !cleanPath.startsWith('/')) {
        cleanPath = 'assets/$cleanPath';
      }

      if (cleanPath.startsWith('assets/')) {
        return Image.asset(cleanPath, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
      }
      return Image.file(File(path), fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    }
  }

  Widget _buildGridImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    } else {
      String cleanPath = path;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/assets/', 'assets/');
      } else if (!cleanPath.startsWith('assets/') && !cleanPath.startsWith('/')) {
        cleanPath = 'assets/$cleanPath';
      }

      if (cleanPath.startsWith('assets/')) {
        return Image.asset(cleanPath, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
      }
      return Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showQuiz ? _quizView() : _learnView(),
    );
  }

  Widget _learnView() {
    // Log view_item activity when this view is shown
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService().logLearningActivity(
        childId: user.uid,
        activityType: 'view_item',
        itemName: widget.profile['name'],
        category: 'object',
      );
    }

    return Column(
      children: [
        AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))),
        Expanded(child: Center(child: _buildDetailImage(widget.profile['image_path']))),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.profile['name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showQuiz = true),
                icon: const Icon(Icons.quiz),
                label: const Text('ابدأ الاختبار', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007aff), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quizView() {
    final isCorrect = _answered && _selectedIdx == _correctIdx;
    final isWrong = _answered && _selectedIdx != _correctIdx;

    return Stack(
      children: [
        Column(
          children: [
            AppBar(title: Text('أين هي ${widget.profile['name']}؟'), backgroundColor: const Color(0xFF007aff)),
            if (isWrong) Container(margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.close, color: Colors.red), SizedBox(width: 10), Text('حاول مرة أخرى!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _opts.length,
                itemBuilder: (context, i) {
                  final isC = i == _correctIdx;
                  final isS = _selectedIdx == i;
                  Color borderColor = Colors.grey.shade300;
                  if (_answered) { if (isC) borderColor = Colors.green; else if (isS) borderColor = Colors.red; }
                  return GestureDetector(
                    onTap: () {
                      if (_answered) return;
                      setState(() {
                        _selectedIdx = i;
                        _answered = true;
                      });
                      if (isC) {
                        // Log quiz_success activity
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          FirebaseService().logLearningActivity(
                            childId: user.uid,
                            activityType: 'quiz_success',
                            itemName: widget.profile['name'],
                            category: 'object',
                          );
                        }
                        Future.delayed(const Duration(seconds: 2),
                            () => Navigator.pop(context));
                      } else {
                        // Log quiz_fail activity
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          FirebaseService().logLearningActivity(
                            childId: user.uid,
                            activityType: 'quiz_fail',
                            itemName: widget.profile['name'],
                            category: 'object',
                            extraData: {'selected': _opts[i]['name']},
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: borderColor, width: 4), borderRadius: BorderRadius.circular(15)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(11), child: _buildGridImage(_opts[i]['image_path'])),
                    ),
                  );
                },
              ),
            ),
            if (isWrong) Padding(padding: const EdgeInsets.all(20), child: ElevatedButton.icon(onPressed: () => setState(() => _buildOptions()), icon: const Icon(Icons.refresh), label: const Text('حاول مرة أخرى'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007aff), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)))),
          ],
        ),
        if (isCorrect)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 20),
                        const Text(
                          'برافو!',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const Text(
                          'إجابة صحيحة!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
