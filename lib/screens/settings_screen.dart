import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialsteps_app/models/models.dart';
import 'package:socialsteps_app/models/child_model.dart';
import 'package:socialsteps_app/screens/edit_doctor_profile_screen.dart';
import '../widgets/global_chat_fab.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

/// Settings & Accessibility Screen
/// Language, audio, accessibility, and parental controls
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _voiceSpeed;
  late double _volume;
  bool _highContrast = false;
  final bool _parentalControls = true;

  // Children list for doctor
  List<ChildModel> _assignedChildren = [];
  bool _isLoadingChildren = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final tabLength = appState.userRole == 'specialist' ? 2 : 1;
    _tabController = TabController(length: tabLength, vsync: this);
    _voiceSpeed = 80.0;
    _volume = 70.0;

    if (appState.userRole == 'specialist') {
      _fetchAssignedChildren();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final theme = Theme.of(context);
        final fillColor =
            theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
        final mutedColor = theme.textTheme.bodyMedium?.color ??
            theme.colorScheme.onSurface.withOpacity(0.7);

        return Scaffold(
          floatingActionButton: const GlobalChatFAB(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralSettings(appState, theme, fillColor, mutedColor),
              if (appState.userRole == 'specialist')
                _buildDoctorControlPanel(appState, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneralSettings(
      AppState appState, ThemeData theme, Color fillColor, Color mutedColor) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Doctor Profile Section
        _buildSectionHeader(
          'الملف الشخصي للدكتور',
          Icons.person_rounded,
          const Color(0xFF667EEA),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007aff), Color(0xFF0088ff)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.currentDoctor?.fullName ??
                                'دكتور أحمد محمد',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.currentDoctor?.specialization ??
                                'علاج النطق',
                            style: TextStyle(
                              fontSize: 14,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow('اسم المستخدم',
                    appState.currentDoctor?.username ?? 'drahmed'),
                const Divider(height: 24),
                _buildInfoRow('البريد الإلكتروني',
                    appState.currentDoctor?.email ?? 'ahmed@clinic.com'),
                const Divider(height: 24),
                _buildInfoRow('رقم الهاتف',
                    appState.currentDoctor?.phone ?? '+201234567890'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditDoctorProfileScreen(
                            doctorProfile: appState.currentDoctor ??
                                DoctorProfile(
                                  id: '',
                                  fullName: '',
                                  username: '',
                                  password: '',
                                  email: '',
                                  phone: '',
                                  specialization: '',
                                ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Language & Audio Section
        _buildSectionHeader(
          AppLocalizations.t('language_audio',
              locale: appState.currentLanguage),
          Icons.language,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Selector
                Text(
                  AppLocalizations.t('language',
                      locale: appState.currentLanguage),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: appState.currentLanguage,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(AppLocalizations.t('english',
                          locale: appState.currentLanguage)),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text(AppLocalizations.t('arabic',
                          locale: appState.currentLanguage)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      appState.setLanguage(value);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Voice Speed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.t('voice_speed',
                          locale: appState.currentLanguage),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_voiceSpeed.toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _voiceSpeed,
                  min: 50,
                  max: 150,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _voiceSpeed = value;
                    });
                    // TODO: Update voice speed setting
                  },
                ),
                const SizedBox(height: 12),

                // Volume
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.t('volume',
                              locale: appState.currentLanguage),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_volume.toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _volume,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                    // TODO: Update volume setting
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Accessibility Section
        _buildSectionHeader(
          AppLocalizations.t('accessibility', locale: appState.currentLanguage),
          Icons.accessibility_new,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Dark Mode
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: AppLocalizations.t('dark_mode',
                      locale: appState.currentLanguage),
                  subtitle: 'Reduce eye strain',
                  value: appState.isDarkMode,
                  onChanged: (value) {
                    appState.toggleDarkMode();
                  },
                ),
                const Divider(height: 24),

                // High Contrast
                _buildSwitchTile(
                  icon: Icons.contrast,
                  title: AppLocalizations.t('high_contrast',
                      locale: appState.currentLanguage),
                  subtitle: AppLocalizations.t('better_visibility',
                      locale: appState.currentLanguage),
                  value: _highContrast,
                  onChanged: (value) {
                    setState(() {
                      _highContrast = value;
                    });
                    // TODO: Implement high contrast mode
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Logout Section
        _buildSectionHeader(
          'الحساب',
          Icons.exit_to_app,
          const Color(0xFFEF4444),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _fetchAssignedChildren() async {
    setState(() {
      _isLoadingChildren = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Fetching children for doctor: ${user.uid}');
        final snapshot = await FirebaseFirestore.instance
            .collection('children')
            .where('assignedDoctorId', isEqualTo: user.uid)
            .get();

        print('Fetched ${snapshot.docs.length} children');
        setState(() {
          _assignedChildren = snapshot.docs
              .map((doc) => ChildModel.fromMap(doc.id, doc.data()))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching children: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'فشل تحميل قائمة الأطفال: قد تكون مشكلة في صلاحيات Firestore'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الخروج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDoctorControlPanel(AppState appState, ThemeData theme) {
    final List<Map<String, dynamic>> mainControlOptions = [
      {
        'title': 'المرضى',
        'description': 'عرض وإدارة قائمة المرضى',
        'icon': Icons.people_rounded,
      },
      {
        'title': 'المواعيد',
        'description': 'جدولة المواعيد والزيارات',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'title': 'التقارير',
        'description': 'تقارير طبية وإحصائيات',
        'icon': Icons.analytics_rounded,
      },
    ];

    final List<Map<String, dynamic>> secondaryControlOptions = [
      {
        'title': 'الإعدادات',
        'description': 'إعدادات النظام والتطبيق',
        'icon': Icons.settings_rounded,
      },
      {
        'title': 'المساعدة',
        'description': 'الدعم والمساعدة الفنية',
        'icon': Icons.help_rounded,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Profile Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007aff), Color(0xFF0088ff)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.currentDoctor?.fullName ?? 'دكتور أحمد محمد',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.currentDoctor?.specialization ??
                              'علاج النطق',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.people_rounded,
                      '${_assignedChildren.length}',
                      'إجمالي المرضى',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.calendar_today_rounded,
                      '8',
                      'مواعيد اليوم',
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Assigned Children Section
          Text(
            'الأطفال المخصصين',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingChildren)
            const Center(child: CircularProgressIndicator())
          else if (_assignedChildren.isEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد أطفال مخصصين',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._assignedChildren.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: child.profileImageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  child.profileImageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person,
                                        color: Colors.blue);
                                  },
                                ),
                              )
                            : Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(
                        child.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text('العمر: ${child.age}'),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // TODO: Navigate to child details
                      },
                    ),
                  ),
                )),
          const SizedBox(height: 24),

          // Main Control Options
          Text(
            'التحكم الرئيسي',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...mainControlOptions
              .map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildControlOption(
                      option['title']!,
                      option['description']!,
                      option['icon'] as IconData,
                      () {
                        // TODO: Navigate to respective screens
                      },
                    ),
                  ))
              .toList(),
          const SizedBox(height: 24),

          // Secondary Control Options
          Text(
            'التحكم الثانوي',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...secondaryControlOptions
              .map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildControlOption(
                      option['title']!,
                      option['description']!,
                      option['icon'] as IconData,
                      () {
                        // TODO: Navigate to respective screens
                      },
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlOption(
      String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color ??
        theme.colorScheme.onSurface.withOpacity(0.7);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.iconTheme.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
