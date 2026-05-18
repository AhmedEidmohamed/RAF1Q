import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_widgets.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كلمات المرور غير متطابقة'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await _firebaseService.registerDoctor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullNameController.text.trim(),
          specialization: _specializationController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        final doctorData = await _firebaseService.getDoctorData(userCredential.user!.uid);

        if (doctorData != null && mounted) {
          final doctorProfile = DoctorProfile(
            id: doctorData.id!,
            fullName: doctorData.name,
            username: _emailController.text,
            password: _passwordController.text,
            specialization: doctorData.specialization,
            email: doctorData.email,
            phone: doctorData.phoneNumber ?? '',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 600 : double.infinity,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // AI Logo Section
                    _buildBranding(),

                    const SizedBox(height: 10),

                    // Registration Form
                    _buildModernRegistrationForm(),

                    const SizedBox(height: 10),

                    // Login link
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

  Widget _buildBranding() {
    return Column(
      children: [
        // AI Brain Icon
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/ic_launcher.png'),
        ),
        const SizedBox(height: 15),

        // Title
        const Text(
          'إنشاء حساب طبيب',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'انضم إلى شبكة الأطباء المحترفين مع رفيق',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernRegistrationForm() {
    return Container(
      padding: const EdgeInsets.all(32),
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
            _buildModernTextField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك بالكامل',
              icon: Icons.person_outline,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'أدخل بريدك الإلكتروني',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _specializationController,
              label: 'التخصص',
              hint: 'تخصصك الطبي',
              icon: Icons.medication_outlined,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: 'رقم هاتفك',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: 'كلمة المرور',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد المرور',
              hint: 'أعد الكتابة',
              icon: Icons.lock_clock_outlined,
              obscureText: true,
              validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 32),

            // Register Button
            _buildModernRegisterButton(),
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
    Widget? suffixIcon,
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
            suffixIcon: suffixIcon,
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

  Widget _buildModernRegisterButton() {
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
          onTap: _isLoading ? null : _saveProfile,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'إنشاء حساب جديد',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/doctor-login'),
          child: const Text(
            'سجل دخولك',
            style: TextStyle(
              color: Color(0xFF007aff),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
