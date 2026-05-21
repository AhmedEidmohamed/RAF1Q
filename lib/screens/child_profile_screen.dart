import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../models/child_model.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';

/// Child Profile Creation Screen
/// Form to collect child information (Case Study - 4 Steps Redesign)
class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({Key? key}) : super(key: key);

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form keys for separate step validations
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Text Controllers
  final _fullNameController = TextEditingController(); // Child Name
  final _ageController = TextEditingController(); // Child Age
  final _governorateController = TextEditingController(); // Governorate
  final _schoolController = TextEditingController(); // School/Center
  final _iqLevelController = TextEditingController(); // IQ Level (Optional)
  
  // Doctor Context (Step 3)
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();

  // Parent Info (Step 4)
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  // Doctors list
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _governorateController.dispose();
    _schoolController.dispose();
    _iqLevelController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      if (appState.currentDoctor != null) {
        setState(() {
          _doctors = [
            {
              'id': appState.currentDoctor!.id,
              'name': appState.currentDoctor!.fullName,
              'specialization': appState.currentDoctor!.specialization,
            }
          ];
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('doctors').get();

      setState(() {
        _doctors = snapshot.docs.map((doc) {
          final data = doc.data();
          final doctorName = data['name'] ?? data['fullName'] ?? 'Unknown';
          final doctorSpecialization = data['specialization'] ?? '';
          return {
            'id': doc.id,
            'name': doctorName,
            'specialization': doctorSpecialization,
            'phone': data['phone'] ?? data['phoneNumber'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D4ED8),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateAge(picked);
      });
    }
  }

  void _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    _ageController.text = age.toString();
  }

  // Find and link a doctor ID in the database based on the doctor name entered
  String? _findDoctorIdByNameOrPhone(String name, String phone) {
    if (name.isEmpty) return null;
    for (var doctor in _doctors) {
      final docName = doctor['name'].toString().toLowerCase();
      final inputName = name.toLowerCase();
      if (docName.contains(inputName) || inputName.contains(docName)) {
        return doctor['id'];
      }
      if (phone.isNotEmpty && doctor['phone'] == phone) {
        return doctor['id'];
      }
    }
    return null;
  }

  void _saveProfile() async {
    // Validate Step 4
    if (!_step4FormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String parentPhone = _parentPhoneController.text.trim();
      final String email = '$parentPhone@rafiq.com'; // Derived Email for authentication
      final String password = _passwordController.text;

      UserCredential userCredential;

      // Register or Login via Firebase Auth
      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Existing child logged in successfully');
      } catch (authError) {
        String errorStr = authError.toString();
        if (errorStr.contains('user-not-found') ||
            errorStr.contains('invalid-credential')) {
          // Register new child auth
          userCredential = await _firebaseService.registerChild(
            email: email,
            password: password,
            name: _fullNameController.text,
            age: _ageController.text,
            parentId: parentPhone,
          );
          print('New child registered successfully in Auth');
        } else {
          rethrow;
        }
      }

      // Link doctor if found in our system
      final linkedDocId = _selectedDoctorId ?? 
          _findDoctorIdByNameOrPhone(_doctorNameController.text, _doctorPhoneController.text);

      // Create ChildModel for Firestore
      final childModel = ChildModel(
        id: userCredential.user!.uid,
        name: _fullNameController.text,
        age: _ageController.text,
        parentId: parentPhone,
        createdAt: DateTime.now(),
        assignedDoctorId: linkedDocId,
        preferences: {
          'dateOfBirth': _selectedDate!.toIso8601String(),
          'gender': _selectedGender,
          'governorate': _governorateController.text,
          'school': _schoolController.text,
          'iqLevel': _iqLevelController.text.isEmpty ? null : _iqLevelController.text,
          'doctorName': _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
          'doctorPhone': _doctorPhoneController.text.isEmpty ? null : _doctorPhoneController.text,
          'parentName': _parentNameController.text,
          'parentPhone': parentPhone,
        },
        progress: {},
      );

      // Save Child to Firestore
      await _firebaseService.saveChildProfile(childModel);

      // Create ChildProfile for compatibility
      final childProfile = ChildProfile(
        id: userCredential.user!.uid,
        fullName: _fullNameController.text,
        age: int.tryParse(_ageController.text) ?? 6,
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
        governorate: _governorateController.text,
        school: _schoolController.text.isEmpty ? null : _schoolController.text,
        iqLevel: _iqLevelController.text.isEmpty ? null : _iqLevelController.text,
        healthStatus: 'لا توجد', // default compatible field
        username: parentPhone, // Phone is the username
        password: password,
        doctorId: linkedDocId,
        parentName: _parentNameController.text,
        parentPhone: parentPhone,
      );

      // Save to SharedPreferences for compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_profile_$parentPhone', jsonEncode(childProfile.toMap()));

      // Set AppState
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setChildName(_fullNameController.text);
      appState.setUserRole('child');

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم إنشاء الحساب بنجاح!'),
              ],
            ),
            backgroundColor: Color(0xFF2563EB),
          ),
        );

        // Navigate to home
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء حفظ الحساب: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _nextStep() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState!.validate()) {
        if (_selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى تحديد تاريخ الميلاد')),
          );
          return;
        }
        if (_selectedGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى تحديد الجنس')),
          );
          return;
        }
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_step2FormKey.currentState!.validate()) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_step3FormKey.currentState!.validate()) {
        setState(() => _currentStep = 3);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Beautiful slate white
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Top Headers
              _buildTopHeader(),
              
              const SizedBox(height: 24),
              
              // Stepper Row
              _buildCustomStepper(),
              
              const SizedBox(height: 16),
              
              // Expanded Multi-step Form Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _buildStepCardContent(),
                      const SizedBox(height: 30),
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

  // --- UI Build Helpers ---

  Widget _buildTopHeader() {
    return Column(
      children: [
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A), // Dark Royal Blue
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'رحلتك التعليمية مع طفلك تبدأ من هنا',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B), // Neutral slate grey
          ),
        ),
      ],
    );
  }

  Widget _buildCustomStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Connecting Line
          Positioned(
            left: 20,
            right: 20,
            top: 20,
            child: Row(
              children: List.generate(3, (index) {
                bool isCompleted = _currentStep > index;
                return Expanded(
                  child: Container(
                    height: 2.5,
                    color: isCompleted ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                );
              }),
            ),
          ),
          
          // Step Nodes Row (RTL: Step 1 on right, Step 4 on left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepNode(0, 'بيانات الطفل', Icons.person_rounded),
              _buildStepNode(1, 'السياق التعليمي', Icons.school_rounded),
              _buildStepNode(2, 'المتابعة الطبية', Icons.local_hospital_rounded),
              _buildStepNode(3, 'حساب ولي الأمر', Icons.verified_user_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepIndex, String title, IconData icon) {
    bool isActive = _currentStep == stepIndex;
    bool isCompleted = _currentStep > stepIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded Circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF2563EB) // Completed step color
                : (isActive ? const Color(0xFF2563EB) : Colors.white), // Active/Inactive
            border: Border.all(
              color: isCompleted || isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              width: 2.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 20, color: Colors.white)
                : Icon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // Label Text
        Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCardContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Card Header (Illustration Banner)
          _buildCardHeaderBanner(),
          
          // Form fields
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildFormFieldsForStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeaderBanner() {
    String title = '';
    String subtitle = '';
    IconData icon = Icons.person;

    switch (_currentStep) {
      case 0:
        title = 'هوية الطفل';
        subtitle = 'أخبرنا قليلاً عن بطلك الصغير';
        icon = Icons.person_outline_rounded;
        break;
      case 1:
        title = 'السياق التعليمي';
        subtitle = 'هذه المعلومات تساعدنا في تخصيص التدريب';
        icon = Icons.school_outlined;
        break;
      case 2:
        title = 'المتابعة الطبية';
        subtitle = 'ربط ملف الطفل بالأخصائي المتابع (اختياري)';
        icon = Icons.health_and_safety_outlined;
        break;
      case 3:
        title = 'حساب ولي الأمر';
        subtitle = 'تأمين حسابك للوصول للتقارير والتدريب';
        icon = Icons.security_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FF), // Beautiful light blue
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Circular White Icon
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldsForStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Fields();
      case 1:
        return _buildStep2Fields();
      case 2:
        return _buildStep3Fields();
      case 3:
        return _buildStep4Fields();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: هوية الطفل (Child's Identity) ---
  Widget _buildStep1Fields() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم الطفل
          _buildFieldLabel('اسم الطفل'),
          _buildCustomTextFormField(
            controller: _fullNameController,
            hintText: 'أدخل اسم الطفل بالكامل',
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم الطفل بالكامل';
              }
              if (value.trim().length < 3) {
                return 'يجب أن يكون الاسم 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // تاريخ الميلاد
          _buildFieldLabel('تاريخ الميلاد'),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: _buildCustomTextFormField(
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                      : '',
                ),
                hintText: 'mm/dd/yyyy',
                prefixIcon: Icons.calendar_today_outlined,
                suffixIcon: Icons.calendar_month_outlined,
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'الرجاء اختيار تاريخ الميلاد';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // الجنس
          _buildFieldLabel('الجنس'),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton('ذكر', _selectedGender == 'ذكر'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderButton('أنثى', _selectedGender == 'أنثى'),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Next Button
          _buildNextButton(),
          
          const SizedBox(height: 16),
          _buildLoginFooterLink(),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 2: السياق التعليمي (Educational Context) ---
  Widget _buildStep2Fields() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المحافظة
          _buildFieldLabel('المحافظة'),
          _buildCustomTextFormField(
            controller: _governorateController,
            hintText: 'أدخل اسم المحافظة',
            prefixIcon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم المحافظة';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // اسم المدرسة / المركز
          _buildFieldLabel('اسم المدرسة / المركز'),
          _buildCustomTextFormField(
            controller: _schoolController,
            hintText: 'أدخل اسم المؤسسة التعليمية',
            prefixIcon: Icons.domain_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم المدرسة أو المركز';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // درجة الذكاء
          _buildFieldLabel('درجة الذكاء (اختياري)'),
          _buildCustomTextFormField(
            controller: _iqLevelController,
            hintText: 'أدخل درجة اختبار الذكاء إن وجد',
            prefixIcon: Icons.psychology_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 36),

          // Navigation buttons
          Row(
            children: [
              Expanded(child: _buildPreviousButton()),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildLoginFooterLink(),
        ],
      ),
    );
  }

  // --- Step 3: المتابعة الطبية (Medical Follow-up) ---
  Widget _buildStep3Fields() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم الأخصائي / الطبيب
          _buildFieldLabel('اسم الأخصائي / الطبيب'),
          _buildCustomTextFormField(
            controller: _doctorNameController,
            hintText: 'أدخل اسم الطبيب المعالج',
            prefixIcon: Icons.healing_outlined,
          ),
          const SizedBox(height: 20),

          // رقم هاتف الأخصائي
          _buildFieldLabel('رقم هاتف الأخصائي'),
          _buildCustomTextFormField(
            controller: _doctorPhoneController,
            hintText: '01xxxxxxxxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Warning Note Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Elegant amber background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706), // Amber dark
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ملاحظة: ربط ملف الطفل بالأخصائي يتيح له متابعة تقدم طفلك وتقديم تقارير دورية دقيقة عن حالته.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFFB45309), // Amber Text
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Navigation buttons
          Row(
            children: [
              Expanded(child: _buildPreviousButton()),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildLoginFooterLink(),
        ],
      ),
    );
  }

  // --- Step 4: حساب ولي الأمر (Parent's Account) ---
  Widget _buildStep4Fields() {
    return Form(
      key: _step4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم ولي الأمر
          _buildFieldLabel('اسم ولي الأمر'),
          _buildCustomTextFormField(
            controller: _parentNameController,
            hintText: 'أدخل اسمك بالكامل',
            prefixIcon: Icons.person_pin_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم ولي الأمر بالكامل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // رقم الهاتف
          _buildFieldLabel('رقم الهاتف'),
          _buildCustomTextFormField(
            controller: _parentPhoneController,
            hintText: '01xxxxxxxxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال رقم الهاتف';
              }
              if (value.trim().length != 11 || !value.trim().startsWith('01')) {
                return 'يرجى إدخال رقم هاتف مصري صحيح (11 رقم يبدأ بـ 01)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // كلمة المرور
          _buildFieldLabel('كلمة المرور'),
          _buildCustomTextFormField(
            controller: _passwordController,
            hintText: 'كلمة المرور (6 أحرف على الأقل)',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixIconPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // تأكيد كلمة المرور
          _buildFieldLabel('تأكيد كلمة المرور'),
          _buildCustomTextFormField(
            controller: _confirmPasswordController,
            hintText: 'أعد كتابة كلمة المرور',
            prefixIcon: Icons.lock_clock_outlined,
            obscureText: _obscureConfirmPassword,
            suffixIcon: _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            onSuffixIconPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء تأكيد كلمة المرور';
              }
              if (value != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),

          const SizedBox(height: 36),

          // Navigation buttons (Previous & Create Account)
          Row(
            children: [
              Expanded(child: _buildPreviousButton()),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildSubmitButton(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildLoginFooterLink(),
        ],
      ),
    );
  }

  // --- Reusable Widget Builders ---

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B), // slate-800
        ),
      ),
    );
  }

  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14.5, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 20),
                onPressed: onSuffixIconPressed,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
      ),
      validator: validator,
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // Rich active blue
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'التالي',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18), // Directed standard right/forward
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _previousStep,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          foregroundColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'السابق',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'تأكيد وإنشاء الحساب',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginFooterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'لديك حساب بالفعل؟',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'سجل دخولك هنا',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
