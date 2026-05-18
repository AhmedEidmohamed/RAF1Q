import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'stage1_recognizing_people_screen.dart';
import 'stage1_recognizing_places_screen.dart';
import 'stage1_recognizing_objects_screen.dart';
import 'test_people_recognition_screen.dart';
import 'test_places_recognition_screen.dart';
import 'test_objects_recognition_screen.dart';

class Stage1DashboardScreen extends StatelessWidget {
  const Stage1DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // تدريب اليوم
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'تدريب اليوم ✨',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'واصل التقدم لتحقيق نتائج مذهلة!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to next due training
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('ابدأ الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // تقدمك في مرحلة التعرف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تقدمك في مرحلة التعرف',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                _buildProgressRow('التعرف على الأشخاص', 0.0),
                const SizedBox(height: 12),
                _buildProgressRow('التعرف على الأماكن', 0.0),
                const SizedBox(height: 12),
                _buildProgressRow('التعرف على الأشياء', 0.05),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'ماذا تريد أن تتعلم اليوم؟',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cards
          _buildLearningCard(
            context: context,
            title: 'التعرف على الأشخاص',
            subtitle: 'تعلم كيفية تمييز وجوه أفراد العائلة والأصدقاء بكل سهولة.',
            imagePath: 'assets/images/persons_card.png', 
            isNetworkImage: false,
            route: '/recognizing-people',
            buttonText: 'ابدأ الآن',
          ),
          const SizedBox(height: 16),
          _buildLearningCard(
            context: context,
            title: 'التعرف على الأماكن',
            subtitle: 'اكتشف الأماكن المحيطة بك مثل المدرسة، الحديقة، والمنزل.',
            imagePath: 'assets/images/places_card.png',
            isNetworkImage: false,
            route: '/recognizing-places',
            buttonText: 'ابدأ الآن',
          ),
          const SizedBox(height: 16),
          _buildLearningCard(
            context: context,
            title: 'التعرف على الأشياء',
            subtitle: 'تعرف على الأدوات التي تستخدمها يومياً مثل الألعاب والأدوات المدرسية.',
            imagePath: 'assets/images/things_card.png',
            isNetworkImage: false,
            route: '/recognizing-objects',
            buttonText: 'واصل التدريب',
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الاختبارات والتقييم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildTestCard(
            context: context,
            title: 'اختبار التعرف على الأشخاص',
            subtitle: 'تقييم دوري (كل 3 أسابيع) لمدى تذكر الأشخاص',
            icon: Icons.help_outline,
            targetScreen: const TestPeopleRecognitionScreen(),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            title: 'اختبار التعرف على الأماكن',
            subtitle: 'تقييم دوري (كل 3 أسابيع) للقدرة على تمييز الأماكن',
            icon: Icons.extension_outlined,
            targetScreen: const TestPlacesRecognitionScreen(),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            title: 'اختبار التعرف على الأشياء',
            subtitle: 'تقييم دوري (كل 3 أسابيع) لحصيلة المفردات والأشياء',
            icon: Icons.star_border,
            targetScreen: const TestObjectsRecognitionScreen(),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text('${(progress * 100).toInt()}%', 
              style: const TextStyle(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildLearningCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    bool isNetworkImage = false,
    required String route,
    required String buttonText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: isNetworkImage
                ? Image.network(imagePath, height: 160, fit: BoxFit.cover)
                : Image.asset(imagePath, height: 160, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (route == '/recognizing-people') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecognizingPeopleScreen()));
                    } else if (route == '/recognizing-places') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecognizingPlacesScreen()));
                    } else if (route == '/recognizing-objects') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecognizingObjectsScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget targetScreen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
