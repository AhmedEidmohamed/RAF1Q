import 'package:flutter/material.dart';
import '../models/models.dart';

/// Doctor Profile View Screen - Child Profile Management
/// Shows and manages child profiles for logged-in doctors
class DoctorProfileViewScreen extends StatefulWidget {
  final DoctorProfile? doctorProfile;
  final bool isEditable;

  const DoctorProfileViewScreen({
    Key? key,
    this.doctorProfile,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<DoctorProfileViewScreen> createState() =>
      _DoctorProfileViewScreenState();
}

class _DoctorProfileViewScreenState extends State<DoctorProfileViewScreen> {
  final bool _isCreatingChild = false;
  List<ChildProfile> _linkedChildren = [];

  @override
  void initState() {
    super.initState();
    _loadChildrenProfiles();
  }

  void _loadChildrenProfiles() {
    // Load mock data for now - in real app, load from database
    setState(() {
      _linkedChildren = [
        ChildProfile(
          fullName: 'أحمد محمد',
          username: 'ahmed_mohamed',
          password: 'password123',
          age: 8,
          dateOfBirth: DateTime(2016, 3, 15),
          gender: 'ذكر',
          governorate: 'القاهرة',
          school: 'مدرسة النصر',
          iqLevel: 'متوسط',
          healthStatus: 'جيد',
          doctorId: widget.doctorProfile?.id ?? '',
        ),
        ChildProfile(
          fullName: 'فاطمة علي',
          username: 'fatima_ali',
          password: 'password123',
          age: 6,
          dateOfBirth: DateTime(2018, 7, 20),
          gender: 'أنثى',
          governorate: 'القاهرة',
          school: 'مدرسة المستقبل',
          iqLevel: 'مرتفع',
          healthStatus: 'جيد',
          doctorId: widget.doctorProfile?.id ?? '',
        ),
      ];
    });
  }

  void _navigateToChildProfile(ChildProfile child) {
    Navigator.of(context).pushNamed('/child-profile', arguments: child);
  }

  void _navigateToCreateChild() {
    Navigator.of(context).pushNamed('/child-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007aff),
      appBar: AppBar(
        title: const Text(
          'ملفات الأطفال',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF007aff),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF007aff).withOpacity(0.1),
              const Color(0xFF0088ff).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'إدارة ملفات الأطفال',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5276),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'قم بإدارة ملفات الأطفال المرتبطين بك',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Create New Child Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToCreateChild,
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'إنشاء ملف طفل جديد',
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
                const SizedBox(height: 24),

                // Children List
                Expanded(
                  child: _linkedChildren.isEmpty
                      ? _buildEmptyState()
                      : _buildChildrenList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد ملفات أطفال بعد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "إنشاء ملف طفل جديد" لبدء إضافة ملفات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _linkedChildren.length,
      itemBuilder: (context, index) {
        final child = _linkedChildren[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToChildProfile(child),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Child Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          child.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1A5276),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Child Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2874A6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${child.age} سنة • ${child.gender}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            child.school ?? 'Not specified',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'مستوى الذكاء: ${child.iqLevel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
