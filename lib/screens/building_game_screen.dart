import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'cooperative_jigsaw_screen.dart';

enum BuildingType { house, mosque, tower, school, animal, placePuzzle }

class BuildingGameScreen extends StatefulWidget {
  const BuildingGameScreen({Key? key}) : super(key: key);

  @override
  State<BuildingGameScreen> createState() => _BuildingGameScreenState();
}

class _BuildingGameScreenState extends State<BuildingGameScreen>
    with TickerProviderStateMixin {
  BuildingType _selectedType = BuildingType.house;
  int _currentBlockIndex = 0;
  final int _totalBlocks = 8;
  int _turnIndex = 0; // 0: You, 1: Ahmed, 2: Mona, 3: Sara
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _isThinking = false;

  late FlutterTts _tts;
  bool _ttsReady = false;

  final Map<BuildingType, Map<String, dynamic>> _buildingData = {
    BuildingType.house: {
      'name': 'منزل',
      'icon': '🏠',
      'parts': [
        {'name': 'الأساس'},
        {'name': 'الجدران'},
        {'name': 'الباب'},
        {'name': 'النافذة'},
        {'name': 'السقف'},
        {'name': 'المدخنة'},
        {'name': 'شجرة'},
        {'name': 'الشمس'}
      ],
    },
    BuildingType.mosque: {
      'name': 'مسجد',
      'icon': '🕌',
      'parts': [
        {'name': 'الأساس'},
        {'name': 'الجدران'},
        {'name': 'المحراب'},
        {'name': 'النافذة'},
        {'name': 'المئذنة'},
        {'name': 'قمة المئذنة'},
        {'name': 'القبة'},
        {'name': 'الهلال'}
      ],
    },
    BuildingType.tower: {
      'name': 'برج',
      'icon': '🏢',
      'parts': [
        {'name': 'الأساس'},
        {'name': 'المدخل'},
        {'name': 'طابق 1'},
        {'name': 'طابق 2'},
        {'name': 'طابق 3'},
        {'name': 'طابق 4'},
        {'name': 'المطعم'},
        {'name': 'القمة'}
      ],
    },
    BuildingType.school: {
      'name': 'مدرسة',
      'icon': '🏫',
      'parts': [
        {'name': 'الأساس'},
        {'name': 'الجدران'},
        {'name': 'البوابة'},
        {'name': 'الفصول'},
        {'name': 'الساعة'},
        {'name': 'سارية العلم'},
        {'name': 'العلم'},
        {'name': 'الرمز'}
      ],
    },
    BuildingType.animal: {
      'name': 'بازل الأسد',
      'icon': '🦁',
      'parts': [
        {'name': 'الجسم'},
        {'name': 'الرجل الخلفية'},
        {'name': 'الرجل الأمامية'},
        {'name': 'الذيل'},
        {'name': 'الرقبة'},
        {'name': 'شعر الأسد'},
        {'name': 'الوجه'},
        {'name': 'الأذنين'}
      ],
    },
    BuildingType.placePuzzle: {
      'name': 'بازل الأماكن',
      'icon': '🗺️',
      'parts': [],
    },
  };

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('ar-SA').catchError((e) => _tts.setLanguage('ar'));
    await _tts.setSpeechRate(0.5);
    _ttsReady = true;
  }

  String _getBuildingName(BuildingType type) => _buildingData[type]!['name'];

  void _startGame(BuildingType type) {
    setState(() {
      _selectedType = type;
      _gameStarted = true;
      _currentBlockIndex = 0;
      _turnIndex = 0;
      _gameOver = false;
      _isThinking = false;
    });
    _speak(
        'يا بطل، يالا نبني ${_getBuildingName(type)} مع بعض! دورك حط أول قطعة.');
  }

  Future<void> _speak(String text) async {
    if (_ttsReady) {
      await _tts.stop();
      await _tts.speak(text);
    }
  }

  void _placeBlock() {
    if (_gameOver || _turnIndex != 0 || _isThinking) return;
    HapticFeedback.mediumImpact();
    setState(() => _currentBlockIndex++);

    String partName =
        _buildingData[_selectedType]!['parts'][_currentBlockIndex - 1]['name'];

    if (_currentBlockIndex >= _totalBlocks) {
      _finishGame();
    } else {
      setState(() => _turnIndex = 1);
      _speak('حطيت $partName! حلو جداً، دلوقتي دور صديقك أحمد.');
      _scheduleAITurn();
    }
  }

  void _scheduleAITurn() {
    if (_turnIndex == 0 || _gameOver) return;
    setState(() => _isThinking = true);
    Timer(const Duration(seconds: 2), () {
      if (mounted && _currentBlockIndex < _totalBlocks) {
        setState(() {
          _currentBlockIndex++;
          _isThinking = false;
          _turnIndex = 0; // Back to User
        });
        HapticFeedback.lightImpact();
        String partName = _buildingData[_selectedType]!['parts']
            [_currentBlockIndex - 1]['name'];
        if (_currentBlockIndex >= _totalBlocks) {
          _finishGame();
        } else {
          _speak('صديقك وضع $partName، دلوقتي دورك يا بطل!');
        }
      }
    });
  }

  void _finishGame() {
    setState(() => _gameOver = true);
    _speak(
        'ما شاء الله! بنينا ${_getBuildingName(_selectedType)} مذهل جداً! برافو يا أبطال.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gameStarted
                ? [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)]
                : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (_gameStarted && !_gameOver) _buildEnvironment(),
              Column(
                children: [
                  _buildHeader(),
                  if (_gameStarted) _buildPlayersTopBar(),
                  Expanded(
                    child: Center(
                      child: _gameStarted
                          ? _buildGameArea()
                          : _buildTypeSelection(),
                    ),
                  ),
                  if (_gameStarted && !_gameOver) _buildActionArea(),
                ],
              ),
              if (_gameOver) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironment() {
    return Stack(
      children: [
        if (_currentBlockIndex >= 8)
          Positioned(
              top: 40,
              right: 40,
              child:
                  const Icon(Icons.wb_sunny, color: Colors.yellow, size: 60)),
        if (_currentBlockIndex >= 7)
          Positioned(bottom: 120, left: 30, child: _buildTree(60)),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              height: 120,
              decoration: const BoxDecoration(
                  color: Color(0xFF81C784),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)))),
        ),
      ],
    );
  }

  Widget _buildTree(double h) {
    return Column(children: [
      Container(
          width: h,
          height: h,
          decoration: const BoxDecoration(
              color: Color(0xFF2E7D32), shape: BoxShape.circle)),
      Container(width: 10, height: 20, color: Colors.brown)
    ]);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context)),
          Text(
              _gameStarted
                  ? 'بناء ${_getBuildingName(_selectedType)}'
                  : 'ماذا سنبني اليوم؟',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildPlayersTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _playerAvatar('أحمد', '👦', _turnIndex == 1, Colors.blue),
        const SizedBox(width: 20),
        _playerAvatar('أنت', '🧒', _turnIndex == 0, Colors.orange),
      ],
    );
  }

  Widget _playerAvatar(String name, String emoji, bool active, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: active ? color : Colors.transparent, width: 3)),
            child: CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.2),
                child: Text(emoji, style: const TextStyle(fontSize: 25))),
          ),
          Text(name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: BuildingType.values
          .map((type) => GestureDetector(
                onTap: () {
                  if (type == BuildingType.animal) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CooperativeJigsawScreen(
                      title: 'الحيوانات',
                      images: [
                        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600', // Cat
                        'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=600', // Lion
                        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=600', // Dog
                        'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=600', // Rabbit
                        'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=600', // Elephant
                        'https://images.unsplash.com/photo-1547721064-3625203532f0?w=600', // Giraffe
                        'https://images.unsplash.com/photo-1549480017-d76466a4b7e8?w=600', // Tiger (Fixed)
                        'https://images.unsplash.com/photo-1501705388883-4ed8a543392c?w=600', // Zebra
                        'https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?w=600', // Monkey
                      ],
                    )));
                  } else if (type == BuildingType.placePuzzle) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CooperativeJigsawScreen(
                      title: 'الأماكن',
                      images: [
                        'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=600', // Mosque
                        'https://images.unsplash.com/photo-1541339907198-e08756ebafe3?w=600', // School
                        'https://images.unsplash.com/photo-1586773860418-d319a39ca41d?w=600', // Hospital
                        'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=600', // House
                        'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?w=600', // Pharmacy
                        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600', // Supermarket
                        'https://images.unsplash.com/photo-1520110120385-c285d6b23b2d?w=600', // Playground
                      ],
                    )));
                  } else {
                    _startGame(type);
                  }
                },
                child: _styledBox(Colors.white,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_buildingData[type]!['icon'],
                              style: const TextStyle(fontSize: 50)),
                          const SizedBox(height: 10),
                          Text(_buildingData[type]!['name'],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ])),
              ))
          .toList(),
    );
  }

  Widget _buildGameArea() {
    return Stack(alignment: Alignment.bottomCenter, children: [
      SizedBox(
          width: 300,
          height: 400,
          child: Stack(
              alignment: Alignment.bottomCenter,
              children: List.generate(
                  _currentBlockIndex, (index) => _buildPart(index)))),
    ]);
  }

  Widget _buildPart(int index) {
    double? b, l, r, w, h;
    Widget child;
    switch (_selectedType) {
      case BuildingType.mosque:
        var res = _getMosqueData(index);
        b = res.b;
        l = res.l;
        r = res.r;
        w = res.w;
        h = res.h;
        child = res.child;
        break;
      case BuildingType.tower:
        var res = _getTowerData(index);
        b = res.b;
        l = res.l;
        r = res.r;
        w = res.w;
        h = res.h;
        child = res.child;
        break;
      case BuildingType.school:
        var res = _getSchoolData(index);
        b = res.b;
        l = res.l;
        r = res.r;
        w = res.w;
        h = res.h;
        child = res.child;
        break;
      case BuildingType.animal:
        var res = _getAnimalData(index);
        b = res.b;
        l = res.l;
        r = res.r;
        w = res.w;
        h = res.h;
        child = res.child;
        break;
      default:
        var res = _getHouseData(index);
        b = res.b;
        l = res.l;
        r = res.r;
        w = res.w;
        h = res.h;
        child = res.child;
    }
    return Positioned(
      bottom: b,
      left: l ?? (l == null && r == null ? 0 : null),
      right: r ?? (l == null && r == null ? 0 : null),
      child: l == null && r == null
          ? Center(
              child: SizedBox(
                  width: w, height: h, child: _animatePart(index, child)))
          : SizedBox(width: w, height: h, child: _animatePart(index, child)),
    );
  }

  Widget _animatePart(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('part_${_selectedType}_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (c, v, ch) => Opacity(opacity: v, child: ch),
      child: child,
    );
  }

  _PartData _getHouseData(int i) {
    switch (i) {
      case 0:
        return _PartData(
            b: 10, w: 230, h: 25, child: _styledBox(const Color(0xFF5D4037)));
      case 1:
        return _PartData(
            b: 33,
            w: 210,
            h: 145,
            child: _styledBox(const Color(0xFFFFF9C4),
                border: true,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                        2,
                        (i) => Icon(Icons.window,
                            color: Colors.blue[100]!.withOpacity(0.5),
                            size: 40)))));
      case 2:
        return _PartData(
            b: 33,
            w: 60,
            h: 90,
            child: _styledBox(const Color(0xFF3E2723),
                radiusFull: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.circle,
                            color: Colors.amber, size: 10)))));
      case 3:
        return _PartData(
            b: 105,
            l: 180,
            w: 55,
            h: 55,
            child: _styledBox(const Color(0xFFE3F2FD),
                border: true, child: _windowGrid()));
      case 4:
        return _PartData(
            b: 173,
            w: 240,
            h: 110,
            child: CustomPaint(
                painter: _TrianglePainter(const Color(0xFFBF360C))));
      case 5:
        return _PartData(
            b: 240,
            r: 185,
            w: 30,
            h: 70,
            child: _styledBox(const Color(0xFF455A64), border: true));
      case 6:
        return _PartData(b: 33, l: 25, w: 60, h: 80, child: _buildTree(50));
      case 7:
        return _PartData(
            b: 280,
            l: 30,
            w: 50,
            h: 50,
            child: const Icon(Icons.wb_sunny,
                color: Colors.orangeAccent, size: 55));
      default:
        return _PartData(b: 0, w: 0, h: 0, child: const SizedBox.shrink());
    }
  }

  _PartData _getMosqueData(int i) {
    switch (i) {
      case 0:
        return _PartData(
            b: 10, w: 260, h: 25, child: _styledBox(const Color(0xFF616161)));
      case 1:
        return _PartData(
            b: 33,
            w: 220,
            h: 145,
            child: _styledBox(const Color(0xFFF1F8E9),
                border: true,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.green, size: 15),
                      SizedBox(width: 40),
                      Icon(Icons.star, color: Colors.green, size: 15)
                    ])));
      case 2:
        return _PartData(
            b: 33,
            w: 75,
            h: 95,
            child: _styledBox(const Color(0xFF1B5E20),
                radiusFull: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
                border: true,
                child: const Icon(Icons.door_front_door,
                    color: Colors.amber, size: 30)));
      case 3:
        return _PartData(
            b: 105,
            l: 175,
            w: 45,
            h: 60,
            child: _styledBox(const Color(0xFFFFF8E1),
                radiusFull: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                border: true,
                child:
                    const Icon(Icons.window, color: Colors.green, size: 20)));
      case 4:
        return _PartData(
            b: 33,
            r: 25,
            w: 40,
            h: 230,
            child: _styledBox(const Color(0xFF2E7D32), border: true));
      case 5:
        return _PartData(
            b: 260,
            r: 20,
            w: 50,
            h: 40,
            child: _styledBox(const Color(0xFFFFD54F),
                radius: 10, child: const Icon(Icons.balcony, size: 20)));
      case 6:
        return _PartData(
            b: 173,
            w: 170,
            h: 100,
            child: _styledBox(const Color(0xFFFFC107),
                radiusFull: const BorderRadius.only(
                    topLeft: Radius.circular(85),
                    topRight: Radius.circular(85)),
                border: true));
      case 7:
        return _PartData(
            b: 270,
            w: 45,
            h: 45,
            child: const Icon(Icons.brightness_3,
                color: Color(0xFFFFC107), size: 45));
      default:
        return _PartData(b: 0, w: 0, h: 0, child: const SizedBox.shrink());
    }
  }

  _PartData _getTowerData(int i) {
    if (i == 0)
      return _PartData(
          b: 10, w: 220, h: 25, child: _styledBox(const Color(0xFF263238)));
    double h = 55;
    if (i < 7) {
      return _PartData(
          b: 33 + (i - 1) * h,
          w: 150,
          h: h + 2,
          child: _styledBox(const Color(0xFF039BE5),
              border: true,
              child: Stack(children: [
                const Center(
                    child: Opacity(
                        opacity: 0.2,
                        child: Icon(Icons.grid_on,
                            size: 30, color: Colors.white))),
                Positioned(
                    top: 10,
                    left: 20,
                    child: Transform.rotate(
                        angle: -0.5,
                        child: Container(
                            width: 80,
                            height: 4,
                            color: Colors.white.withOpacity(0.3)))),
              ])));
    }
    return _PartData(
        b: 33 + 6 * h,
        w: 40,
        h: 100,
        child: Column(children: [
          Container(width: 6, height: 80, color: Colors.grey[400]),
          const Icon(Icons.circle, color: Colors.red, size: 15)
        ]));
  }

  _PartData _getSchoolData(int i) {
    switch (i) {
      case 0:
        return _PartData(
            b: 10, w: 290, h: 25, child: _styledBox(const Color(0xFF455A64)));
      case 1:
        return _PartData(
            b: 35,
            w: 260,
            h: 130,
            child: _styledBox(const Color(0xFFFFFDE7),
                border: true,
                child: const Center(
                    child: Text('مدرسة',
                        style: TextStyle(
                            color: Colors.brown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))))); // Signboard
      case 2:
        return _PartData(
            b: 35,
            w: 90,
            h: 95,
            child: _styledBox(const Color(0xFFD32F2F),
                radiusFull: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                child: const Icon(Icons.door_back_door,
                    color: Colors.white54, size: 40))); // Gate
      case 3:
        return _PartData(
            b: 165,
            w: 200,
            h: 85,
            child: _styledBox(const Color(0xFFFFF9C4),
                border: true,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                        4,
                        (i) => Icon(Icons.window,
                            color: Colors.blue[300], size: 28)))));
      case 4:
        return _PartData(
            b: 250,
            l: 140,
            w: 80,
            h: 80,
            child: _styledBox(Colors.white,
                radius: 40,
                border: true,
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.circle_outlined,
                      size: 70, color: Colors.black),
                  Container(
                      width: 2,
                      height: 30,
                      color: Colors.black,
                      margin: const EdgeInsets.only(bottom: 30)),
                  Container(
                      width: 20,
                      height: 2,
                      color: Colors.black,
                      margin: const EdgeInsets.only(left: 20))
                ]))); // Real Clock
      case 5:
        return _PartData(
            b: 165,
            r: 40,
            w: 12,
            h: 180,
            child: _styledBox(Colors.blueGrey[600]!)); // Flag pole
      case 6:
        return _PartData(
            b: 310,
            r: 40,
            w: 60,
            h: 40,
            child: _styledBox(const Color(0xFFC62828),
                radiusFull: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: const Icon(Icons.flag,
                    color: Colors.white, size: 25))); // Waving Flag
      case 7:
        return _PartData(
            b: 175,
            l: 50,
            w: 65,
            h: 65,
            child: const Icon(Icons.school_rounded,
                color: Colors.indigo, size: 60)); // Iconic symbol
      default:
        return _PartData(b: 0, w: 0, h: 0, child: const SizedBox.shrink());
    }
  }

  _PartData _getAnimalData(int i) {
    switch (i) {
      case 0: return _PartData(b: 100, w: 150, h: 100, child: _styledBox(Colors.orange[700]!, radius: 50)); // Body
      case 1: return _PartData(b: 70, l: 60, w: 40, h: 60, child: _styledBox(Colors.orange[800]!, radius: 20)); // Back Leg
      case 2: return _PartData(b: 70, r: 60, w: 40, h: 60, child: _styledBox(Colors.orange[800]!, radius: 20)); // Front Leg
      case 3: return _PartData(b: 150, l: 30, w: 60, h: 15, child: _styledBox(Colors.orange[900]!, radius: 10)); // Tail
      case 4: return _PartData(b: 160, r: 60, w: 60, h: 60, child: _styledBox(Colors.orange[600]!, radius: 30)); // Neck
      case 5: return _PartData(b: 180, r: 40, w: 120, h: 120, child: _styledBox(Colors.brown[800]!, radius: 60)); // Mane (Hair)
      case 6: return _PartData(b: 200, r: 60, w: 80, h: 80, child: _styledBox(Colors.orange[400]!, radius: 40, child: const Icon(Icons.face, size: 40, color: Colors.black))); // Face
      case 7: return _PartData(b: 260, r: 70, w: 60, h: 30, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icon(Icons.circle, color: Colors.orange[300], size: 20), Icon(Icons.circle, color: Colors.orange[300], size: 20)])); // Ears
      default: return _PartData(b: 0, w: 0, h: 0, child: const SizedBox.shrink());
    }
  }

  Widget _windowGrid() {
    return Stack(
      children: [
        Row(children: [
          const Spacer(),
          Container(width: 2, color: Colors.black12),
          const Spacer()
        ]),
        Column(children: [
          const Spacer(),
          Container(height: 2, color: Colors.black12),
          const Spacer()
        ]),
      ],
    );
  }

  Widget _styledBox(Color c,
      {bool border = false,
      double radius = 10,
      BorderRadius? radiusFull,
      Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        color: c,
        borderRadius: radiusFull ?? BorderRadius.circular(radius),
        border: border
            ? Border.all(color: Colors.black.withOpacity(0.1), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionArea() {
    bool mine = _turnIndex == 0;
    return Padding(
      padding: const EdgeInsets.all(25),
      child: GestureDetector(
        onTap: mine ? _placeBlock : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
              color: mine ? const Color(0xFF1976D2) : Colors.grey,
              borderRadius: BorderRadius.circular(20),
              boxShadow: mine
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ]
                  : []),
          child: Center(
              child: Text(mine ? 'ضع الجزء القادم 🧱' : 'انتظر دور صديقك...',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎊 برافو 🎊',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C))),
                const SizedBox(height: 20),
                Text('بنينا ${_getBuildingName(_selectedType)} رائع!',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _gameStarted = false;
                      _gameOver = false;
                      _currentBlockIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text('العب مرة تانية',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartData {
  final double b;
  final double? l;
  final double? r;
  final double w;
  final double h;
  final Widget child;
  _PartData(
      {required this.b,
      this.l,
      this.r,
      required this.w,
      required this.h,
      required this.child});
}

class _TrianglePainter extends CustomPainter {
  final Color c;
  _TrianglePainter(this.c);
  @override
  void paint(Canvas canvas, Size size) {
    var p = Path();
    p.moveTo(0, size.height);
    p.lineTo(size.width / 2, 0);
    p.lineTo(size.width, size.height);
    p.close();
    canvas.drawPath(p, Paint()..color = c);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
