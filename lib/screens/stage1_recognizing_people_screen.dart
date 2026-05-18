import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:universal_html/html.dart' as html show Blob, Url, AudioElement;
import '../widgets/emotion_tracker_wrapper.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/global_chat_fab.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/session_tracker.dart';

/// Stage 1A: Recognizing People Screen
/// Grid of people cards with photos, names, and relationships
/// Tap to trigger Text-to-Speech
class RecognizingPeopleScreen extends StatefulWidget {
  const RecognizingPeopleScreen({Key? key}) : super(key: key);

  @override
  State<RecognizingPeopleScreen> createState() =>
      _RecognizingPeopleScreenState();
}

class _RecognizingPeopleScreenState extends State<RecognizingPeopleScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedRelation;
  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> voiceProfiles = [];
  bool isLoading = false;
  bool showInputSection = false;
  final AudioPlayer _player = AudioPlayer();
  final just_audio.AudioPlayer _justAudioPlayer = just_audio.AudioPlayer();
  final FirebaseService _firebaseService = FirebaseService();
  late SessionTracker _sessionTracker;
  final List<Map<String, dynamic>> _assignedProfiles = [];

  // Animation state variables
  int? currentlyPlayingProfileId;
  bool isPlaying = false;

  final String apiKey = "sk_3aaa6d7ef1d79cae6aba84a6fcf0fa9f53ac64dd81fac576";
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  final List<String> relations = [
    'ده بابا',
    'دي ماما',
    'ده أخويا',
    'دي أختي',
    'ده جدي',
    'دي تيتا',
    'ده عمي',
    'ده خالي',
    'دي عمتي',
    'دي خالتي',
    'ده ابني',
    'دي بنتي',
    'ده جوزي',
    'دي مراتي',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _sessionTracker = SessionTracker(stageNumber: 1, activityName: 'Recognizing People');
    _sessionTracker.startSession();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadVoiceProfiles();
    _addDefaultPeople();
    _fetchAssignedActivities();
  }

  void _fetchAssignedActivities() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firebaseService.getAssignedActivities(user.uid, 'person').listen((snapshot) {
        final newProfiles = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'relation': data['relation'] ?? '',
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
          // Remove previously assigned profiles to avoid duplicates
          voiceProfiles.removeWhere((p) => p['is_assigned'] == true);
          // Add new ones
          voiceProfiles.addAll(newProfiles);
        });
      });
    }
  }

  void _addDefaultPeople() {
    // إضافة أشخاص افتراضيين بصور واقعية من النت
    final defaultPeople = [
      {
        'id': 1,
        'name': 'بابا',
        'relation': 'ده بابا',
        'image_path':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'name': 'ماما',
        'relation': 'دي ماما',
        'image_path':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'name': 'أخويا',
        'relation': 'ده أخويا',
        'image_path':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 4,
        'name': 'أختي',
        'relation': 'دي أختي',
        'image_path':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 5,
        'name': 'جدي',
        'relation': 'ده جدي',
        'image_path':
            'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 6,
        'name': 'تيتا',
        'relation': 'دي تيتا',
        'image_path':
            'https://images.unsplash.com/photo-1559629088-866bc29d8a24?w=800&q=80',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    if (voiceProfiles.isEmpty) {
      setState(() {
        voiceProfiles = defaultPeople;
      });
    }
  }

  bool _isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  // Play audio on web using HTML5 audio
  Future<void> _playAudioOnWeb(Uint8List audioBytes) async {
    try {
      final blob = html.Blob([audioBytes], 'audio/mpeg');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final audio = html.AudioElement();
      audio.src = url;
      audio.play();

      // Clean up the URL after audio finishes
      audio.onEnded.listen((_) => html.Url.revokeObjectUrl(url));
    } catch (e) {
      print('Error playing web audio: $e');
      // Fallback to regular audio player
      _player.play(
          UrlSource('data:audio/mpeg;base64,${base64Encode(audioBytes)}'));
    }
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    nameController.dispose();
    _player.dispose();
    _justAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadVoiceProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('voice_profiles') ?? [];

      setState(() {
        voiceProfiles = profilesJson.map((json) {
          return Map<String, dynamic>.from(jsonDecode(json));
        }).toList();

        // If no profiles exist, add some demo data for testing
        if (voiceProfiles.isEmpty) {
          voiceProfiles = [
            {
              'id': 1,
              'name': 'أحمد',
              'relation': 'أخي',
              'image_path': 'https://picsum.photos/seed/person1/400/400.jpg',
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'id': 2,
              'name': 'فاطمة',
              'relation': 'أختي',
              'image_path': 'https://picsum.photos/seed/person2/400/400.jpg',
              'created_at': DateTime.now().toIso8601String(),
            },
          ];
        }
      });
    } catch (e) {
      print('Error loading voice profiles: $e');
      setState(() {
        voiceProfiles = [];
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
          content: Text('الرجاء إدخال الاسم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار صلة القرابة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // بناء الجملة الكاملة
      String sentence = selectedRelation! + " " + nameController.text;

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

        // Check if running on web
        if (kIsWeb) {
          try {
            await _playAudioOnWeb(audioBytes);
          } catch (e) {
            print('Web audio failed: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل تشغيل الصوت على الويب: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Mobile/desktop audio playback
          try {
            await _player.setSourceBytes(audioBytes);
            await _player.resume();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تشغيل الصوت بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            print('Audio playback failed: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل تشغيل الصوت: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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

  Future<void> saveVoiceProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال الاسم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار صلة القرابة'),
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
      final newProfile = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': nameController.text,
        'relation': selectedRelation,
        'image_path': selectedImagePath,
        'created_at': DateTime.now().toIso8601String(),
      };

      voiceProfiles.insert(0, newProfile);

      // حفظ في التخزين الدائم
      final prefs = await SharedPreferences.getInstance();
      final profilesJson =
          voiceProfiles.map((profile) => jsonEncode(profile)).toList();
      await prefs.setStringList('voice_profiles', profilesJson);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الملف الصوتي بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // مسح الحقول وإغلاق جزء الإدخال
      setState(() {
        nameController.clear();
        selectedRelation = null;
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

      // بناء الجملة الكاملة للملف المحفوظ
      String sentence = "${profile['relation']} ${profile['name']}";

      print('Playing voice for: ${profile['name']}');
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
    print('Starting audio repetition for: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing repetition $i/3 for: $name');
        await _player.setSourceBytes(audioBytes);
        await _player.resume();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل صوت: $name ($i/3)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Wait for audio to finish before next repetition
        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        print('Error in repetition $i: $e');
        break;
      }
    }
    print('Finished audio repetition for: $name');
  }

  // Helper method for playing audio with repetition from file
  Future<void> _playAudioWithRepetitionFromFile(
      File audioFile, String name) async {
    print('Starting audio repetition from file for: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing repetition $i/3 for: $name');
        await _player.setSourceDeviceFile(audioFile.path);
        await _player.resume();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تشغيل صوت: $name ($i/3)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Wait for audio to finish before next repetition
        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        print('Error in repetition $i: $e');
        break;
      }
    }
    print('Finished audio repetition from file for: $name');
  }

  // Helper method for web audio with repetition
  Future<void> _playAudioOnWebWithRepetition(
      Uint8List audioBytes, String name) async {
    print('Starting web audio repetition for: $name');
    for (int i = 1; i <= 3; i++) {
      try {
        print('Playing web repetition $i/3 for: $name');
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
    print('Finished web audio repetition for: $name');
  }

  Future<void> deleteVoiceProfile(Map<String, dynamic> profile) async {
    try {
      setState(() {
        voiceProfiles.removeWhere((p) => p['id'] == profile['id']);
      });

      // Update persistent storage
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = voiceProfiles.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('voice_profiles', profilesJson);

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
                  'الاسم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'أدخل الاسم هنا',
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

            // اختيار صلة القرابة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'صلة القرابة',
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
                    hint: Text('اختر صلة القرابة'),
                    value: selectedRelation,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: relations.map((String relation) {
                      return DropdownMenuItem<String>(
                        value: relation,
                        child: Text(relation, textDirection: TextDirection.rtl),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRelation = newValue;
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
                    onPressed: isLoading ? null : saveVoiceProfile,
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
                      selectedRelation = null;
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isNetworkImage(selectedImagePath)
                        ? Image.network(
                            selectedImagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text('لا يمكن عرض الصورة',
                                        style: TextStyle(
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(selectedImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text('لا يمكن عرض الصورة',
                                        style: TextStyle(
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                              );
                            },
                          ),
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
      floatingActionButton: const GlobalChatFAB(),
      appBar: AppBar(
        title: Text(
          'التعرف على الأشخاص',
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
              if (voiceProfiles.length >= 3) {
                Navigator.pushNamed(context, '/test-people');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('يجب إضافة على الأقل 3 أشخاص لإجراء الاختبار'),
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
        activityTitle: 'التعرف على الأشخاص',
        child: Column(
          children: [
          // جزء الإدخال المتحرك
          showInputSection
              ? Expanded(flex: 2, child: _buildInputSection())
              : SizedBox.shrink(),

          // عرض الملفات المحفوظة
          Expanded(
            child: voiceProfiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
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
                          'اضغط على زر (+) لإضافة شخص جديد',
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
                      itemCount: voiceProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = voiceProfiles[index];
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
                                    // الصورة مع أيقونة التعديل
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade100,
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
                                                              Icons.person,
                                                              size: 80,
                                                              color: Colors.blue
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
                                                              Icons.person,
                                                              size: 80,
                                                              color: Colors.blue
                                                                  .shade700,
                                                            );
                                                          },
                                                        )
                                                  : Icon(
                                                      Icons.person,
                                                      size: 80,
                                                      color:
                                                          Colors.blue.shade700,
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
                                    // المعلومات مع الصوت
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            // صلة القرابة أولاً ثم الاسم مع أيقونة الصوت جنبهم
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${profile['relation']} ${profile['name']} ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
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
                                                  color: Colors.purple[700],
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
                                category: 'person',
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
                                                              .blue.shade100,
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 100,
                                                            color: Colors
                                                                .blue.shade700,
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
                                                              .blue.shade100,
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 100,
                                                            color: Colors
                                                                .blue.shade700,
                                                          ),
                                                        );
                                                      },
                                                    )
                                              : Container(
                                                  color: Colors.blue.shade100,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 100,
                                                    color: Colors.blue.shade700,
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
                                              profile['relation'],
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

  // دوال التعديل والحذف
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
              title: Text('تعديل الاسم'),
              onTap: () {
                Navigator.pop(context);
                _editPersonName(profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: Text('تعديل صلة القرابة'),
              onTap: () {
                Navigator.pop(context);
                _editPersonRelation(profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.purple),
              title: Text('تعديل الصورة'),
              onTap: () {
                Navigator.pop(context);
                _editPersonImage(profile);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('حذف الشخص'),
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

  void _editPersonName(Map<String, dynamic> profile) {
    final TextEditingController editController =
        TextEditingController(text: profile['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل اسم الشخص'),
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
                      voiceProfiles.map((p) => jsonEncode(p)).toList();
                  await prefs.setStringList('voice_profiles', profilesJson);

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

  void _editPersonRelation(Map<String, dynamic> profile) {
    String? selectedRelation = profile['relation'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل صلة القرابة'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            hint: Text('اختر صلة القرابة'),
            value: selectedRelation,
            isExpanded: true,
            items: relations.map((String relation) {
              return DropdownMenuItem<String>(
                value: relation,
                child: Text(relation, textDirection: TextDirection.rtl),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRelation = newValue;
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
              if (selectedRelation != null) {
                try {
                  setState(() {
                    profile['relation'] = selectedRelation;
                  });

                  // Update persistent storage
                  final prefs = await SharedPreferences.getInstance();
                  final profilesJson =
                      voiceProfiles.map((p) => jsonEncode(p)).toList();
                  await prefs.setStringList('voice_profiles', profilesJson);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث صلة القرابة بنجاح'),
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

  void _editPersonImage(Map<String, dynamic> profile) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        try {
          setState(() {
            profile['image_path'] = image.path;
          });

          // Update persistent storage
          final prefs = await SharedPreferences.getInstance();
          final profilesJson = voiceProfiles.map((p) => jsonEncode(p)).toList();
          await prefs.setStringList('voice_profiles', profilesJson);

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
              deleteVoiceProfile(profile);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
