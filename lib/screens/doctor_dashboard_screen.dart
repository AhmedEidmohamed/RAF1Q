import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/child_model.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';
import 'child_detail_screen.dart';
import 'doctor_child_chat_screen.dart';
import '../widgets/custom_widgets.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DoctorProfile? _currentDoctor;
  List<ChildModel> _linkedChildren = [];
  bool _isLoadingChildren = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize doctor data immediately from AppState
    _currentDoctor =
        Provider.of<AppState>(context, listen: false).currentDoctor;
    if (_currentDoctor != null) {
      _fetchAssignedChildren();
    }
  }

  Future<void> _fetchAssignedChildren() async {
    setState(() => _isLoadingChildren = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('children')
            .where('assignedDoctorId', isEqualTo: user.uid)
            .get();

        setState(() {
          _linkedChildren = snapshot.docs
              .map((doc) => ChildModel.fromMap(doc.id, doc.data()))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching children: $e');
    } finally {
      setState(() => _isLoadingChildren = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = Provider.of<AppState>(context).currentDoctor;

    if (doctor == null) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول أولاً')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ConstrainedPage(
        maxWidth: 900,
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -50,
              right: -50,
              child: _buildDecorativeCircle(
                  200, const Color(0xFF4F46E5).withOpacity(0.03)),
            ),
            Positioned(
              bottom: 100,
              left: -30,
              child: _buildDecorativeCircle(
                  120, const Color(0xFF0EA5E9).withOpacity(0.03)),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMainOverview(),
                        _buildChildrenList(),
                        _buildMessagesTab(),
                        _buildSettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConstrainedPage(
        maxWidth: 900,
        child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  backgroundImage: (_currentDoctor?.photoUrl != null &&
                          _currentDoctor!.photoUrl!.isNotEmpty)
                      ? NetworkImage(_currentDoctor!.photoUrl!)
                      : null,
                  child: (_currentDoctor?.photoUrl == null ||
                          _currentDoctor!.photoUrl!.isEmpty)
                      ? Text(
                          (_currentDoctor?.fullName != null &&
                                  _currentDoctor!.fullName.isNotEmpty)
                              ? _currentDoctor!.fullName[0]
                              : 'D',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5)))
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً بك، دكتور',
                      style: TextStyle(
                          color: Colors.blueGrey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text(
                    _currentDoctor!.fullName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ],
          ),
          _buildIconButton(Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
    );
  }

  Widget _buildMainOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Summary
          Row(
            children: [
              Expanded(
                  child: _buildMetricCard(
                      'إجمالي الحالات',
                      _linkedChildren.length.toString(),
                      Icons.people_outline,
                      const Color(0xFF4F46E5))),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMetricCard('الرسائل', '12',
                      Icons.chat_bubble_outline, const Color(0xFF0EA5E9))),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مرضاك الحاليين',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('عرض الكل',
                    style: TextStyle(
                        color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingChildren)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()))
          else if (_linkedChildren.isEmpty)
            _buildEmptyState()
          else
            ..._linkedChildren.take(3).map((child) => _buildPatientCard(child)),

          const SizedBox(height: 32),
          _buildQuickActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 20),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: Colors.blueGrey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPatientCard(ChildModel child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15)),
            child:
                const Icon(Icons.child_care_rounded, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text('العمر: ${child.age} سنوات',
                    style:
                        TextStyle(color: Colors.blueGrey[500], fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToDetail(child),
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF4F46E5)),
            style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5).withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return _isLoadingChildren
        ? const Center(child: CircularProgressIndicator())
        : _linkedChildren.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _linkedChildren.length,
                itemBuilder: (context, index) =>
                    _buildPatientCard(_linkedChildren[index]),
              );
  }

  Widget _buildMessagesTab() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return _buildEmptyMessages();

        // Group by sender
        final Map<String, Map<String, dynamic>> latestMessages = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final senderId = data['senderId'];
          if (!latestMessages.containsKey(senderId)) {
            latestMessages[senderId] = data;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: latestMessages.length,
          itemBuilder: (context, index) {
            final msg = latestMessages.values.elementAt(index);
            return _buildMessageTile(msg);
          },
        );
      },
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.person_outline, color: Color(0xFF64748B))),
        title: Text(msg['senderName'] ?? 'مستخدم',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(msg['text'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.blueGrey[500])),
        trailing:
            const Icon(Icons.chevron_right, color: Colors.blueGrey, size: 20),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DoctorChildChatScreen(
                    receiverId: msg['senderId'],
                    receiverName: msg['senderName']))),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSettingsGroup('الحساب', [
          _buildSettingsItem(Icons.person_outline, 'تعديل الملف الشخصي', () {}),
          _buildSettingsItem(
              Icons.notifications_none_rounded, 'تنبيهات المواعيد', () {}),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('عام', [
          _buildSettingsItem(Icons.language_rounded, 'اللغة', () {}),
          _buildSettingsItem(
              Icons.help_outline_rounded, 'مركز المساعدة', () {}),
        ]),
        const SizedBox(height: 32),
        _buildSettingsItem(Icons.logout_rounded, 'تسجيل الخروج', () async {
          await FirebaseAuth.instance.signOut();
          Provider.of<AppState>(context, listen: false).setCurrentDoctor(null);
          Navigator.pushReplacementNamed(context, '/role-selection');
        }, color: Colors.red),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[400],
                letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueGrey[100]!)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF4F46E5), size: 22),
      title: Text(title,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w500, fontSize: 15)),
      trailing:
          const Icon(Icons.chevron_right, size: 18, color: Colors.blueGrey),
      onTap: onTap,
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إجراءات سريعة',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
                Icons.assignment_outlined, 'تقارير كل الأطفال', const Color(0xFF0EA5E9),
                () {
              Navigator.pushNamed(context, '/progress-reports', arguments: _linkedChildren);
            }),
            _buildActionItem(Icons.calendar_today_rounded, 'المواعيد',
                const Color(0xFF8B5CF6), () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('ميزة المواعيد ستكون متاحة قريباً')));
            }),
            _buildActionItem(
                Icons.analytics_outlined, 'الإحصائيات', const Color(0xFFF59E0B),
                () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('ميزة الإحصائيات ستكون متاحة قريباً')));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF4F46E5), width: 3),
          insets: EdgeInsets.symmetric(horizontal: 40),
        ),
        labelColor: const Color(0xFF4F46E5),
        unselectedLabelColor: Colors.blueGrey[400],
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_rounded, size: 24)),
          Tab(icon: Icon(Icons.people_rounded, size: 24)),
          Tab(icon: Icon(Icons.chat_bubble_rounded, size: 24)),
          Tab(icon: Icon(Icons.settings_rounded, size: 24)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.child_care_rounded,
                size: 64, color: Colors.blueGrey[200]),
            const SizedBox(height: 16),
            Text('لا يوجد حالات نشطة حالياً',
                style: TextStyle(color: Colors.blueGrey[400], fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
        child: Text('لا توجد رسائل',
            style: TextStyle(color: Colors.blueGrey[400])));
  }

  void _navigateToDetail(ChildModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailScreen(
          child: ChildProfile(
            id: child.id,
            fullName: child.name.isNotEmpty ? child.name : 'طفل رفيق',
            age: int.tryParse(child.age) ?? 0,
            dateOfBirth: DateTime.now()
                .subtract(Duration(days: (int.tryParse(child.age) ?? 0) * 365)),
            gender: 'غير محدد',
            governorate: child.preferences?['governorate'] ?? 'غير محدد',
            healthStatus: 'مستقرة',
            username: child.name.isNotEmpty ? child.name : 'user',
            password: '',
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
