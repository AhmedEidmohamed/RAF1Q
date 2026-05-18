import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'turn_taking_game_screen.dart';

enum GameTheme { basketball, soccer }

class TurnTakingGameplayScreen extends StatefulWidget {
  final GameLevel level;
  const TurnTakingGameplayScreen({Key? key, required this.level}) : super(key: key);

  @override
  State<TurnTakingGameplayScreen> createState() => _TurnTakingGameplayScreenState();
}

class _TurnTakingGameplayScreenState extends State<TurnTakingGameplayScreen>
    with TickerProviderStateMixin {
  int _currentTurn = 0;
  final int _humanPlayerIndex = 0;
  int _score = 0;
  int _totalTurns = 0;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _showCelebration = false;
  bool _earlyPressDetected = false;
  
  late FlutterTts _tts;
  bool _ttsReady = false;
  late GameTheme _theme;

  late AnimationController _itemMoveController;
  late Animation<double> _itemCurve;
  late Animation<Offset> _itemOffset;

  late List<PlayerPosition> _players;

  @override
  void initState() {
    super.initState();
    _setThemeByLevel();
    _initTts();
    _itemMoveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _itemCurve = CurvedAnimation(parent: _itemMoveController, curve: Curves.easeInOut);
    _itemOffset = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_itemCurve);
  }

  void _setThemeByLevel() {
    if (widget.level.level == 1) {
      _theme = GameTheme.basketball;
    } else {
      _theme = GameTheme.soccer;
    }
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('ar-SA').catchError((e) => _tts.setLanguage('ar'));
    await _tts.setSpeechRate(0.5);
    _ttsReady = true;
  }

  @override
  void dispose() {
    _itemMoveController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _startGame() {
    if (!mounted) return;
    setState(() {
      _gameStarted = true;
      _currentTurn = 0;
      _score = 0;
      _totalTurns = 0;
    });
    _initPlayerPositions();
    _speak(_getStartText());
    if (_currentTurn != _humanPlayerIndex) _scheduleAITurn();
  }

  String _getStartText() {
    return _theme == GameTheme.basketball ? 'مرر كرة السلة وسجل في السلة' : 'مرر الكورة لأصحابك وسجل هدف';
  }

  void _initPlayerPositions() {
    final size = MediaQuery.of(context).size;
    _players = [
      PlayerPosition(name: 'أنت', color: Colors.orange, offset: Offset(size.width * 0.5, size.height * 0.75), emoji: '🏃‍♂️'),
      PlayerPosition(name: 'أحمد', color: Colors.blue, offset: Offset(size.width * 0.2, size.height * 0.5), emoji: '🏃'),
      PlayerPosition(name: 'سارة', color: Colors.pink, offset: Offset(size.width * 0.8, size.height * 0.5), emoji: '🏃‍♀️'),
      PlayerPosition(name: 'مُنى', color: Colors.amber, offset: Offset(size.width * 0.5, size.height * 0.3), emoji: '🏃'),
    ];
  }

  Future<void> _speak(String text) async {
    if (_ttsReady) {
      await _tts.stop();
      await _tts.speak(text);
    }
  }

  void _onPassItem() {
    if (!_gameStarted || _gameOver || _currentTurn != _humanPlayerIndex) {
      if (_gameStarted && !_gameOver) _onEarlyPress();
      return;
    }
    _moveItemToPlayer((_currentTurn + 1) % _players.length);
  }

  void _onEarlyPress() {
    if (!mounted) return;
    setState(() => _earlyPressDetected = true);
    _speak('انتظر دورك يا بطل');
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _earlyPressDetected = false);
    });
  }

  void _moveItemToPlayer(int targetIndex) {
    if (!mounted) return;
    Offset start = _players[_currentTurn].offset;
    Offset end = _players[targetIndex].offset;

    setState(() {
      _itemOffset = Tween<Offset>(begin: start, end: end).animate(_itemCurve);
    });

    _itemMoveController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _currentTurn = targetIndex;
        _totalTurns++;
      });
      if (_totalTurns % 4 == 0) {
        _performSpecialAction();
      } else {
        _advanceGame();
      }
    });
  }

  void _performSpecialAction() {
    if (_theme == GameTheme.soccer) {
      _shootGoal();
    } else {
      _shootHoop();
    }
  }

  void _shootHoop() {
    setState(() {
      _itemOffset = Tween<Offset>(begin: _players[_currentTurn].offset, end: Offset(MediaQuery.of(context).size.width * 0.5, 120)).animate(_itemCurve);
    });
    _itemMoveController.forward(from: 0).then((_) {
      setState(() {
        _score++;
        _showCelebration = true;
      });
      _speak('برافو سجلت في السلة');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCelebration = false);
          _advanceGame();
        }
      });
    });
  }

  void _shootGoal() {
    setState(() {
      _itemOffset = Tween<Offset>(begin: _players[_currentTurn].offset, end: Offset(MediaQuery.of(context).size.width * 0.5, 80)).animate(_itemCurve);
    });
    _itemMoveController.forward(from: 0).then((_) {
      setState(() {
        _score++;
        _showCelebration = true;
      });
      _speak('برافو هدف رائع');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCelebration = false);
          _advanceGame();
        }
      });
    });
  }

  void _advanceGame() {
    if (!mounted) return;
    if (_score >= 3) {
      setState(() => _gameOver = true);
      _speak('أحسنتم أنتم أبطال التبادل الرياضي');
      return;
    }
    if (_currentTurn == _humanPlayerIndex) {
      _speak('مرر الآن');
    } else {
      _scheduleAITurn();
    }
  }

  void _scheduleAITurn() {
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted && !(_gameOver || _showCelebration)) {
        _moveItemToPlayer((_currentTurn + 1) % _players.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme == GameTheme.soccer ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
      body: Stack(
        children: [
          if (_theme == GameTheme.soccer) _buildSoccerLines(),
          if (_theme == GameTheme.basketball) _buildBasketballLines(),
          if (_gameStarted) ..._buildPlayers(),
          if (_gameStarted) _buildMovingItem(),
          if (_gameStarted) _buildHeaderUI(),
          if (!_gameStarted) _buildStartOverlay(),
          if (_showCelebration) _buildCelebrationOverlay(),
          if (_gameOver) _buildGameOverOverlay(),
          if (_earlyPressDetected) _buildWarningOverlay(),
          if (_gameStarted && !_gameOver) _buildPassButton(),
          if (_gameStarted && !_gameOver) _buildScoreText(),
        ],
      ),
    );
  }

  Widget _buildSoccerLines() {
    return CustomPaint(size: Size.infinite, painter: SoccerFieldPainter());
  }

  Widget _buildBasketballLines() {
    return CustomPaint(size: Size.infinite, painter: BasketballFieldPainter());
  }

  Widget _buildHeaderUI() {
    return Positioned(
      top: 40, left: 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.shade200, width: 2),
            ),
            child: Row(
              children: [
                Text(_theme == GameTheme.soccer ? '⚽' : '🏀', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(_theme == GameTheme.soccer ? 'دوري مين؟' : 'رمية السلة', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 36),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreText() {
    return Positioned(
      top: 110, right: 30,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
        child: Text('النقاط: $_score', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  List<Widget> _buildPlayers() {
    return _players.asMap().entries.map((entry) {
      int idx = entry.key;
      var p = entry.value;
      bool isActive = _currentTurn == idx;
      return Positioned(
        left: p.offset.dx - 40, top: p.offset.dy - 100,
        child: Column(
          children: [
            if (isActive) const Icon(Icons.arrow_drop_down, color: Colors.yellow, size: 40),
            _buildCartoonPlayer(p.color, p.emoji, isActive),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
              child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCartoonPlayer(Color color, String emoji, bool isActive) {
    return AnimatedScale(
      scale: isActive ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 45)),
          Container(
            width: 35, height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 2)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 12, color: Colors.white),
              const SizedBox(width: 10),
              Container(width: 8, height: 12, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovingItem() {
    String item = _theme == GameTheme.soccer ? '⚽' : '🏀';
    return AnimatedBuilder(
      animation: _itemMoveController,
      builder: (context, child) {
        Offset pos = _itemMoveController.isAnimating ? _itemOffset.value : _players[_currentTurn].offset;
        double bounce = math.sin(_itemMoveController.value * math.pi) * 40;
        return Positioned(
          left: pos.dx - 25, top: pos.dy - 25 - bounce,
          child: Transform.rotate(
            angle: _itemMoveController.value * 6.28,
            child: Text(item, style: const TextStyle(fontSize: 50)),
          ),
        );
      },
    );
  }

  Widget _buildPassButton() {
    bool isMyTurn = _currentTurn == _humanPlayerIndex;
    return Positioned(
      bottom: 40, left: 30, right: 30,
      child: GestureDetector(
        onTap: _onPassItem,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: isMyTurn ? const Color(0xFFFFD600) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isMyTurn) Text(_theme == GameTheme.soccer ? '⚽' : '🏀', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  isMyTurn ? 'مرر!' : 'انتظر دورك...',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF33691E)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_theme == GameTheme.soccer ? '⚽' : '🏀', style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              Text(_theme == GameTheme.soccer ? 'دوري مين؟' : 'تحدي السلة', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('دخول اللعبة 🎮', style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(child: Container(color: Colors.orange.withOpacity(0.5), child: Center(child: Text('برافو! 🏆✨', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)))));
  }

  Widget _buildWarningOverlay() {
    return Center(child: Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), child: const Text('انتظر دورك! 😊', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))));
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              const Text('أبطال الرياضة!', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('العودة للمهام', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), paint);
    canvas.drawLine(Offset(10, size.height * 0.5), Offset(size.width - 10, size.height * 0.5), paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 60, paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.25, 10, size.width * 0.5, 80), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.25, size.height - 90, size.width * 0.5, 80), paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BasketballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), paint);
    canvas.drawArc(Rect.fromLTWH(size.width * 0.1, -50, size.width * 0.8, 200), 0, math.pi, false, paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, 10, size.width * 0.4, 120), paint);
    canvas.drawCircle(Offset(size.width * 0.5, 120), 25, paint);
    canvas.drawLine(Offset(size.width * 0.4, 95), Offset(size.width * 0.6, 95), paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PlayerPosition {
  final String name;
  final Color color;
  final Offset offset;
  final String emoji;
  PlayerPosition({required this.name, required this.color, required this.offset, required this.emoji});
}
