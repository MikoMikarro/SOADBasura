import 'dart:math';
import 'dart:ui' as ui;

import 'package:buildgreen/screens/mapa_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:glitcheffect/glitcheffect.dart';

/// Widget that paints an animated neon-light horizon.
class NeonHorizon extends StatefulWidget {
  const NeonHorizon({
    Key? key,
    required this.color,
    this.animate = true,
  }) : super(key: key);

  /// The color of the neon lines and highlights.
  final Color color;

  /// Whether to animate the horizon lines.
  final bool animate;

  @override
  _NeonHorizonState createState() => _NeonHorizonState();
}

class _NeonHorizonState extends State<NeonHorizon> with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  double _distancePercent = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);

    if (widget.animate) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(NeonHorizon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.animate && oldWidget.animate) {
      _ticker.stop();
    } else if (widget.animate && !oldWidget.animate) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsedTime) {
    setState(() {
      _distancePercent = (elapsedTime.inMilliseconds / const Duration(seconds: 3).inMilliseconds) % 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,

        children:[
            ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  Colors.black.withOpacity(1),
                  Colors.white.withOpacity(1),
                  Colors.deepPurple.withOpacity(1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0.1,
                  0.4,
                  1.0,
                ],
              ).createShader(rect);
            },
            child: CustomPaint(
              painter: _NeonHorizonPainter(
                distancePercent: _distancePercent,
                lineColor: widget.color,
              ),
              child:Container(),
              
          ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(),
              GlithEffect(
                child: Container(
                  padding: EdgeInsets.all(25),
                  width: MediaQuery.of(context).size.width ,
                  child: Image.asset('assets/images/logo.png'),
                ),
                duration: Duration(seconds: 1),
              ),
              Container(
                padding: EdgeInsets.all(50),
                child: ElevatedButton(
                  

                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const MapaScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellowAccent,
                    side: BorderSide(color: Color.fromARGB(255, 60, 33, 105), width: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Container(
                      padding: EdgeInsets.fromLTRB(0,0,0,40),
                      child: const Text("START",style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'Mustasurma',
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),),
                    ),
                    ]
                  )),
              )
            ],
          )
          
        ]
      ),
    );
  }
}

/// Paints a neon-line horizon.
class _NeonHorizonPainter extends CustomPainter {
  _NeonHorizonPainter({
    required this.distancePercent,
    required Color lineColor,
  })  : _backgroundPaint = Paint() .. color = Colors.black,
        _linePaint = Paint()
          ..color = Colors.pinkAccent
          ..strokeWidth = 4;

  /// Distance traveled across the plane, with 100% meaning
  /// that a horizontal line at the nearest edge of the plane
  /// has traveled to the farthest edge of the plane.
  final double distancePercent;

  final Paint _backgroundPaint;
  final Paint _linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);

    final centerX = size.width / 2;
    const spacing = 45.0;
    double deltaX = spacing;

    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), _linePaint);
    while (centerX - deltaX >= 0) {
      canvas.drawLine(Offset(centerX - deltaX, 0), Offset(centerX - (2.5 * deltaX), size.height), _linePaint);
      canvas.drawLine(Offset(centerX + deltaX, 0), Offset(centerX + (2.5 * deltaX), size.height), _linePaint);

      deltaX += spacing;
    }

    // Draw the horizontal reference line. Later, we'll fill in
    // additional lines above this reference line, to fill
    // in all visible space.
    const dt = 0.1;
    double t = distancePercent % dt;
    final firstLineY = _horizontalLineAtTime(size, t);
    canvas.drawLine(Offset(0, firstLineY), Offset(size.width, firstLineY), _linePaint);

    // Draw lines above the reference line.
    t = t + dt;
    while (_horizontalLineAtTime(size, t) > 0) {
      final y = _horizontalLineAtTime(size, t);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _linePaint);
      t += dt;
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    _backgroundPaint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.height),
      [
        Color.fromARGB(255, 35, 19, 61).withOpacity(1.0),
        Color.fromARGB(255, 35, 19, 61).withOpacity(1.0),
      ],
    );

    canvas.drawRect(Offset.zero & size, _backgroundPaint);
  }

  double _horizontalLineAtTime(Size size, double t) {
    // Evolution of math:
    t = t.clamp(0.0, 1.0);
    // return size.height * (1 - t);
    final distancePercent = sin(t * pi / 2);
    return size.height * (1 - distancePercent);
  }

  @override
  bool shouldRepaint(_NeonHorizonPainter oldDelegate) {
    return distancePercent != oldDelegate.distancePercent;
  }
}
