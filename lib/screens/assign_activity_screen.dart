import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../providers/app_state.dart';

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
  final _detailController = TextEditingController(); // For relationship or category
  
  String _selectedType = 'person'; // 'person', 'place', 'object'
  String? _imagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  final Map<String, String> _typeLabels = {
    'person': 'تعرف على الأشخاص',
    'place': 'تعرف على الأماكن',
    'object': 'تعرف على الأشياء',
  };

  final Map<String, String> _detailLabels = {
    'person': 'صلة القرابة (مثلاً: ده بابا)',
    'place': 'نوع المكان (مثلاً: المنزل)',
    'object': 'فئة الشيء (مثلاً: فواكه)',
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
        const SnackBar(content: Text('الرجاء اختيار صورة'), backgroundColor: Colors.red),
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
      };

      if (_selectedType == 'person') {
        activityData['relation'] = _detailController.text;
      } else {
        activityData['place_type'] = _detailController.text;
      }
      
      activityData['image_path'] = imageUrl;

      await _firebaseService.assignActivityToChild(
        childId: widget.childId,
        type: _selectedType,
        activityData: activityData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة النشاط بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة نشاط لـ ${widget.childName}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر نوع التدريب',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: _typeLabels.entries.map((e) {
                  return ButtonSegment<String>(
                    value: e.key,
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _detailController.clear();
                  });
                },
              ),
              const SizedBox(height: 24),
              
              _buildTextField(
                controller: _nameController,
                label: 'الاسم (مثلاً: بابا، تفاحة، المنزل)',
                hint: 'أدخل الاسم',
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _detailController,
                label: _detailLabels[_selectedType]!,
                hint: 'أدخل التفاصيل',
              ),
              const SizedBox(height: 24),
              
              Text(
                'الصورة',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('اضغط لإضافة صورة'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ النشاط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
            return null;
          },
        ),
      ],
    );
  }
}
