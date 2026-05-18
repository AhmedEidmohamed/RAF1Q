import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../models/child_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';

/// Child Profile Creation Screen
/// Form to collect child information (Case Study - Short Version)
class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({Key? key}) : super(key: key);

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _governorateController = TextEditingController();
  final _schoolController = TextEditingController();
  final _iqLevelController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _doctorUsernameController = TextEditingController();

  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  // Doctors list
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;
  bool _isLoadingDoctors = false;

  DateTime? _selectedDate;
  String? _selectedGender;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _floatController.repeat(reverse: true);
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // First, try to get the current logged-in doctor from AppState
      if (appState.currentDoctor != null) {
        setState(() {
          _doctors = [
            {
              'id': appState.currentDoctor!.id,
              'name': appState.currentDoctor!.fullName,
              'specialization': appState.currentDoctor!.specialization,
            }
          ];
          _isLoadingDoctors = false;
        });
        print(
            'Using current doctor from AppState: ${appState.currentDoctor!.fullName}');
        return;
      }

      // If no current doctor, try fetching from Firestore
      final firestore = FirebaseFirestore.instance;

      print('Attempting to fetch doctors from Firestore...');
      print('Current user: ${FirebaseAuth.instance.currentUser?.uid}');

      final snapshot = await firestore.collection('doctors').get();

      print('Fetched ${snapshot.docs.length} doctors from Firestore');

      setState(() {
        _doctors = snapshot.docs.map((doc) {
          final data = doc.data();
          print('Doctor data: $data');
          // Try both 'name' and 'fullName' fields
          final doctorName = data['name'] ?? data['fullName'] ?? 'Unknown';
          final doctorSpecialization = data['specialization'] ?? '';
          print(
              'Doctor name: $doctorName, Specialization: $doctorSpecialization');
          return {
            'id': doc.id,
            'name': doctorName,
            'specialization': doctorSpecialization,
          };
        }).toList();
        _isLoadingDoctors = false;
      });

      print('Doctors list: $_doctors');

      if (_doctors.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('لا يوجد أطباء مسجلين في النظام'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'تسجيل طبيب',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed('/doctor-registration');
                },
              ),
            ),
          );
        }
      }
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.code} - ${e.message}');

      // If permission denied, try to use current doctor from AppState
      if (e.code == 'permission-denied') {
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
            _isLoadingDoctors = false;
          });
          return;
        }
      }

      setState(() {
        _isLoadingDoctors = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ Firebase (${e.code}): ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoadingDoctors = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل قائمة الأطباء: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Calculate age automatically
        final DateTime today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month ||
            (today.month == picked.month && today.day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.t('select_date',
                locale: Provider.of<AppState>(context).currentLanguage)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.t('select_gender',
                locale: Provider.of<AppState>(context).currentLanguage)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      try {
        UserCredential userCredential;
        String email = _usernameController.text;

        // Try login first - if user exists, this will work
        // If user doesn't exist, we'll get user-not-found error
        try {
          userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: _passwordController.text,
          );
          print('User logged in successfully');
        } catch (authError) {
          print('Auth error: $authError');
          String errorStr = authError.toString();

          // If user doesn't exist (user-not-found or invalid-credential), register new user
          if (errorStr.contains('user-not-found') ||
              errorStr.contains('invalid-credential')) {
            userCredential = await _firebaseService.registerChild(
              email: email,
              password: _passwordController.text,
              name: _fullNameController.text,
              age: _ageController.text,
              parentId: _selectedDoctorId ?? 'parent_default',
            );
            print('New user registered successfully');
          }
          // If email already in use, it means user exists - try login again with same password
          else if (errorStr.contains('email-already-in-use')) {
            // This is strange - email exists but login failed? Try again
            userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: _passwordController.text,
            );
            print('User logged in (retry after email-already-in-use)');
          } else {
            rethrow;
          }
        }

        // Create ChildModel with additional data
        final childModel = ChildModel(
          id: userCredential.user!.uid,
          name: _fullNameController.text,
          age: _ageController.text,
          parentId: _selectedDoctorId ?? 'parent_default',
          createdAt: DateTime.now(),
          assignedDoctorId: _selectedDoctorId,
          preferences: {
            'dateOfBirth': _selectedDate!.toIso8601String(),
            'gender': _selectedGender,
            'governorate': _governorateController.text,
            'school':
                _schoolController.text.isEmpty ? null : _schoolController.text,
            'iqLevel': _iqLevelController.text.isEmpty
                ? null
                : _iqLevelController.text,
            'healthStatus': _healthStatusController.text,
          },
          progress: {},
        );

        // Save child profile to Firestore (handles both new and existing users)
        try {
          await _firebaseService.saveChildProfile(childModel);
          print('Child profile saved to Firestore successfully');
        } catch (firestoreError) {
          print('Error saving to Firestore: $firestoreError');
          // Continue anyway - user is logged in
        }

        // Create ChildProfile object for compatibility
        final childProfile = ChildProfile(
          fullName: _fullNameController.text,
          age: int.parse(_ageController.text),
          dateOfBirth: _selectedDate!,
          gender: _selectedGender!,
          governorate: _governorateController.text,
          school:
              _schoolController.text.isEmpty ? null : _schoolController.text,
          iqLevel:
              _iqLevelController.text.isEmpty ? null : _iqLevelController.text,
          healthStatus: _healthStatusController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          doctorId: _doctorUsernameController.text.isEmpty
              ? null
              : _doctorUsernameController.text,
        );

        // Also save to SharedPreferences for compatibility
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('child_profile_${childProfile.username}',
            jsonEncode(childProfile.toMap()));

        // Set current child in AppState
        final appState = Provider.of<AppState>(context, listen: false);
        appState.setChildName(childProfile.username);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Profile saved successfully'),
                ],
              ),
              backgroundColor: Colors.purple,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Navigate to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: childProfile,
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error saving profile: $e',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _governorateController.dispose();
    _schoolController.dispose();
    _iqLevelController.dispose();
    _healthStatusController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _doctorUsernameController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // AI Logo Section
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value * 100),
                      child: _buildAIBranding(),
                    );
                  },
                ),

                // Registration Form
                _buildModernRegistrationForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIBranding() {
    return Column(
      children: [
        // AI Brain Icon
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/ic_launcher.png'),
        ),
        const SizedBox(height: 10),

        // Title
        const Text(
          'إنشاء ملف شخصي ذكي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'معلومات طفلك لتجربة تعليمية مخصصة',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withOpacity(0.6),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernRegistrationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Full Name
            _buildModernTextField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              hint: 'أدخل الاسم الكامل',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Username and Password Row
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: _usernameController,
                    label: 'اسم المستخدم',
                    hint: 'اسم المستخدم',
                    icon: Icons.alternate_email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date of Birth and Age Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: _buildModernTextField(
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'اختر تاريخ الميلاد',
                      ),
                      label: 'تاريخ الميلاد',
                      hint: 'يوم/شهر/سنة',
                      icon: Icons.calendar_today_rounded,
                      enabled: false,
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _ageController,
                    label: 'العمر',
                    hint: 'العمر',
                    icon: Icons.cake_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gender and Governorate Row
            Row(
              children: [
                Expanded(
                  child: _buildModernDropdownField(
                    label: 'الجنس',
                    hint: 'اختر الجنس',
                    icon: Icons.person_outline_rounded,
                    value: _selectedGender,
                    items: const ['ذكر', 'أنثى'],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _governorateController,
                    label: 'المحافظة',
                    hint: 'المحافظة',
                    icon: Icons.location_city_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // School and IQ Level Row
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: _schoolController,
                    label: 'المدرسة',
                    hint: 'اسم المدرسة',
                    icon: Icons.school_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernTextField(
                    controller: _iqLevelController,
                    label: 'مستوى الذكاء',
                    hint: 'مستوى الذكاء',
                    icon: Icons.psychology_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Status
            _buildModernTextField(
              controller: _healthStatusController,
              label: 'الحالة الصحية أو الشكوى',
              hint: 'أدخل الحالة الصحية أو الشكوى',
              icon: Icons.medical_services_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Doctor Name
            _isLoadingDoctors
                ? _buildModernTextField(
                    controller: TextEditingController(text: 'جاري التحميل...'),
                    label: 'اسم الطبيب',
                    hint: 'اسم الطبيب',
                    icon: Icons.local_hospital_rounded,
                    enabled: false,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorDropdownField(),
                      const SizedBox(height: 8),
                      if (_doctors.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showDoctorSelectionDialog(),
                          icon: const Icon(Icons.list, size: 16),
                          label: const Text(
                            'أو اضغط هنا للاختيار من قائمة',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Save Button
            _buildModernSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLines,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines ?? 1,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF007aff),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildModernDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF007aff),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDoctorDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اسم الطبيب',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDoctorId,
          decoration: InputDecoration(
            hintText: 'اختر الطبيب المعالج',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.local_hospital_rounded,
              color: const Color(0xFF007aff),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF007aff),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          isExpanded: true,
          items: _doctors.map((doctor) {
            return DropdownMenuItem<String>(
              value: doctor['id'],
              child: Text(
                '${doctor['name']} - ${doctor['specialization']}',
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDoctorId = value;
              if (value != null) {
                _doctorUsernameController.text =
                    _doctors.firstWhere((d) => d['id'] == value)['name'];
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'مطلوب';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showDoctorSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر الطبيب المعالج'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                final doctor = _doctors[index];
                return ListTile(
                  title: Text(doctor['name']),
                  subtitle: Text(doctor['specialization']),
                  onTap: () {
                    setState(() {
                      _selectedDoctorId = doctor['id'];
                      _doctorUsernameController.text = doctor['name'];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF007aff),
            Color(0xFF0088ff),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007aff).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveProfile,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'حفظ الملف الشخصي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
