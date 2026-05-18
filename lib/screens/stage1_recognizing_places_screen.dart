import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
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

/// Stage 1B: Recognizing Places Screen
/// Cards showing familiar places with first-person voice pronunciation
class RecognizingPlacesScreen extends StatefulWidget {
  const RecognizingPlacesScreen({Key? key}) : super(key: key);

  @override
  State<RecognizingPlacesScreen> createState() =>
      _RecognizingPlacesScreenState();
}

class _RecognizingPlacesScreenState extends State<RecognizingPlacesScreen> {
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

  // Animation state variables
  int? currentlyPlayingProfileId;
  bool isPlaying = false;

  final String apiKey = "sk_3aaa6d7ef1d79cae6aba84a6fcf0fa9f53ac64dd81fac576";
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  final List<String> placeTypes = [
    'المنزل',
    'المدرسة',
    'المستشفى',
    'المطعم',
    'الحديقة',
    'المسجد',
    'الكنيسة',
    'المكتبة',
    'المحل التجاري',
    'أخرى',
  ];

  final Map<String, List<String>> placeExamples = {
    'المنزل': ['غرفة المعيشة', 'المطبخ', 'الحمام', 'غرفة النوم', 'غرفة الضيوف'],
    'المدرسة': ['الفصل', 'المكتبة', 'المختبر', 'الممرج', 'الملاعب'],
    'المستشفى': [
      'غرفة الطبيب',
      'غرفة العمليات',
      'الطوارئ',
      'الصيدلية',
      'غرفة الانتظار'
    ],
    'المطعم': ['مطعم شعبي', 'مطعم فاستفود', 'كافتيريا', 'مقهى', 'مخبز'],
    'الحديقة': [
      'حديقة عامة',
      'حديقة حيوانات',
      'ملعب أطفال',
      'حديقة نباتات',
      'ملعب رياضة'
    ],
    'المسجد': ['المصلى', 'الوضوء', 'الساحة الخارجية', 'المكتبة', 'غرفة الوضوء'],
    'الكنيسة': [
      'الكنيسة الرئيسية',
      'قاعة الاجتماعات',
      'غرفة الدراسة',
      'المكتبة',
      'حديقة الكنيسة'
    ],
    'المكتبة': [
      'قاعة القراءة',
      'قسم الأطفال',
      'المكتبة الرقمية',
      'قسم المراجع',
      'غرفة الأنشطة'
    ],
    'المحل التجاري': [
      'سوبر ماركت',
      'مخبز خضروات',
      'محل ملابس',
      'صيدلية',
      'مطعم'
    ],
    'أخرى': ['محطة البنزين', 'المطار', 'الميناء', 'النادي', 'السينما'],
  };

  @override
  void initState() {
    super.initState();
    _sessionTracker =
        SessionTracker(stageNumber: 1, activityName: 'Recognizing Places');
    _sessionTracker.startSession();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadPlaceProfiles();
    _addDefaultPlaces();
    _fetchAssignedActivities();
  }

  void _fetchAssignedActivities() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firebaseService
          .getAssignedActivities(user.uid, 'place')
          .listen((snapshot) {
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

        // Sort by assignedAt descending
        newProfiles.sort((a, b) {
          final aTime = a['assignedAt'] as Timestamp?;
          final bTime = b['assignedAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        setState(() {
          placeProfiles.removeWhere((p) => p['is_assigned'] == true);
          placeProfiles.addAll(newProfiles);
        });
      });
    }
  }

  void _addDefaultPlaces() {
    // إضافة أماكن افتراضية بصور واقعية من النت
    final List<Map<String, dynamic>> defaultPlaces = [
      {
        'id': -1,
        'name': 'غرفة المعيشة',
        'place_type': 'المنزل',
        'image_path':
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -2,
        'name': 'المطبخ',
        'place_type': 'المنزل',
        'image_path':
            'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -3,
        'name': 'الفصل',
        'place_type': 'المدرسة',
        'image_path':
            'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -4,
        'name': 'حديقة عامة',
        'place_type': 'الحديقة',
        'image_path':
            'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -5,
        'name': 'المسجد',
        'place_type': 'المسجد',
        'image_path':
            'https://images.unsplash.com/photo-1545167496-c935c937f943?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -6,
        'name': 'المكتبة',
        'place_type': 'المكتبة',
        'image_path':
            'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -7,
        'name': 'المطعم',
        'place_type': 'المطعم',
        'image_path':
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': -8,
        'name': 'المستشفى',
        'place_type': 'المستشفى',
        'image_path':
            'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    // Always add default places alongside user profiles
    setState(() {
      // Add default places first (so they take priority in deduplication)
      final combined = [...defaultPlaces, ...placeProfiles];

      // Remove duplicates by name, keeping first occurrence (default places)
      final seenNames = <String>{};
      final uniquePlaces = <Map<String, dynamic>>[];

      for (var place in combined) {
        final name = place['name'] as String?;

        if (name == null) continue;

        // Skip if we've seen this name before
        if (seenNames.contains(name)) continue;

        // Add this place (default places come first so they are kept)
        seenNames.add(name);
        uniquePlaces.add(place);
      }

      placeProfiles = uniquePlaces;
    });
  }

  bool _isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
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
      final profilesJson = prefs.getStringList('place_profiles') ?? [];

      setState(() {
        placeProfiles = profilesJson.map((json) {
          return Map<String, dynamic>.from(jsonDecode(json));
        }).toList();

        // If no profiles exist, start with empty list (no demo data)
        if (placeProfiles.isEmpty) {
          placeProfiles = [];
        }
      });
    } catch (e) {
      print('Error loading place profiles: $e');
      setState(() {
        placeProfiles = [];
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في اختيار الصورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> generateVoice() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال اسم المكان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPlaceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار نوع المكان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // بناء الجملة بالعمية
      String sentence = "ده ${nameController.text}";

      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": sentence}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        await _player.setSourceBytes(audioBytes);
        await _player.resume();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل الصوت بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إنشاء الصوت: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> savePlaceProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال اسم المكان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPlaceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار نوع المكان'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء رفع صورة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> newProfile = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': nameController.text,
        'place_type': selectedPlaceType,
        'image_path': selectedImagePath,
        'created_at': DateTime.now().toIso8601String(),
      };

      placeProfiles.insert(0, newProfile);

      // حفظ في التخزين الدائم
      final prefs = await SharedPreferences.getInstance();
      final profilesJson =
          placeProfiles.map((profile) => jsonEncode(profile)).toList();
      await prefs.setStringList('place_profiles', profilesJson);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الملف الصوتي بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // مسح الحقول وإغلاق جزء الإدخال
      setState(() {
        nameController.clear();
        selectedPlaceType = null;
        selectedImagePath = null;
        isLoading = false;
        showInputSection = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> playVoiceForProfile(Map<String, dynamic> profile) async {
    try {
      // Start animation
      setState(() {
        currentlyPlayingProfileId = profile['id'];
        isPlaying = true;
      });

      // بناء الجملة بالعمية
      String sentence = "ده ${profile['name']}";

      print('Playing voice for place: ${profile['name']}');
      print('Sentence: $sentence');
      print('API Key: ${apiKey.substring(0, 10)}...');
      print('Voice ID: $voiceId');

      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": sentence}),
          )
          .timeout(Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        try {
          // Try different audio player methods
          if (audioBytes.isNotEmpty) {
            // Check if running on web
            if (kIsWeb) {
              try {
                await _playAudioOnWebWithRepetition(
                    audioBytes, profile['name']);
              } catch (e) {
                print('Web audio failed: $e');
                throw e;
              }
            } else {
              // Method 1: audioplayers (for mobile/desktop)
              try {
                await _playAudioWithRepetition(audioBytes, profile['name']);
              } catch (e) {
                print('audioplayers failed: $e');

                // Method 2: Save to temp file and play (fallback)
                try {
                  final tempDir = Directory.systemTemp;
                  final tempFile = File(
                      '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
                  await tempFile.writeAsBytes(audioBytes);

                  await _playAudioWithRepetitionFromFile(
                      tempFile, profile['name']);

                  // Clean up temp file after playing
                  Future.delayed(Duration(seconds: 15), () {
                    if (tempFile.existsSync()) {
                      tempFile.delete();
                    }
                  });
                } catch (e2) {
                  print('Temp file method failed: $e2');
                  throw e2;
                }
              }
            }
          }
        } catch (audioError) {
          print('Audio player error: $audioError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('مشكلة في تشغيل الصوت: $audioError'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('Failed to generate voice. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تشغيل الصوت: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Stop animation when done or if error occurs
      if (mounted) {
        setState(() {
          currentlyPlayingProfileId = null;
          isPlaying = false;
        });
      }
    }
  }

  // Helper method for playing audio with repetition (mobile/desktop)
  Future<void> _playAudioWithRepetition(
      Uint8List audioBytes, String name) async {
    print('Starting audio repetition for place: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing repetition $i/3 for place: $name');
        await _player.setSourceBytes(audioBytes);
        await _player.resume();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل صوت: $name ($i/3)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Wait for audio to finish before next repetition
        await Future.delayed(Duration(seconds: 4));
      } catch (e) {
        print('Error in repetition $i: $e');
        break;
      }
    }
    print('Finished audio repetition for place: $name');
  }

  // Helper method for playing audio with repetition from file
  Future<void> _playAudioWithRepetitionFromFile(
      File audioFile, String name) async {
    print('Starting audio repetition from file for place: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing repetition $i/3 for place: $name');
        await _player.setSourceDeviceFile(audioFile.path);
        await _player.resume();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل صوت: $name ($i/3)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Wait for audio to finish before next repetition
        await Future.delayed(Duration(seconds: 4));
      } catch (e) {
        print('Error in repetition $i: $e');
        break;
      }
    }
    print('Finished audio repetition from file for place: $name');
  }

  // Helper method for web audio with repetition
  Future<void> _playAudioOnWebWithRepetition(
      Uint8List audioBytes, String name) async {
    print('Starting web audio repetition for place: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing web repetition $i/3 for place: $name');
        // Create a blob from the audio bytes
        final blob = html.Blob([audioBytes], 'audio/mpeg');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create audio element and play
        final audio = html.AudioElement();
        audio.src = url;
        audio.play();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل صوت: $name ($i/3)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Wait for audio to finish
        await Future.delayed(Duration(seconds: 4));

        // Clean up the URL
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        print('Error in web repetition $i: $e');
        break;
      }
    }
    print('Finished web audio repetition for place: $name');
  }

  Widget _buildInputSection() {
    if (!showInputSection) return SizedBox.shrink();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حقل إدخال الاسم
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'اسم المكان',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم المكان هنا',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),

            SizedBox(height: 16),

            // اختيار نوع المكان
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نوع المكان',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    hint: Text('اختر نوع المكان'),
                    value: selectedPlaceType,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: placeTypes.map((String placeType) {
                      return DropdownMenuItem<String>(
                        value: placeType,
                        child:
                            Text(placeType, textDirection: TextDirection.rtl),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPlaceType = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // رفع الصورة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الصورة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildImageWidget(),
              ],
            ),

            SizedBox(height: 20),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : generateVoice,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.volume_up),
                    label: Text(isLoading ? 'جاري التحميل...' : 'تشغيل الصوت'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : savePlaceProfile,
                    icon: Icon(Icons.save),
                    label: Text('حفظ الملف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showInputSection = false;
                      nameController.clear();
                      selectedPlaceType = null;
                      selectedImagePath = null;
                    });
                  },
                  icon: Icon(Icons.close),
                  label: Text('إلغاء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: selectedImagePath == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 40, color: Colors.grey.shade400),
                SizedBox(height: 8),
                Text(
                  'لم يتم اختيار صورة',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.upload),
                  label: Text('رفع صورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 50,
                        color: Colors.green.shade600,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'تم رفع الصورة بنجاح',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      setState(() {
                        selectedImagePath = null;
                      });
                    },
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التعرف على الأماكن',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF007aff),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.quiz,
              color: Colors.white,
            ),
            onPressed: () {
              if (placeProfiles.length >= 3) {
                Navigator.pushNamed(context, '/test-places');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('يجب إضافة على الأقل 3 أماكن لإجراء الاختبار'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showInputSection = !showInputSection;
              });
            },
          ),
        ],
      ),
      body: EmotionTrackerWrapper(
        activityTitle: 'التعرف على الأماكن',
        child: Column(
          children: [
          // جزء الإدخال المتحرك
          showInputSection
              ? Expanded(flex: 2, child: _buildInputSection())
              : SizedBox.shrink(),

          // عرض الملفات المحفوظة
          Expanded(
            child: placeProfiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'لا توجد ملفات محفوظة',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'اضغط على زر (+) لإضافة مكان جديد',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: placeProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = placeProfiles[index];
                        final isCurrentlyPlaying =
                            currentlyPlayingProfileId == profile['id'] &&
                                isPlaying;

                        return OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          transitionDuration: Duration(milliseconds: 500),
                          closedColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedElevation: 0,
                          openElevation: 0,
                          closedBuilder: (context, action) {
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  action();
                                  playVoiceForProfile(profile);
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(15),
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(15),
                                              ),
                                              child: profile['image_path'] !=
                                                      null
                                                  ? _isNetworkImage(
                                                          profile['image_path'])
                                                      ? Image.network(
                                                          profile['image_path'],
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Icon(
                                                              Icons.place,
                                                              size: 80,
                                                              color: Colors
                                                                  .orange
                                                                  .shade700,
                                                            );
                                                          },
                                                        )
                                                      : Image.file(
                                                          File(profile[
                                                              'image_path']),
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Icon(
                                                              Icons.place,
                                                              size: 80,
                                                              color: Colors
                                                                  .orange
                                                                  .shade700,
                                                            );
                                                          },
                                                        )
                                                  : Icon(
                                                      Icons.place,
                                                      size: 80,
                                                      color: Colors
                                                          .orange.shade700,
                                                    ),
                                            ),
                                          ),
                                          // أيقونة التعديل فوق الصورة
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  showEditOptions(profile),
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.grey[700],
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // نوع المكان أولاً ثم اسم المكان مع أيقونة الصوت جنبهم
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${profile['place_type']} ${profile['name']} ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  Icons.volume_up,
                                                  color: Colors.orange[700],
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          openBuilder: (context, action) {
                            // Log view_item activity
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              FirebaseService().logLearningActivity(
                                childId: user.uid,
                                activityType: 'view_item',
                                itemName: profile['name'],
                                category: 'place',
                              );
                            }

                            return EmotionTrackerWrapper(
                              activityTitle: 'التعرف على: ${profile['name']}',
                              child: Scaffold(
                                backgroundColor: Colors.black,
                                body: SafeArea(
                                  child: Column(
                                    children: [
                                      // Top bar with back button
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    40), // Balance for centering
                                          ],
                                        ),
                                      ),
                                      // Image takes remaining space
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          child: profile['image_path'] != null
                                              ? _isNetworkImage(
                                                      profile['image_path'])
                                                  ? Image.network(
                                                      profile['image_path'],
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: Colors
                                                              .orange.shade100,
                                                          child: Icon(
                                                            Icons.place,
                                                            size: 100,
                                                            color: Colors
                                                                .orange.shade700,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Image.file(
                                                      File(profile['image_path']),
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: Colors
                                                              .orange.shade100,
                                                          child: Icon(
                                                            Icons.place,
                                                            size: 100,
                                                            color: Colors
                                                                .orange.shade700,
                                                          ),
                                                        );
                                                      },
                                                    )
                                              : Container(
                                                  color: Colors.orange.shade100,
                                                  child: Icon(
                                                    Icons.place,
                                                    size: 100,
                                                    color: Colors.orange.shade700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Fixed height text at bottom
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(20),
                                        color: Colors.black,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              profile['name'],
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              profile['place_type'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

  Future<void> deletePlaceProfile(Map<String, dynamic> profile) async {
    try {
      setState(() {
        placeProfiles.removeWhere((p) => p['id'] == profile['id']);
      });

      // Update persistent storage
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = placeProfiles.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('place_profiles', profilesJson);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف ${profile['name']} بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في الحذف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دوال التعديل والحذف للأماكن
  void showEditOptions(Map<String, dynamic> profile) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'خيارات التعديل',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('تعديل اسم المكان'),
              onTap: () {
                Navigator.pop(context);
                _editPlaceName(profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.green),
              title: Text('تعديل نوع المكان'),
              onTap: () {
                Navigator.pop(context);
                _editPlaceType(profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.orange),
              title: Text('تعديل الصورة'),
              onTap: () {
                Navigator.pop(context);
                _editPlaceImage(profile);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('حذف المكان'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editPlaceName(Map<String, dynamic> profile) {
    final TextEditingController editController =
        TextEditingController(text: profile['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل اسم المكان'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'أدخل الاسم الجديد',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                try {
                  setState(() {
                    profile['name'] = editController.text.trim();
                  });

                  // Update persistent storage
                  final prefs = await SharedPreferences.getInstance();
                  final profilesJson =
                      placeProfiles.map((p) => jsonEncode(p)).toList();
                  await prefs.setStringList('place_profiles', profilesJson);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث الاسم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في التحديث: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _editPlaceType(Map<String, dynamic> profile) {
    String? selectedType = profile['place_type'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل نوع المكان'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            hint: Text('اختر نوع المكان'),
            value: selectedType,
            isExpanded: true,
            items: placeTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, textDirection: TextDirection.rtl),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedType != null) {
                try {
                  setState(() {
                    profile['place_type'] = selectedType;
                  });

                  // Update persistent storage
                  final prefs = await SharedPreferences.getInstance();
                  final profilesJson =
                      placeProfiles.map((p) => jsonEncode(p)).toList();
                  await prefs.setStringList('place_profiles', profilesJson);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث نوع المكان بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في التحديث: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _editPlaceImage(Map<String, dynamic> profile) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        try {
          setState(() {
            profile['image_path'] = image.path;
          });

          // Update persistent storage
          final prefs = await SharedPreferences.getInstance();
          final profilesJson = placeProfiles.map((p) => jsonEncode(p)).toList();
          await prefs.setStringList('place_profiles', profilesJson);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الصورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في تحديث الصورة: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في اختيار الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(Map<String, dynamic> profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${profile['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deletePlaceProfile(profile);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
