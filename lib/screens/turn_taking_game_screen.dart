import 'package:flutter/material.dart';
import 'turn_taking_gameplay_screen.dart';

class GameLevel {
  final int level;
  final String title;
  final String description;
  final String imageUrl;

  GameLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class TurnTakingGameScreen extends StatelessWidget {
  TurnTakingGameScreen({Key? key}) : super(key: key);

  final List<GameLevel> levels = [
    GameLevel(
      level: 1,
      title: 'كرة السلة 🏀',
      description: 'مرر الكرة وسجل في السلة مع أصحابك!',
      imageUrl: 'https://images.pexels.com/photos/220383/pexels-photo-220383.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    GameLevel(
      level: 2,
      title: 'ملعب الأبطال ⚽',
      description: 'دوري مين؟ مرر الكرة وسجل هدفاً!',
      imageUrl: 'https://images.pexels.com/photos/399187/pexels-photo-399187.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: levels.length,
                  itemBuilder: (context, index) => _buildLevelCard(context, levels[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'دوري الأبطال 🏆',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GameLevel level) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TurnTakingGameplayScreen(level: level)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: NetworkImage(level.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              Text(level.description, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
