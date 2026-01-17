// lib/ui/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

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
      title: 'Auto Location Detection',
      subtitle:
          'We detect your area so you can reach help with fewer steps.',
      icon: Icons.my_location,
      color: AppColors.brandBlue,
    ),
    _OnboardSlide(
      title: 'Select Your Area',
      subtitle:
          'Pick your state and local government if auto detection fails.',
      icon: Icons.map_outlined,
      color: AppColors.brandGreen,
    ),
    _OnboardSlide(
      title: 'Get Help Fast',
      subtitle:
          'Tap a service type to call the closest verified provider.',
      icon: Icons.local_hospital_outlined,
      color: AppColors.brandRed,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.95,
      upperBound: 1.06,
    )..repeat(reverse: true);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _page && mounted) {
        setState(() => _page = newPage);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < slides.length - 1) {
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      slides.length - 1,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOut,
    );
  }

  void _finish() {
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
        color: isActive ? AppColors.brandBlue : AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final safeBottom = (bottomInset < 12) ? 16.0 : bottomInset + 8.0;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            itemBuilder: (context, idx) {
              final s = slides[idx];
              return SafeArea(
                top: true,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 42,
                        height: 42,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LifeLine',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 1.2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: s.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  s.icon,
                                  size: 60,
                                  color: s.color,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                s.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(slides.length, _buildIndicator),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 18,
            top: MediaQuery.of(context).viewPadding.top + 8,
            child: TextButton(
              onPressed: _skip,
              child:
                  const Text('Skip', style: TextStyle(color: AppColors.muted)),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: safeBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseController,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _page == slides.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: const Text('Learn more',
                      style: TextStyle(color: AppColors.muted)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
