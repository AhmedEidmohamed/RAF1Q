import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/global_chat_fab.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';

/// Progress Reports Screen
/// Shows progress tracking, charts, and achievements
class ProgressReportsScreen extends StatelessWidget {
  const ProgressReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;
    final args = ModalRoute.of(context)?.settings.arguments;
    List<ChildModel>? children;
    ChildProfile? singleChild;

    if (args is List<ChildModel>) {
      children = args;
    } else if (args is ChildProfile) {
      singleChild = args;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تقارير المتابعة',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ConstrainedPage(
        maxWidth: 800,
        child: children != null
            ? _buildDoctorReportsView(context, children)
            : _buildSingleChildReportsView(context, child: singleChild),
      ),
    );
  }

  Widget _buildDoctorReportsView(
      BuildContext context, List<ChildModel> children) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];

        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('children')
                .doc(child.id)
                .collection('stage_progress')
                .doc('stage_1') // Just using stage 1 as summary for now
                .snapshots(),
            builder: (context, snapshot) {
              int totalMinutes = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                totalMinutes = snapshot.data!.get('totalMinutes') ?? 0;
              }

              double mockProgress = (totalMinutes / 60).clamp(0.0, 1.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B)),
                              ),
                              Text(
                                'العمر: ${child.age} سنوات',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.blueGrey[400]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${totalMinutes} دقيقة',
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('التقدم العام (المرحلة الأولى)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: mockProgress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4F46E5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(Icons.access_time_rounded,
                            '$totalMinutes د', 'مدة التعلم'),
                        _buildMiniStat(Icons.check_circle_outline_rounded,
                            'نشط', 'الحالة'),
                        _buildMiniStat(
                            Icons.star_outline_rounded, 'جديد', 'إنجاز'),
                      ],
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildSingleChildReportsView(BuildContext context, {ChildProfile? child}) {
    final targetUid = child?.id ?? FirebaseAuth.instance.currentUser?.uid;
    final bool isDoctorView = child != null; // If child is passed, it's the doctor viewing a child
    
    if (targetUid == null) return const Center(child: Text('الرجاء تسجيل الدخول'));

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('children')
            .doc(targetUid)
            .collection('stage_progress')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final progressDocs = snapshot.data!.docs;
          final Map<int, int> stageMinutes = {1: 0, 2: 0, 3: 0};

          for (var doc in progressDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final stageNum = data['stageNumber'] as int?;
            if (stageNum != null) {
              stageMinutes[stageNum] = data['totalMinutes'] ?? 0;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (isDoctorView) _buildChildInfoCard(child!),
              _buildProgressChart(stageMinutes),
              const SizedBox(height: 24),
              
              if (isDoctorView) ...[
                const Text('مسار التعلم التفصيلي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                _buildLearningTimeline(targetUid),
                const SizedBox(height: 32),
              ],

              _buildStageDurationCard(1, 'التعرف الاجتماعي', stageMinutes[1]!,
                  const Color(0xFF4F46E5), Icons.visibility_rounded),
              _buildStageDurationCard(2, 'التفاعل الاجتماعي', stageMinutes[2]!,
                  const Color(0xFF8B5CF6), Icons.people_rounded),
              _buildStageDurationCard(3, 'التواصل الاجتماعي', stageMinutes[3]!,
                  const Color(0xFFEC4899), Icons.chat_bubble_rounded),
              const SizedBox(height: 24),
              
              const Text('تقارير المحادثة مع رفيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildBehaviorReportsList(targetUid),
              
              const SizedBox(height: 24),
              const Text('تقارير الحالة النفسية (مراقبة ذكية)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildEmotionReportsList(targetUid),

              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'يتم تحديث هذه التقارير تلقائياً بناءً على الوقت الذي يقضيه الطفل في كل مرحلة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget _buildChildInfoCard(ChildProfile child) {
    final displayName = child.fullName.isNotEmpty ? child.fullName : "طفل";
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF4F46E5),
            child: Text(displayName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('العمر: ${child.age} سنوات', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTimeline(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService().getLearningActivities(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        final activities = snapshot.data!.docs;

        if (activities.isEmpty) {
          return const Center(child: Text('لا توجد أنشطة مسجلة بعد', style: TextStyle(color: Colors.grey)));
        }

        return Column(
          children: activities.take(10).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['activityType'];
            final itemName = data['itemName'];
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            IconData icon;
            Color color;
            String text;

            switch(type) {
              case 'view_item':
                icon = Icons.visibility_outlined;
                color = Colors.blue;
                text = 'شاهد صورة: $itemName';
                break;
              case 'quiz_success':
                icon = Icons.check_circle_outline;
                color = Colors.green;
                text = 'نجح في التعرف على: $itemName';
                break;
              case 'quiz_fail':
                icon = Icons.highlight_off;
                color = Colors.orange;
                text = 'حاول التعرف على: $itemName';
                break;
              default:
                icon = Icons.info_outline;
                color = Colors.grey;
                text = 'نشاط: $itemName';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProgressChart(Map<int, int> stageMinutes) {
    int total = stageMinutes.values.fold(0, (sum, m) => sum + m);
    if (total == 0) total = 1; // Avoid division by zero

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Text('توزيع وقت التعلم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF4F46E5),
                    value: stageMinutes[1]!.toDouble(),
                    title: '${((stageMinutes[1]! / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF8B5CF6),
                    value: stageMinutes[2]!.toDouble(),
                    title: '${((stageMinutes[2]! / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFEC4899),
                    value: stageMinutes[3]!.toDouble(),
                    title: '${((stageMinutes[3]! / total) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(const Color(0xFF4F46E5), 'م 1'),
              const SizedBox(width: 16),
              _buildChartLegend(const Color(0xFF8B5CF6), 'م 2'),
              const SizedBox(width: 16),
              _buildChartLegend(const Color(0xFFEC4899), 'م 3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStageDurationCard(
      int stageNum, String title, int minutes, Color color, IconData icon) {
    double progress = (minutes / 60).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المرحلة $stageNum',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold)),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$minutes',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const Text('دقيقة',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorReportsList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('children')
          .doc(uid)
          .collection('behavior_reports')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'لم يتم تسجيل أي تقارير سلوكية بعد. اجعل الطفل يتحدث مع رفيق لإنشاء تقارير ذكية.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final reports = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['is_hidden'] != true;
        }).toList();

        if (reports.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'تم إخفاء جميع التقارير. ستظهر تقارير جديدة عند تفاعل الطفل مع رفيق.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: reports.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final report = data['report'] as Map<String, dynamic>?;
            final analysis = report?['behavior_analysis'] ?? 'لا يوجد تحليل';
            
            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.horizontal,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              onDismissed: (direction) {
                doc.reference.update({'is_hidden': true});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إخفاء التقرير من القائمة')),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Colors.amber),
                  ),
                  title: const Text('تقرير تفاعل', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(analysis, style: const TextStyle(height: 1.5)),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmotionReportsList(String childId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('children')
          .doc(childId)
          .collection('emotion_logs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'لا توجد بيانات مشاعر مسجلة بعد. نظام المراقبة الذكي يعمل الآن لتسجيل حالة الطفل.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final reports = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['is_hidden'] != true;
        }).toList();

        if (reports.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'تم إخفاء جميع سجلات المشاعر.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: reports.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final emotion = (data['emotion'] ?? 'unknown').toString().toLowerCase();
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final activityTitle = data['gesture_title'] ?? 'تدريب عام';
            
            IconData icon;
            Color color;
            String label;

            switch(emotion) {
              case 'happy':
                icon = Icons.sentiment_very_satisfied_rounded;
                color = Colors.green;
                label = 'سعيد 😊';
                break;
              case 'sad':
                icon = Icons.sentiment_very_dissatisfied_rounded;
                color = Colors.blue;
                label = 'حزين 😔';
                break;
              case 'angry':
                icon = Icons.sentiment_dissatisfied_rounded;
                color = Colors.red;
                label = 'منفعل 😠';
                break;
              case 'neutral':
                icon = Icons.sentiment_neutral_rounded;
                color = Colors.blueGrey;
                label = 'طبيعي 😐';
                break;
              default:
                icon = Icons.sentiment_satisfied_rounded;
                color = Colors.amber;
                label = 'هادئ ✨';
            }

            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.horizontal,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              onDismissed: (direction) {
                doc.reference.update({'is_hidden': true});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إخفاء السجل من القائمة')),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('أثناء تدريب: $activityTitle'),
                  trailing: Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// Keep the rest of the file (models and chart) as is

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stage Progress Model
class StageProgress {
  final String name;
  final double progress;
  final int activitiesCompleted;
  final int totalActivities;
  final Color color;
  final IconData icon;

  StageProgress({
    required this.name,
    required this.progress,
    required this.activitiesCompleted,
    required this.totalActivities,
    required this.color,
    required this.icon,
  });
}

/// Achievement Data Model
class AchievementData {
  final String title;
  final String date;
  final String emoji;

  AchievementData({
    required this.title,
    required this.date,
    required this.emoji,
  });
}

/// Weekly Bar Chart Widget
class _WeeklyBarChart extends StatelessWidget {
  final List<double> values = [3, 5, 2, 6, 4, 7, 5];
  final List<String> labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        maxY: 8,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    labels[i],
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: theme.colorScheme.primary,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}
