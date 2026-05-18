import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimalJigsawScreen extends StatefulWidget {
  const AnimalJigsawScreen({Key? key}) : super(key: key);

  @override
  State<AnimalJigsawScreen> createState() => _AnimalJigsawScreenState();
}

class _AnimalJigsawScreenState extends State<AnimalJigsawScreen> {
  final List<String> _animalImages = [
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600', // Cat
    'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=600', // Lion
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=600', // Dog
    'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=600', // Rabbit
  ];
  
  late String _imageUrl;
  final List<bool> _placedPieces = [false, false, false, false];
  
  // Position of pieces on the 2x2 grid
  final List<Offset> _targetPositions = [
    const Offset(60, 100),  // Top Left
    const Offset(160, 100), // Top Right
    const Offset(60, 200),  // Bottom Left
    const Offset(160, 200), // Bottom Right
  ];

  @override
  void initState() {
    super.initState();
    _imageUrl = (_animalImages..shuffle()).first;
  }

  void _onPiecePlaced(int index) {
    if (_placedPieces[index]) return;
    setState(() => _placedPieces[index] = true);
    HapticFeedback.heavyImpact();
    
    if (_placedPieces.every((p) => p)) {
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        title: const Column(
          children: [
            Text('🎊 ممتاز 🎊', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
            SizedBox(height: 10),
            Icon(Icons.pets, size: 50, color: Colors.pinkAccent),
          ],
        ),
        content: const Text('لقد رتبت صورة القطة اللطيفة بنجاح!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _placedPieces.fillRange(0, 4, false);
                  _imageUrl = (_animalImages..shuffle()).first;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('العب مرة ثانية', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81D4FA), Color(0xFFE1F5FE), Color(0xFFC8E6C9)], // Sky to Grass
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Container(
                    width: 320,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                    ),
                    child: Stack(
                      children: [
                        // Guide Background (Faded image)
                        Opacity(
                          opacity: 0.2,
                          child: Center(child: Icon(Icons.pets, size: 200, color: Colors.pink[100])),
                        ),
                        
                        // Drop Targets
                        ...List.generate(4, (i) => _buildTargetSlot(i)),
                      ],
                    ),
                  ),
                ),
              ),
              _buildTray(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const Expanded(
            child: Center(
              child: Text('رتب صورة القطة 🐱', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 5)])),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTargetSlot(int index) {
    Offset pos = _targetPositions[index];
    bool isPlaced = _placedPieces[index];
    
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: DragTarget<int>(
        onWillAccept: (data) => data == index,
        onAccept: (data) => _onPiecePlaced(data),
        builder: (context, candidate, rejected) {
          return Opacity(
            opacity: isPlaced ? 1.0 : 0.2,
            child: _PuzzlePiece(
              index: index,
              imageUrl: _imageUrl,
              isGray: !isPlaced,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTray() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) {
          if (_placedPieces[i]) return const SizedBox(width: 80);
          return Draggable<int>(
            data: i,
            feedback: _PuzzlePiece(index: i, imageUrl: _imageUrl, scale: 1.1),
            childWhenDragging: Opacity(opacity: 0.2, child: _PuzzlePiece(index: i, imageUrl: _imageUrl)),
            child: _PuzzlePiece(index: i, imageUrl: _imageUrl),
          );
        }),
      ),
    );
  }
}

class _PuzzlePiece extends StatelessWidget {
  final int index;
  final String imageUrl;
  final bool isGray;
  final double scale;

  const _PuzzlePiece({required this.index, required this.imageUrl, this.isGray = false, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        children: [
          // The interlocking shape with the image slice
          ClipPath(
            clipper: _PuzzleClipper(index),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: OverflowBox(
                minWidth: 200,
                maxWidth: 200,
                minHeight: 200,
                maxHeight: 200,
                alignment: _getAlignment(index),
                child: ColorFiltered(
                  colorFilter: isGray 
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Stroke for the interlocking shape
          CustomPaint(
            size: const Size(100, 100),
            painter: _PuzzleStrokePainter(index, isGray ? Colors.white54 : Colors.white),
          ),
        ],
      ),
    );
  }

  Alignment _getAlignment(int i) {
    switch (i) {
      case 0: return Alignment.topLeft;
      case 1: return Alignment.topRight;
      case 2: return Alignment.bottomLeft;
      case 3: return Alignment.bottomRight;
      default: return Alignment.center;
    }
  }
}

class _PuzzleClipper extends CustomClipper<Path> {
  final int index;
  _PuzzleClipper(this.index);

  @override
  Path getClip(Size size) {
    return _getPuzzlePath(index, size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PuzzleStrokePainter extends CustomPainter {
  final int index;
  final Color color;
  _PuzzleStrokePainter(this.index, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(_getPuzzlePath(index, size), paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

Path _getPuzzlePath(int index, Size size) {
  var path = Path();
  double w = size.width;
  double h = size.height;
  double tabSize = 20;

  path.moveTo(0, 0);
  
  // Top side
  if (index == 0 || index == 1) {
     path.lineTo(w, 0);
  } else {
     path.lineTo(w/2 - tabSize, 0);
     path.arcToPoint(Offset(w/2 + tabSize, 0), radius: Radius.circular(tabSize), clockwise: false);
     path.lineTo(w, 0);
  }

  // Right side
  if (index == 1 || index == 3) {
    path.lineTo(w, h);
  } else {
    path.lineTo(w, h/2 - tabSize);
    path.arcToPoint(Offset(w, h/2 + tabSize), radius: Radius.circular(tabSize), clockwise: true);
    path.lineTo(w, h);
  }

  // Bottom side
  if (index == 2 || index == 3) {
    path.lineTo(0, h);
  } else {
    path.lineTo(w/2 + tabSize, h);
    path.arcToPoint(Offset(w/2 - tabSize, h), radius: Radius.circular(tabSize), clockwise: true);
    path.lineTo(0, h);
  }

  // Left side
  if (index == 0 || index == 2) {
    path.lineTo(0, 0);
  } else {
    path.lineTo(0, h/2 + tabSize);
    path.arcToPoint(Offset(0, h/2 - tabSize), radius: Radius.circular(tabSize), clockwise: false);
    path.lineTo(0, 0);
  }
  path.close();
  return path;
}
