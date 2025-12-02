import 'package:flutter/material.dart';
import 'dart:async';

class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const SosButton({Key? key, required this.onPressed, required this.color}) : super(key: key);

  @override
  _SosButtonState createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 800), (_) {
      setState(() => _scale = _scale == 1.0 ? 1.2 : 1.0);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scale,
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        backgroundColor: widget.color,
        child: Icon(Icons.warning, color: Colors.white),
      ),
    );
  }
}
