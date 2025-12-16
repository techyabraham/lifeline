// lib/ui/onboarding/onboarding_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _page = 0;
  late AnimationController _pulseController;

  final List<_OnboardSlide> slides = [
    _OnboardSlide(
      title: 'Help when you need it most',
      subtitle:
          'One tap to call — location-aware emergency contacts across Nigeria.',
      icon: Icons.warning_amber_rounded,
      bgStart: Color(0xFF0047AB),
      bgEnd: Color(0xFF0066FF),
    ),
    _OnboardSlide(
      title: 'Fast, clear actions',
      subtitle:
          'Large touch targets and color-coded emergency types — no confusion under stress.',
      icon: Icons.flash_on_rounded,
      bgStart: Color(0xFF0A84FF),
      bgEnd: Color(0xFF00C2FF),
    ),
    _OnboardSlide(
      title: 'Offline & verified',
      subtitle:
          'Cached local contacts per LGA and verified emergency numbers you can trust.',
      icon: Icons.verified_user_rounded,
      bgStart: Color(0xFF12A572),
      bgEnd: Color(0xFF62D39F),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Simple pulsing animation for CTA
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.95,
      upperBound: 1.06,
    )..repeat(reverse: true);

    // Enter immersive sticky mode on onboarding (Android): nav hidden, comes back on swipe
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _page && mounted) {
        setState(() => _page = newPage);
      }
    });
  }

  @override
  void dispose() {
    // Restore normal UI overlays when leaving onboarding
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < slides.length - 1) {
      _pageController.animateToPage(_page + 1,
          duration: const Duration(milliseconds: 360), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _skip() {
    _pageController.animateToPage(slides.length - 1,
        duration: const Duration(milliseconds: 360), curve: Curves.easeOut);
  }

  void _finish() {
    // Restore system mode and navigate to home
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _page;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 26 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white70,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context)
        .viewPadding
        .bottom; // ensures we sit above navigation
    final safeBottom = (bottomInset < 12) ? 16.0 : bottomInset + 8.0;

    return Scaffold(
      body: Stack(
        children: [
          // PageView with gradient backgrounds per slide
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            itemBuilder: (context, idx) {
              final s = slides[idx];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [s.bgStart, s.bgEnd],
                  ),
                ),
                child: SafeArea(
                  top: true,
                  bottom: false, // we'll control bottom padding manually
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
                        // Big icon
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(s.icon, size: 88, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(s.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 15)),
                        const Spacer(),
                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(slides.length, _buildIndicator),
                        ),
                        const SizedBox(height: 20 + 4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Top-right Skip
          Positioned(
            right: 18,
            top: MediaQuery.of(context).viewPadding.top + 8,
            child: TextButton(
              onPressed: _skip,
              child:
                  const Text('Skip', style: TextStyle(color: Colors.white70)),
            ),
          ),

          // Bottom controls (Next / Get started) — placed above nav using safeBottom
          Positioned(
            left: 18,
            right: 18,
            bottom: safeBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Next / Get started button (pulsing)
                ScaleTransition(
                  scale: _pulseController,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        _page == slides.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Secondary button (learn more / privacy) - subtle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      child: const Text('Learn more',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// small model for slides
class _OnboardSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgStart;
  final Color bgEnd;

  _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgStart,
    required this.bgEnd,
  });
}
