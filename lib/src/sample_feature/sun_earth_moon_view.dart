import 'dart:math';

import 'package:dash_painter/dash_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SunEarthMoonView extends StatefulWidget {
  const SunEarthMoonView({Key? key}) : super(key: key);

  static const routeName = '/sun_earth_moon';

  @override
  State<SunEarthMoonView> createState() => _SunEarthMoonViewState();
}

class _SunEarthMoonViewState extends State<SunEarthMoonView>
    with SingleTickerProviderStateMixin {
  Line line = Line(
      start: const Offset(0, 0),
      end: const Offset(80, 80),
      third: const Offset(60, 60));

  late AnimationController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..addListener(_updateLine);
  }

  @override
  void dispose() {
    line.dispose();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // line.start = Offset.zero;
    // line.end = Offset(40, 0);
    // line.rotate(2.4085543677521746);

    return Scaffold(
        body: Center(
      child: GestureDetector(
        onTap: () {
          // line.record();
          ctrl.forward(from: 0);
        },
        child: CustomPaint(
          foregroundPainter: AnglePainter(line: line // linker: linker
              ),
          child: Container(
            color: const Color(0xff2f3141),
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    ));
  }

  void _updateLine() {
    // print("${ctrl.value * 2 * pi}");
    line.rotate(ctrl.value * 2 * pi, ctrl.value * 32 * pi, ctrl.value * 2 * pi,
        ctrl.value * 32 * pi);
  }
}

class AnglePainter extends CustomPainter {
  // 绘制虚线
  final DashPainter dashPainter = const DashPainter(span: 4, step: 4);

  AnglePainter({required this.line}) : super(repaint: line);

  final Paint helpPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.lightBlue
    ..strokeWidth = 1;

  final TextPainter textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  final Line line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    // drawHelp(canvas, size);
    line.paint(canvas);
  }

  void drawHelp(Canvas canvas, Size size) {
    Path helpPath = Path()
      ..moveTo(-size.width / 2, 0)
      ..relativeLineTo(size.width, 0)
      ..moveTo(0, -size.height / 2)
      ..relativeLineTo(0, size.height);
    dashPainter.paint(canvas, helpPath, helpPaint);

    drawHelpText('0°', canvas, Offset(size.width / 2 - 20, 0));
    drawHelpText('p0', canvas, line.start.translate(-20, 0));
    drawHelpText('p1', canvas, line.end.translate(-20, 0));

    drawHelpText(
      '角度: ${(line.rad * 180 / pi).toStringAsFixed(2)}°',
      canvas,
      Offset(
        -size.width / 2 + 10,
        -size.height / 2 + 10,
      ),
    );

    canvas.drawArc(
      Rect.fromCenter(center: line.start, width: 20, height: 20),
      0,
      line.positiveRad,
      false,
      helpPaint,
    );

    // canvas.save();
    // Offset center = const Offset(60, 60);
    // canvas.translate(center.dx, center.dy);
    // canvas.rotate(line.positiveRad);
    // canvas.translate(-center.dx, -center.dy);
    // canvas.drawCircle(center, 4, helpPaint);
    // canvas.drawRect(
    //     Rect.fromCenter(center: center, width: 30, height: 60), helpPaint);
    // canvas.restore();
  }

  void drawHelpText(
    String text,
    Canvas canvas,
    Offset offset, {
    Color color = Colors.lightBlue,
  }) {
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(fontSize: 12, color: color),
    );
    textPainter.layout(maxWidth: 200);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Line extends ChangeNotifier {
  Line({
    this.start = Offset.zero,
    this.end = Offset.zero,
    this.third = Offset.zero,
  });

  Offset start;
  Offset end;
  Offset third;

  double get rad => (end - start).direction;

  double get radTwo => (third - end).direction;

  double get positiveRad => rad < 0 ? 2 * pi + rad : rad;

  double get positiveRadTwo => radTwo < 0 ? 2 * pi + radTwo : radTwo;

  double get length => (end - start).distance;

  double get lengthTwo => (third - end).distance;

  final Paint pointPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  void paint(Canvas canvas) {
    // canvas.drawLine(start, end, pointPaint);
    // drawAnchor(canvas, start);
    // drawAnchor(canvas, end);
    // drawAnchor(canvas, third);

    List<Color> colorsStart = [
      const Color(0xfffcd670),
      const Color(0xfff2784b),
    ];
    List<Color> colorsEnd = [
      const Color(0xff19b5fe),
      const Color(0xff7befb2),
    ];
    List<Color> colorsThird = [
      const Color(0xff8d6e63),
      const Color(0xffffe0b2),
    ];

    drawAnchorTwo(canvas, start, 30, colorsStart);
    drawAnchorTwo(canvas, end, 8, colorsEnd);
    drawAnchorTwo(canvas, third, 5, colorsThird);

    // canvas.drawCircle(start, length, pointPaint..style = PaintingStyle.stroke);
    // canvas.drawCircle(end, lengthTwo, pointPaint..style = PaintingStyle.stroke);

    canvas.drawArc(
        Rect.fromCircle(center: start, radius: length),
        detaRotateThree,
        detaRotateFour,
        false,
        pointPaint..style = PaintingStyle.stroke);
    // canvas.drawArc(Rect.fromCircle(center: end, radius: lengthTwo), 0.5,
    //     detaRotateFour, false, pointPaint..style = PaintingStyle.stroke);
  }

  void drawAnchor(Canvas canvas, Offset offset) {
    canvas.drawCircle(offset, 4, pointPaint..style = PaintingStyle.stroke);
    canvas.drawCircle(offset, 2, pointPaint..style = PaintingStyle.fill);
  }

  void drawAnchorTwo(
      Canvas canvas, Offset offset, double radius, List<Color> colors) {
    var rect = Rect.fromLTWH(radius, radius, radius, radius);
    var gradient = SweepGradient(colors: colors, tileMode: TileMode.decal);

    canvas.drawCircle(
        offset,
        radius,
        pointPaint
          ..style = PaintingStyle.fill
          ..shader = gradient.createShader(rect));
  }

  double detaRotate = 0;
  double detaRotateTwo = 0;
  double detaRotateThree = 0;
  double detaRotateFour = 0;

  void rotate(
      double rotate, double rotateTwo, double rotateThree, double rotateFour) {
    double _lengthTwo = lengthTwo;

    detaRotate = rotate - detaRotate;
    end = Offset(
          length * cos(rad + detaRotate),
          length * sin(rad + detaRotate),
        ) +
        start;
    detaRotate = rotate;

    detaRotateTwo = rotateTwo - detaRotateTwo;
    third = Offset(
          _lengthTwo * cos(radTwo + detaRotateTwo),
          _lengthTwo * sin(radTwo + detaRotateTwo),
        ) +
        end;
    detaRotateTwo = rotateTwo;

    detaRotateThree = rad - rotate;
    detaRotateFour = rotate;

    notifyListeners();
  }

  void tick() {
    notifyListeners();
  }
}
