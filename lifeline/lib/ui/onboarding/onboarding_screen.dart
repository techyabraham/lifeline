import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  // tweak pages here
  final List<_OnboardPageData> _pages = [
    _OnboardPageData(
      title: 'Fast Help',
      subtitle: 'One-tap access to verified emergency contacts nearby.',
      icon: Icons.flash_on_rounded,
      color: Color(0xFF0047AB),
    ),
    _OnboardPageData(
      title: 'Locate Help',
      subtitle: 'Automatically find services in your LGA or choose manually.',
      icon: Icons.location_on_rounded,
      color: Color(0xFF00A86B),
    ),
    _OnboardPageData(
      title: 'Stay Safe',
      subtitle: 'Share contacts quickly and get verified updates from admins.',
      icon: Icons.shield_rounded,
      color: Color(0xFFFF3B30),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Enter immersive (hides nav bar & status bar; user can swipe to reveal)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Optional: Ensure status bar icons are readable during onboarding
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _page && mounted) setState(() => _page = page);
    });
  }

  @override
  void dispose() {
    // Restore default system UI when leaving onboarding (edge-to-edge)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() {
    // restore UI BEFORE navigation for consistent experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      _pageController.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
      );
    } else {
      _goToHome();
    }
  }

  void _skip() {
    _goToHome();
  }

  @override
  Widget build(BuildContext context) {
    // Use safe area / media query to ensure controls are above nav bar
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    // Add a small extra padding so controls are clearly above nav bar
    final bottomPadding = bottomInset + 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // allow content to extend behind nav while keeping controls safe
        top: true,
        bottom: false,
        child: Stack(
          children: [
            // PageView with animated content
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final data = _pages[index];
                final delta =
                    (_pageController.hasClients && _pageController.page != null)
                        ? (_pageController.page! - index)
                        : (index == _page ? 0.0 : 1.0);
                // Use delta to create subtle parallax/scale animation
                final scale = (1 - (delta.abs() * 0.08)).clamp(0.9, 1.0);
                final opacity = (1 - delta.abs()).clamp(0.0, 1.0);

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          // Big icon area
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.62,
                                    height: MediaQuery.of(context).size.width *
                                        0.62,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          data.color.withOpacity(0.95),
                                          data.color.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: data.color.withOpacity(0.25),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        data.icon,
                                        size: 84,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Text area
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 26,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data.subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // Top-right small Skip button (keeps visible)
            Positioned(
              right: 12,
              top: 12,
              child: SafeArea(
                top: true,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Bottom controls: indicators + buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated dots
                    _PageIndicator(
                      currentIndex: _page,
                      itemCount: _pages.length,
                    ),
                    const SizedBox(height: 16),
                    // Buttons row
                    Row(
                      children: [
                        // Secondary button (Back / Skip placeholder)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _page == 0
                                ? null
                                : () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 360),
                                      curve: Curves.easeOut,
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _page == 0 ? '' : 'Back',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Primary button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: Text(
                              _page == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple model for onboarding screens
class _OnboardPageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// A small animated page indicator (no external packages)
class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const _PageIndicator({
    required this.currentIndex,
    required this.itemCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dots = List<Widget>.generate(itemCount, (i) {
      final active = i == currentIndex;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: active ? 26 : 10,
        height: 10,
        decoration: BoxDecoration(
          color: active ? Colors.black87 : Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }
}
