import '../core/config/app_config.dart';
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

// Import for web support
import 'dart:html' as html show Blob, Url, AudioElement;
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';

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

  // Animation state variables
  int? currentlyPlayingProfileId;
  bool isPlaying = false;

  final String apiKey = AppConfig.elevenLabsApiKey;
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  final List<String> relations = [
    'هذا كتاب',
    'هذه قلم',
    'هذا حقيبة',
    'هذه سيارة',
    'هذا هاتف',
    'هذا كمبيوتر',
    'هذه كرسي',
    'هذا طاولة',
    'هذا باب',
    'هذه نافذة',
    'هذا تفاح',
    'هذه موزة',
    'هذا ماء',
    'هذه حليب',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _loadVoiceProfiles();
  }

  // Web-specific audio playback
  Future<void> _playAudioOnWeb(Uint8List audioBytes) async {
    try {
      // Create a blob from the audio bytes
      final blob = html.Blob([audioBytes], 'audio/mpeg');

      // Create a URL for the blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create audio element and play
      final audio = html.AudioElement(url);
      audio.play();

      // Clean up the URL after playing
      audio.onEnded.listen((_) {
        html.Url.revokeObjectUrl(url);
        // Stop animation when audio ends
        setState(() {
          currentlyPlayingProfileId = null;
          isPlaying = false;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تشغيل الصوت بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Web audio playback failed: $e');
      throw e;
    }
  }

  @override
  void dispose() {
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
              'name': 'كتاب',
              'relation': 'هذا كتاب',
              'image_path': 'https://picsum.photos/seed/book1/400/400.jpg',
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'id': 2,
              'name': 'قلم',
              'relation': 'هذه قلم',
              'image_path': 'https://picsum.photos/seed/pen1/400/400.jpg',
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
          content: Text('الرجاء اختيار نوع الشيء'),
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
          content: Text('الرجاء اختيار نوع الشيء'),
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
                await _playAudioOnWeb(audioBytes);
              } catch (e) {
                print('Web audio failed: $e');
                throw e;
              }
            } else {
              // Method 1: audioplayers (for mobile/desktop)
              try {
                await _player.setSourceBytes(audioBytes);
                await _player.resume();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تشغيل صوت: ${profile['name']}'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              } catch (e) {
                print('audioplayers failed: $e');

                // Method 2: Save to temp file and play (fallback)
                try {
                  final tempDir = Directory.systemTemp;
                  final tempFile = File(
                      '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
                  await tempFile.writeAsBytes(audioBytes);

                  await _player.setSourceDeviceFile(tempFile.path);
                  await _player.resume();

                  // Clean up temp file after playing
                  Future.delayed(Duration(seconds: 10), () {
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تشغيل صوت: ${profile['name']}'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
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
    } catch (e) {
      print('Error in playVoiceForProfile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // Stop animation when done or if error occurs
      setState(() {
        currentlyPlayingProfileId = null;
        isPlaying = false;
      });
    }
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

            // اختيار نوع الشيء
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نوع الشيء',
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
                    hint: Text('اختر نوع الشيء'),
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
                    child: kIsWeb
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
      appBar: AppBar(
        title: Text('معرض الأشياء والأصوات'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                showInputSection = !showInputSection;
              });
            },
          ),
        ],
      ),
      body: Column(
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
                          Icons.category,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'لا توجد أشياء محفوظة',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'اضغط على زر (+) لإضافة شيء جديد',
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
                                                  ? kIsWeb
                                                      ? Image.network(
                                                          profile['image_path'],
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Icon(
                                                              Icons.person,
                                                              size: 80,
                                                              color: Colors
                                                                  .purple
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
                                                              color: Colors
                                                                  .purple
                                                                  .shade700,
                                                            );
                                                          },
                                                        )
                                                  : Icon(
                                                      Icons.person,
                                                      size: 80,
                                                      color: Colors
                                                          .purple.shade700,
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
                                                Text(
                                                  '${profile['relation']} ${profile['name']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                            return Scaffold(
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
                                            ? kIsWeb
                                                ? Image.network(
                                                    profile['image_path'],
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: Colors
                                                            .purple.shade100,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 100,
                                                          color: Colors
                                                              .purple.shade700,
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
                                                            .purple.shade100,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 100,
                                                          color: Colors
                                                              .purple.shade700,
                                                        ),
                                                      );
                                                    },
                                                  )
                                            : Container(
                                                color: Colors.purple.shade100,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 100,
                                                  color: Colors.purple.shade700,
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
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
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
              title: Text('تعديل نوع الشيء'),
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
              title: Text('حذف الشيء'),
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
        title: Text('تعديل اسم الشيء'),
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
        title: Text('تعديل نوع الشيء'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            hint: Text('اختر نوع الشيء'),
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
                      content: Text('تم تحديث النوع بنجاح'),
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
