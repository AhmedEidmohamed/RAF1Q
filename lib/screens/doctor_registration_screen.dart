import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _centerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _centerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمات المرور غير متطابقة'), 
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final String phone = _phoneController.text.trim();
        final String email = '$phone@rafiq.com'; // Automatically map phone to email for Firebase Auth

        UserCredential userCredential = await _firebaseService.registerDoctor(
          email: email,
          password: _passwordController.text,
          name: _fullNameController.text.trim(),
          specialization: 'أخصائي', // Default or could use _centerController
          phoneNumber: phone,
        );

        final doctorData = await _firebaseService.getDoctorData(userCredential.user!.uid);

        if (doctorData != null && mounted) {
          final doctorProfile = DoctorProfile(
            id: doctorData.id!,
            fullName: doctorData.name,
            username: phone, // Username is the phone
            password: _passwordController.text,
            specialization: doctorData.specialization,
            email: doctorData.email,
            phone: doctorData.phoneNumber ?? phone,
            linkedChildrenIds: List<String>.from(doctorData.patients ?? []),
            photoUrl: doctorData.profileImageUrl,
            clinicName: _centerController.text.trim(), // Save the center/hospital
            clinicAddress: doctorData.clinicInfo?['address'],
            qualifications: doctorData.clinicInfo?['qualifications'],
            experience: doctorData.clinicInfo?['experience'],
            about: doctorData.clinicInfo?['about'],
            languages: List<String>.from(doctorData.clinicInfo?['languages'] ?? ['Arabic', 'English']),
            licenseNumber: doctorData.licenseNumber,
            workingHours: doctorData.clinicInfo?['workingHours'],
          );

          Provider.of<AppState>(context, listen: false).setCurrentDoctor(doctorProfile);
          
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

          Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Slate 50
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield Icon Header
                    _buildHeaderIcon(),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'إنشاء حساب أخصائي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A), // Dark blue
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                      'انضم إلى رفيق لمتابعة تقدم الأطفال وتقديم الدعم المتخصص',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B), // Slate 500
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Registration Form Card
                    _buildRegistrationCard(),

                    const SizedBox(height: 24),

                    // Login Link Footer
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF), // Very light blue
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.verified_user_outlined,
          color: Color(0xFF2563EB), // Rich blue
          size: 32,
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name Field
            _buildCustomField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              icon: Icons.person_outline_rounded,
              hintText: 'الأخصائي/ة...',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Phone Field
            _buildCustomField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              hintText: '0123456789',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if (value.trim().length < 10) {
                  return 'الرجاء إدخال رقم هاتف صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Center / Hospital Field
            _buildCustomField(
              controller: _centerController,
              label: 'المركز / المستشفى',
              icon: Icons.domain_outlined,
              hintText: 'اسم الجهة التي تعمل بها...',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم المركز أو المستشفى';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildCustomField(
              controller: _passwordController,
              label: 'كلمة المرور',
              icon: Icons.lock_outline_rounded,
              hintText: 'كلمة المرور (6 أحرف على الأقل)',
              obscureText: _obscurePassword,
              showToggle: true,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            _buildCustomField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              icon: Icons.lock_outline_rounded,
              hintText: 'أعد كتابة كلمة المرور',
              obscureText: _obscureConfirmPassword,
              showToggle: true,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Create Account Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool showToggle = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF1E3A8A), // Dark blue
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // Dark blue
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Input Field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14.5, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5), // Slate 400
            filled: true,
            fillColor: const Color(0xFFF1F5F9), // Slate 100
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // Solid blue
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13.5,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/doctor-login'),
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
