import '../core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class SmartObjectsGallery extends StatefulWidget {
  @override
  State<SmartObjectsGallery> createState() => _SmartObjectsGalleryState();
}

class _SmartObjectsGalleryState extends State<SmartObjectsGallery> {
  final TextEditingController nameController = TextEditingController();
  String? selectedCategory;
  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> objectProfiles = [];
  bool isLoading = false;
  bool showInputSection = false;
  final AudioPlayer _player = AudioPlayer();

  final String apiKey = AppConfig.elevenLabsApiKey;
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  final List<String> categories = [
    'خضروات',
    'فواكه',
    'ألعاب',
    'أدوات منزلية',
    'حيوانات',
    'أخرى',
  ];

  final Map<String, List<String>> objectTypes = {
    'خضروات': ['طماطم', 'خيار', 'فلفل', 'بصل', 'بطاطس', 'جزر', 'باذنجان'],
    'فواكه': ['تفاحة', 'موز', 'برتقال', 'فراولة', 'عنب', 'مانجو', 'برتقال'],
    'ألعاب': ['كرة', 'دب دمية', 'مكعبات', 'سيارة', 'قطار', 'طائرة'],
    'أدوات منزلية': ['كوب', 'ملعقة', 'شوكة', 'طبق', 'سknife', 'مفتاح'],
    'حيوانات': ['قطة', 'كلب', 'طائر', 'سمكة', 'أرنب', 'حصان'],
    'أخرى': ['كتاب', 'قلم', 'كرسي', 'طاولة', 'باب', 'نافذة'],
  };

  @override
  void initState() {
    super.initState();
    _loadObjectProfiles();
  }

  @override
  void dispose() {
    nameController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadObjectProfiles() async {
    setState(() {
      objectProfiles = [];
    });
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
          content: Text('الرجاء إدخال اسم الشيء'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار الفئة'),
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
      String sentence = "هذا ${nameController.text}";

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

  Future<void> saveObjectProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال اسم الشيء'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار الفئة'),
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
        'category': selectedCategory,
        'image_path': selectedImagePath,
        'created_at': DateTime.now().toIso8601String(),
      };

      objectProfiles.insert(0, newProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الملف الصوتي بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // مسح الحقول وإغلاق جزء الإدخال
      setState(() {
        nameController.clear();
        selectedCategory = null;
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
      // بناء الجملة الكاملة للملف المحفوظ
      String sentence = "هذا ${profile['name']}";

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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تشغيل الصوت'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
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
                  'اسم الشيء',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم الشيء هنا',
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

            // اختيار الفئة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الفئة',
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
                    hint: Text('اختر الفئة'),
                    value: selectedCategory,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, textDirection: TextDirection.rtl),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
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
                    onPressed: isLoading ? null : saveObjectProfile,
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
                      selectedCategory = null;
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
        title: Text('معرض الأشياء والصوت'),
        backgroundColor: Colors.green[700],
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
            child: objectProfiles.isEmpty
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
                          'لا توجد ملفات محفوظة',
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
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: objectProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = objectProfiles[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () => playVoiceForProfile(profile),
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      size: 60,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          profile['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          profile['category'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.volume_up,
                                          color: Colors.green[700],
                                          size: 20,
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
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
