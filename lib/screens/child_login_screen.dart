import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../widgets/custom_widgets.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../l10n/app_localizations.dart';

/// Child Login Screen
/// Login form for existing children with username/password
class ChildLoginScreen extends StatefulWidget {
  static const String routeName = '/child-login';
  const ChildLoginScreen({Key? key}) : super(key: key);

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();

    // Check if user is already logged in
    _checkLoginStatus();

    // Initialize Google Sign-In
    _googleSignIn.signInSilently();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }

  void _checkLoginStatus() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Check if Firebase user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get child data
        final childData = await _firebaseService.getChildData(user.uid);

        if (childData != null) {
          appState.setChildName(childData.name);
          appState.setUserRole('child');

          // Navigate to home if already logged in
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        print('Error checking login status: $e');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final appState = Provider.of<AppState>(context, listen: false);

        // Use Firebase authentication
        await _firebaseService.loginChild(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        // Get child data from Firebase
        final childData = await _firebaseService.getChildData(
          _firebaseService.currentUser!.uid,
        );

        if (childData != null) {
          appState.setChildName(childData.name);
          appState.setUserRole('child');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home dashboard
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          throw Exception('Child data not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // Check if child exists in Firestore
        final childData = await _firebaseService.getChildData(user.uid);

        final appState = Provider.of<AppState>(context, listen: false);

        if (childData != null) {
          // Child exists, set state and navigate
          appState.setChildName(childData.name);
          appState.setUserRole('child');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Child doesn't exist, set basic info and go home
          appState.setChildName(user.displayName ?? 'User');
          appState.setUserRole('child');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacementNamed('/home');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      setState(() {
        _isLoading = false;
      });

      print('Google Sign-In Error: $error');
      print('Stack Trace: $stackTrace');

      String errorMessage = error.toString();
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? error.code;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول بحساب جوجل: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
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
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // AI Logo Section
                    _buildAIBranding(),

                    const SizedBox(height: 10),

                    // Login Form
                    _buildModernLoginForm(),

                    const SizedBox(height: 5),

                    // Sign up link
                    _buildSignUpLink(),
                  ],
                ),
              ),
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
          'مرحباً بك في رفيق ',
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
          'مساعدك الذكي للتعلم والتطور',
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

  Widget _buildModernLoginForm() {
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
            // Username Field
            _buildModernTextField(
              controller: _usernameController,
              label: 'اسم المستخدم',
              hint: 'أدخل اسم المستخدم',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                if (value.length < 3) {
                  return 'الحد الأدنى 3 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildModernTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                if (value.length < 4) {
                  return 'الحد الأدنى 4 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Login Button
            _buildModernLoginButton(),

            const SizedBox(height: 16),
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

  Widget _buildModernLoginButton() {
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
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : const Text(
                    'تسجيل دخول',
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

  Widget _buildGoogleSignInButton() {
    return Container(
      width: 300,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF007aff),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _signInWithGoogle,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF007aff)),
                  ),
                  child: const Icon(
                    Icons.g_mobiledata,
                    color: Color(0xFF007aff), // Icon blue inside white circle
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تسجيل الدخول بحساب جوجل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ليس لديك حساب؟',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.setChildName('');
                Navigator.of(context).pushNamed('/child-profile');
              },
              child: const Text(
                'إنشاء حساب ذكي',
                style: TextStyle(
                  color: Color(0xFF007aff),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Google Sign-In Button
        _buildGoogleSignInButton(),
      ],
    );
  }
}
