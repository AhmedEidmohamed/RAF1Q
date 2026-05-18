import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

class CollaborativePaintingScreen extends StatefulWidget {
  const CollaborativePaintingScreen({Key? key}) : super(key: key);

  @override
  State<CollaborativePaintingScreen> createState() => _CollaborativePaintingScreenState();
}

class _CollaborativePaintingScreenState extends State<CollaborativePaintingScreen> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawingPoint?> _points = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 5.0;
  int _currentImageIndex = 0;
  bool _isAhmedDrawing = false;

  final List<String> _outlineImages = [
    'https://cdn-icons-png.flaticon.com/512/375/375125.png', // Butterfly
    'https://cdn-icons-png.flaticon.com/512/619/619153.png', // House
    'https://cdn-icons-png.flaticon.com/512/2613/2613143.png', // Lion
    'https://cdn-icons-png.flaticon.com/512/744/744465.png', // Car
    'https://cdn-icons-png.flaticon.com/512/2970/2970104.png', // Fish
    'https://cdn-icons-png.flaticon.com/512/489/489969.png', // Tree
    'https://cdn-icons-png.flaticon.com/512/869/869869.png', // Sun
    'https://cdn-icons-png.flaticon.com/512/415/415733.png', // Apple
    'https://cdn-icons-png.flaticon.com/512/616/616430.png', // Cat
    'https://cdn-icons-png.flaticon.com/512/1067/1067357.png', // Rocket
  ];

  final List<Color> _palette = [
    Colors.red, Colors.blue, Colors.green, Colors.yellow, 
    Colors.orange, Colors.purple, Colors.pink, Colors.black
  ];

  void _startAhmedDrawing() {
    if (_isAhmedDrawing) return;
    setState(() => _isAhmedDrawing = true);
    
    // Ahmed draws a circle or some lines
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (timer.tick > 20 || !mounted) {
        timer.cancel();
        setState(() {
          _points.add(null); // End Ahmed's path
          _isAhmedDrawing = false;
        });
        return;
      }
      
      setState(() {
        double x = 150 + (timer.tick * 5.0);
        double y = 150 + (timer.tick * 2.0);
        _points.add(DrawingPoint(
          offset: Offset(x, y),
          paint: Paint()
            ..color = Colors.blueAccent
            ..strokeCap = StrokeCap.round
            ..strokeWidth = _strokeWidth,
        ));
      });
    });
  }

  void _saveCanvas() {
    // In a real app, we would use RenderRepaintBoundary to save to file.
    // Here we simulate the process with a beautiful feedback.
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Center(child: Text('📸 تم الحفظ! 📸', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        content: const Text('لقد قام أحمد بحفظ لوحتك الجميلة في معرض الصور بنجاح!', textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('رائع!', style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('نشخبط ونلون معاً 🎨'),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.blue),
            onPressed: _saveCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => setState(() => _points.clear()),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next, color: Colors.green),
            onPressed: () => setState(() {
              _currentImageIndex = (_currentImageIndex + 1) % _outlineImages.length;
              _points.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background Outline Image
                Center(
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.network(
                      _outlineImages[_currentImageIndex],
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Drawing Canvas
                RepaintBoundary(
                  key: _globalKey,
                  child: GestureDetector(
                    onPanStart: (details) {
                    setState(() {
                      _points.add(DrawingPoint(
                        offset: details.localPosition,
                        paint: Paint()
                          ..color = _selectedColor
                          ..strokeCap = StrokeCap.round
                          ..strokeWidth = _strokeWidth,
                      ));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _points.add(DrawingPoint(
                        offset: details.localPosition,
                        paint: Paint()
                          ..color = _selectedColor
                          ..strokeCap = StrokeCap.round
                          ..strokeWidth = _strokeWidth,
                      ));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() => _points.add(null));
                    // When child stops, Ahmed might start
                    if (_points.length % 50 == 0) _startAhmedDrawing();
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(pointsList: _points),
                    size: Size.infinite,
                  ),
                ),
                ),
                
                if (_isAhmedDrawing)
                  Positioned(
                    top: 20, right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                      child: const Text('👦 أحمد يشخبط معك!'),
                    ),
                  ),
              ],
            ),
          ),
          _buildPalette(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _palette.length,
        itemBuilder: (context, i) {
          bool isSelected = _selectedColor == _palette[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = _palette[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              decoration: BoxDecoration(
                color: _palette[i],
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  List<DrawingPoint?> pointsList;
  DrawingPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.offset, pointsList[i + 1]!.offset, pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [pointsList[i]!.offset], pointsList[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
