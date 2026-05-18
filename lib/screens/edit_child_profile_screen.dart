import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/models.dart';
import '../models/child_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../widgets/global_chat_fab.dart';

/// Edit Child Profile Screen
/// Allows editing existing child profile data
class EditChildProfileScreen extends StatefulWidget {
  final ChildProfile childProfile;

  const EditChildProfileScreen({
    Key? key,
    required this.childProfile,
  }) : super(key: key);

  @override
  State<EditChildProfileScreen> createState() => _EditChildProfileScreenState();
}

class _EditChildProfileScreenState extends State<EditChildProfileScreen> {
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

  DateTime? _selectedDate;
  bool _isLoading = false;

  // Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _fullNameController.text = widget.childProfile.fullName;
    _ageController.text = widget.childProfile.age.toString();
    _governorateController.text = widget.childProfile.governorate;
    _schoolController.text = widget.childProfile.school ?? '';
    _iqLevelController.text = widget.childProfile.iqLevel ?? '';
    _healthStatusController.text = widget.childProfile.healthStatus;
    _usernameController.text = widget.childProfile.username;
    _passwordController.text = widget.childProfile.password;
    _doctorUsernameController.text = widget.childProfile.doctorId ?? '';
    _selectedDate = widget.childProfile.dateOfBirth;
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
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current child data from Firebase
      final childData =
          await _firebaseService.getChildData(widget.childProfile.username);

      if (childData != null) {
        // Update ChildModel with new data
        final updatedChildModel = childData.copyWith(
          name: _fullNameController.text.trim(),
          age: _ageController.text,
          parentId: _doctorUsernameController.text.trim().isEmpty
              ? childData.parentId
              : _doctorUsernameController.text.trim(),
          preferences: {
            'dateOfBirth': (_selectedDate ?? DateTime.now()).toIso8601String(),
            'gender': widget.childProfile.gender,
            'governorate': _governorateController.text.trim(),
            'school': _schoolController.text.trim().isEmpty
                ? null
                : _schoolController.text.trim(),
            'iqLevel': _iqLevelController.text.trim().isEmpty
                ? null
                : _iqLevelController.text.trim(),
            'healthStatus': _healthStatusController.text.trim(),
          },
        );

        // Update in Firebase
        await _firebaseService.updateChildProfile(updatedChildModel);
      }

      // Create updated ChildProfile for compatibility
      final updatedProfile = ChildProfile(
        fullName: _fullNameController.text.trim(),
        age: int.parse(_ageController.text),
        governorate: _governorateController.text.trim(),
        school: _schoolController.text.trim().isEmpty
            ? null
            : _schoolController.text.trim(),
        iqLevel: _iqLevelController.text.trim().isEmpty
            ? null
            : _iqLevelController.text.trim(),
        healthStatus: _healthStatusController.text.trim(),
        dateOfBirth: _selectedDate ?? DateTime.now(),
        gender: widget.childProfile.gender,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        doctorId: _doctorUsernameController.text.trim().isEmpty
            ? null
            : _doctorUsernameController.text.trim(),
      );

      // Also update SharedPreferences for compatibility
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('child_profiles') ?? [];

      // Find and update the profile
      final updatedProfiles = profilesJson.map((json) {
        final profile =
            ChildProfile.fromMap(Map<String, dynamic>.from(jsonDecode(json)));
        if (profile.username == widget.childProfile.username) {
          return updatedProfile;
        }
        return profile;
      }).toList();

      // Save back to preferences
      final updatedProfilesJson = updatedProfiles
          .map((profile) => jsonEncode(profile.toMap()))
          .toList();
      await prefs.setStringList('child_profiles', updatedProfilesJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop(updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error updating profile: $e'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: const GlobalChatFAB(),
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.appBarTheme.iconTheme?.color,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withOpacity(0.1),
                        theme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تعديل بيانات الطفل',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildLabel(AppLocalizations.t('full_name_required',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_full_name',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.t('name_required',
                                locale: currentLanguage);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Age and Date of Birth Row
                      Row(
                        children: [
                          // Age
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(AppLocalizations.t('age_required',
                                    locale: currentLanguage)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.t('enter_age',
                                        locale: currentLanguage),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: theme.primaryColor, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.t('age_required',
                                          locale: currentLanguage);
                                    }
                                    final age = int.tryParse(value);
                                    if (age == null || age < 1 || age > 18) {
                                      return 'العمر يجب أن يكون بين 1 و 18 سنة';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Date of Birth
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(AppLocalizations.t('date_of_birth',
                                    locale: currentLanguage)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedDate != null
                                            ? theme.primaryColor
                                            : Colors.grey,
                                        width: _selectedDate != null ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedDate != null
                                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                              : AppLocalizations.t(
                                                  'select_date',
                                                  locale: currentLanguage),
                                          style: TextStyle(
                                            color: _selectedDate != null
                                                ? theme
                                                    .textTheme.bodyLarge?.color
                                                : Colors.grey,
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: _selectedDate != null
                                              ? theme.primaryColor
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Governorate
                      _buildLabel(AppLocalizations.t('governorate_required',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _governorateController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_governorate',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.t('governorate_required',
                                locale: currentLanguage);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // School
                      _buildLabel(AppLocalizations.t('school',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _schoolController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_school',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // IQ Level (Optional)
                      _buildLabel(AppLocalizations.t('iq_level',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _iqLevelController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_iq',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Health Status
                      _buildLabel(AppLocalizations.t('health_status_required',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _healthStatusController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_health_status',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.t('required',
                                locale: currentLanguage);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Username and Password Row
                      Row(
                        children: [
                          // Username
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(AppLocalizations.t(
                                    'username_required',
                                    locale: currentLanguage)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.t(
                                        'enter_username',
                                        locale: currentLanguage),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: theme.primaryColor, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.t('required',
                                          locale: currentLanguage);
                                    }
                                    if (value.length < 4) {
                                      return AppLocalizations.t('min_4_chars',
                                          locale: currentLanguage);
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Password
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(AppLocalizations.t(
                                    'password_required',
                                    locale: currentLanguage)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.t(
                                        'enter_password',
                                        locale: currentLanguage),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: theme.primaryColor, width: 2),
                                    ),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.t('required',
                                          locale: currentLanguage);
                                    }
                                    if (value.length < 6) {
                                      return AppLocalizations.t('min_6_chars',
                                          locale: currentLanguage);
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Doctor Username (Optional)
                      _buildLabel(AppLocalizations.t('doctor_username',
                          locale: currentLanguage)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _doctorUsernameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.t('enter_doctor_username',
                              locale: currentLanguage),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Update Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _updateProfile,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'تحديث الملف',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
