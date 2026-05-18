import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'stage2_social_gestures_screen.dart';
import 'behavior_training_screen.dart';
import 'stage2_cooperative_play_screen.dart';

class Stage2DashboardScreen extends StatelessWidget {
  const Stage2DashboardScreen({Key? key}) : super(key: key);

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
                const Icon(Icons.lightbulb_outline, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'تدريب اليوم ✨',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'فهم المشاعر والانفعالات',
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
          
          // تقدمك في مرحلة التفاعل
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
                  'تقدمك في مرحلة التفاعل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                _buildProgressRow('الإشارات الاجتماعية', 0.0),
                const SizedBox(height: 12),
                _buildProgressRow('المشاعر والانفعالات', 0.0),
                const SizedBox(height: 12),
                _buildProgressRow('مواقف الحياة اليومية', 0.0),
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
            title: 'الإشارات الاجتماعية',
            subtitle: 'يتعلم الطفل فهم الإشارات مثل الإيماءات ولغة الجسد بطريقة ممتعة وتفاعلية.',
            imagePath: 'assets/images/interaction_social.jpg', 
            isNetworkImage: false,
            targetScreen: const SocialGesturesScreen(),
            buttonText: 'ابدأ الآن',
          ),
          const SizedBox(height: 16),
          _buildLearningCard(
            context: context,
            title: 'المشاعر والانفعالات',
            subtitle: 'يتدرب الطفل على التعرف على المشاعر وردود الفعل من خلال مواقف تعليمية مشوقة.',
            imagePath: 'assets/images/interaction_emotions_2.jpg',
            isNetworkImage: false,
            targetScreen: const BehaviorTrainingScreen(),
            buttonText: 'ابدأ الآن',
          ),
          const SizedBox(height: 16),
          _buildLearningCard(
            context: context,
            title: 'مواقف الحياة اليومية',
            subtitle: 'يتعلم الطفل التعرف على المواقف اليومية مثل الأكل والشرب واللعب والنوم.',
            imagePath: 'assets/images/interaction_daily.png',
            isNetworkImage: false,
            targetScreen: const CooperativePlayScreen(),
            buttonText: 'ابدأ الآن',
          ),
          
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Text(
                'اختبر معلوماتك',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildTestCard(
            context: context,
            title: 'اختبار الإشارات الاجتماعية',
            subtitle: 'تحدي قراءة الإيماءات والتعبيرات',
            icon: Icons.assignment_ind_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')));
            },
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            title: 'اختبار المشاعر والانفعالات',
            subtitle: 'ماذا تشعر الشخصية الآن؟',
            icon: Icons.psychology_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')));
            },
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context: context,
            title: 'اختبار الحياة اليومية',
            subtitle: 'فهم السلوكيات والأنشطة المعتادة',
            icon: Icons.arrow_back_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')));
            },
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
    required Widget targetScreen,
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
