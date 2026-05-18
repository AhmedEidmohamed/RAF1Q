import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';

/// Doctor Control Panel Screen
/// Control panel for medical staff and doctors
class DoctorControlPanelScreen extends StatefulWidget {
  const DoctorControlPanelScreen({Key? key}) : super(key: key);

  @override
  State<DoctorControlPanelScreen> createState() =>
      _DoctorControlPanelScreenState();
}

class _DoctorControlPanelScreenState extends State<DoctorControlPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _mainControlOptions = [
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

  final List<Map<String, dynamic>> _secondaryControlOptions = [
    {
      'title': 'الرسائل',
      'description': 'المراسلة مع المرضى وأولياء الأمور',
      'icon': Icons.message_rounded,
    },
    {
      'title': 'الإعدادات',
      'description': 'إعدادات النظام والملف الشخصي',
      'icon': Icons.settings_rounded,
    },
  ];

  void _onItemTapped(String category, int index) {
    // TODO: Navigate to respective screens
    switch (category) {
      case 'main':
        switch (index) {
          case 0:
            // Navigate to patients list
            break;
          case 1:
            // Navigate to appointments
            break;
          case 2:
            // Navigate to reports
            break;
        }
        break;
      case 'secondary':
        switch (index) {
          case 0:
            // Navigate to messages
            break;
          case 1:
            // Navigate to settings
            break;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم الطبي',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.appBarTheme.iconTheme,
        flexibleSpace: Container(),
      ),
      body: Column(
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
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.medical_services_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لوحة التحكم الطبي',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'إدارة النظام الطبي والمرضى',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.dashboard_rounded),
                        text: 'الرئيسية',
                      ),
                      Tab(
                        icon: Icon(Icons.message_rounded),
                        text: 'التواصل',
                      ),
                      Tab(
                        icon: Icon(Icons.settings_rounded),
                        text: 'الإعدادات',
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Main Controls Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'التحكم الرئيسي',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _mainControlOptions.length,
                              itemBuilder: (context, index) {
                                final option = _mainControlOptions[index];
                                return InkWell(
                                  onTap: () => _onItemTapped('main', index),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.dividerTheme.color ??
                                            Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            option['icon'] as IconData,
                                            size: 32,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          option['title'] as String,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option['description'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .textTheme.bodySmall?.color
                                                ?.withOpacity(0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Communication Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'التواصل والإعدادات',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _secondaryControlOptions.length,
                              itemBuilder: (context, index) {
                                final option = _secondaryControlOptions[index];
                                return InkWell(
                                  onTap: () =>
                                      _onItemTapped('secondary', index),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.dividerTheme.color ??
                                            Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            option['icon'] as IconData,
                                            size: 32,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          option['title'] as String,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option['description'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .textTheme.bodySmall?.color
                                                ?.withOpacity(0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
