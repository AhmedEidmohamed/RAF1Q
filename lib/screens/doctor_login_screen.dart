import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({Key? key}) : super(key: key);

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final String phone = _phoneController.text.trim();
        String loginEmail = phone;
        // Automatically map phone to email if it doesn't contain '@'
        if (!loginEmail.contains('@')) {
          loginEmail = '$phone@rafiq.com';
        }

        await _firebaseService.loginDoctor(
          email: loginEmail,
          password: _passwordController.text,
        );

        final doctorData = await _firebaseService.getDoctorData(
          _firebaseService.currentUser!.uid,
        );

        if (doctorData != null && mounted) {
          final doctorProfile = DoctorProfile(
            id: doctorData.id!,
            fullName: doctorData.name,
            username: phone,
            password: _passwordController.text,
            specialization: doctorData.specialization,
            email: doctorData.email,
            phone: doctorData.phoneNumber ?? phone,
            linkedChildrenIds: List<String>.from(doctorData.patients ?? []),
            photoUrl: doctorData.profileImageUrl,
            clinicName: doctorData.clinicInfo?['clinicName'],
            clinicAddress: doctorData.clinicInfo?['address'],
            qualifications: doctorData.clinicInfo?['qualifications'],
            experience: doctorData.clinicInfo?['experience'],
            about: doctorData.clinicInfo?['about'],
            languages: List<String>.from(doctorData.clinicInfo?['languages'] ?? ['Arabic', 'English']),
            licenseNumber: doctorData.licenseNumber,
            workingHours: doctorData.clinicInfo?['workingHours'],
          );

          Provider.of<AppState>(context, listen: false).setCurrentDoctor(doctorProfile);
          Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
        } else {
          throw Exception('بيانات الطبيب غير موجودة');
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
                      'دخول الأخصائيين',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A), // Dark blue
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                      'مرحباً بك في بوابة الأخصائي المعتمد',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B), // Slate 500
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Login Form Card
                    _buildLoginCard(),

                    const SizedBox(height: 24),

                    // Back to parents login
                    _buildBackToParentsLink(),
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

  Widget _buildLoginCard() {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone Field
            _buildCustomField(
              controller: _phoneController,
              label: 'رقم الهاتف المسجل',
              icon: Icons.phone_outlined,
              hintText: '01xxxxxxxxx',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
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
              hintText: '........',
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
                return null;
              },
            ),
            
            const SizedBox(height: 12),
            
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'نسيت كلمة المرور؟',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A), // Dark blue
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Login Button
            _buildSubmitButton(),
            
            const SizedBox(height: 24),
            
            // Divider
            const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
            
            const SizedBox(height: 16),
            
            // Create Account Section
            const Center(
              child: Text(
                'ليس لديك حساب أخصائي؟',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCreateAccountButton(),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B), // Dark slate
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
            prefixIcon: Icon(
              icon,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
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
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A), // Dark blue
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'دخول لوحة التحكم',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.login_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/doctor-registration'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
          foregroundColor: const Color(0xFF1E3A8A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'إنشاء حساب أخصائي جديد',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToParentsLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/child-login');
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'العودة لتسجيل دخول أولياء الأمور',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_back_rounded, // Points left in RTL
            color: Color(0xFF64748B),
            size: 16,
          ),
        ],
      ),
    );
  }
}
