import 'dart:async';

import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../widgets/stack_logo.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const _dropDuration = Duration(milliseconds: 1500);
  static const _holdBeforeNavigate = Duration(milliseconds: 550);

  late final AnimationController _controller;
  late final List<Animation<double>> _barDrops;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    AudioService.init().then((_) => AudioService.playSplash());
    _controller = AnimationController(vsync: this, duration: _dropDuration);

    final barCount = StackLogo.bars.length;
    _barDrops = List.generate(barCount, (i) {
      final start = i * 0.16;
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    const titleStart = 0.62;
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(titleStart, 1.0, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(titleStart, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    _navigateTimer = Timer(_dropDuration + _holdBeforeNavigate, () {
      AudioService.stopSplash();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    AudioService.stopSplash();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < StackLogo.bars.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: AnimatedBuilder(
                  animation: _barDrops[i],
                  builder: (context, child) {
                    final t = _barDrops[i].value;
                    return Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * -160),
                        child: child,
                      ),
                    );
                  },
                  child: LogoBar(
                    color: StackLogo.bars[i].$1,
                    width: StackLogo.bars[i].$2 * 1.1,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: const Text(
                  'STACK IT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
