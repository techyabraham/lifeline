import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {'title': 'Fast Help', 'description': 'Get connected to verified emergency contacts quickly.', 'icon': 'assets/icons/fast.png'},
    {'title': 'Verified Contacts', 'description': 'All contacts are verified and trusted.', 'icon': 'assets/icons/verified.png'},
    {'title': 'Offline Access', 'description': 'Access emergency contacts even without internet.', 'icon': 'assets/icons/offline.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(pages[index]['icon']!, height: 200),
                SizedBox(height: 24),
                Text(pages[index]['title']!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text(pages[index]['description']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
      bottomSheet: currentIndex == pages.length - 1
          ? TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: Text('Get Started', style: TextStyle(fontSize: 20)),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: Text('Skip')),
                TextButton(onPressed: () => _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease), child: Text('Next')),
              ],
            ),
    );
  }
}
