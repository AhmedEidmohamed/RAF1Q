import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class AssignActivityScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const AssignActivityScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<AssignActivityScreen> createState() => _AssignActivityScreenState();
}

class _AssignActivityScreenState extends State<AssignActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController(); 
  
  String _selectedType = 'person';
  String? _imagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  // The 7 Learning Categories
  final Map<String, Map<String, dynamic>> _categories = {
    'person': {
      'label': 'التعرف على الأشخاص',
      'icon': Icons.person_rounded,
      'nameLabel': 'الاسم',
      'nameHint': 'مثلاً: بابا، أحمد',
      'detailLabel': 'صلة القرابة',
      'detailHint': 'مثلاً: أب، صديق',
    },
    'place': {
      'label': 'التعرف على الأماكن',
      'icon': Icons.place_rounded,
      'nameLabel': 'اسم المكان',
      'nameHint': 'مثلاً: المنزل، الحديقة',
      'detailLabel': 'نوع المكان',
      'detailHint': 'مثلاً: مكان عام، غرفة',
    },
    'object': {
      'label': 'التعرف على الأشياء',
      'icon': Icons.category_rounded,
      'nameLabel': 'اسم الشيء',
      'nameHint': 'مثلاً: تفاحة، سيارة',
      'detailLabel': 'فئة الشيء',
      'detailHint': 'مثلاً: فواكه، ألعاب',
    },
    'social_gesture': {
      'label': 'الإيماءات الاجتماعية',
      'icon': Icons.waving_hand_rounded,
      'nameLabel': 'اسم الإيماءة',
      'nameHint': 'مثلاً: التلويح للوداع',
      'detailLabel': 'وصف الإيماءة ومناسبتها',
      'detailHint': 'كيف ومتى تستخدم؟',
    },
    'cooperative_play': {
      'label': 'اللعب التعاوني',
      'icon': Icons.extension_rounded,
      'nameLabel': 'اسم اللعبة',
      'nameHint': 'مثلاً: تبادل الأدوار',
      'detailLabel': 'قواعد اللعبة',
      'detailHint': 'اشرح كيفية اللعب مع الآخرين',
    },
    'conversation': {
      'label': 'بدء المحادثة',
      'icon': Icons.record_voice_over_rounded,
      'nameLabel': 'موضوع المحادثة',
      'nameHint': 'مثلاً: إلقاء التحية',
      'detailLabel': 'نص الجملة المقترحة',
      'detailHint': 'العبارة التي يجب أن يقولها الطفل',
    },
    'interaction': {
      'label': 'المبادرة بالتفاعل',
      'icon': Icons.connect_without_contact_rounded,
      'nameLabel': 'الموقف الاجتماعي',
      'nameHint': 'مثلاً: طلب المساعدة',
      'detailLabel': 'طريقة التفاعل',
      'detailHint': 'ماذا يجب أن يفعل الطفل في هذا الموقف؟',
    },
  };

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للنشاط'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a unique path for the activity image
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String storagePath = 'activities/${widget.childId}/${_selectedType}_$timestamp.jpg';
      
      // Upload the image and get the network URL
      String imageUrl = await _firebaseService.uploadImage(storagePath, File(_imagePath!));
      
      Map<String, dynamic> activityData = {
        'name': _nameController.text,
        'created_at': DateTime.now().toIso8601String(),
        'assignedAt': FieldValue.serverTimestamp(), // For ordering
        'image_path': imageUrl,
      };

      // Add specific fields based on type
      if (_selectedType == 'person') {
        activityData['relation'] = _detailController.text;
      } else if (_selectedType == 'place') {
        activityData['place_type'] = _detailController.text;
      } else if (_selectedType == 'object') {
        activityData['category'] = _detailController.text;
      } else {
        // For new stages (Gestures, Play, Conversation, Interaction)
        activityData['description'] = _detailController.text;
      }

      await _firebaseService.assignActivityToChild(
        childId: widget.childId,
        type: _selectedType,
        activityData: activityData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إسناد النشاط بنجاح للطفل!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ النشاط: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCat = _categories[_selectedType]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('إضافة نشاط لـ ${widget.childName}'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '1. حدد القسم التدريبي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              
              // Categories Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: _categories.entries.map((entry) {
                  final isSelected = _selectedType == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value['label']),
                    avatar: Icon(
                      entry.value['icon'],
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF4F46E5),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = entry.key;
                          // Optional: Clear fields when switching types to avoid confusion
                          // _nameController.clear();
                          // _detailController.clear();
                        });
                      }
                    },
                    selectedColor: const Color(0xFF4F46E5),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                '2. تفاصيل النشاط',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: currentCat['nameLabel'],
                      hint: currentCat['nameHint'],
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      controller: _detailController,
                      label: currentCat['detailLabel'],
                      hint: currentCat['detailHint'],
                      icon: Icons.description_rounded,
                      maxLines: _selectedType == 'person' || _selectedType == 'place' || _selectedType == 'object' ? 1 : 3,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                '3. صورة معبرة للنشاط',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imagePath == null ? Colors.grey[300]! : const Color(0xFF4F46E5),
                      width: _imagePath == null ? 1 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(_imagePath!), fit: BoxFit.cover),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_rounded, size: 40, color: Color(0xFF4F46E5)),
                            ),
                            const SizedBox(height: 12),
                            const Text('اضغط لاختيار صورة من المعرض', 
                                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('حفظ وإسناد للطفل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
            return null;
          },
        ),
      ],
    );
  }
}
