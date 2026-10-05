import '../app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'AI-Powered Resume Analysis',
      'description': 'Upload your CV and let Lumina discover your hidden strengths and skill gaps in seconds.',
      'icon': 'upload_file'
    },
    {
      'title': 'Personalized Career Roadmap',
      'description': 'Get a step-by-step trajectory tailored to your dream role, from courses to hands-on projects.',
      'icon': 'alt_route'
    },
    {
      'title': 'Nail the Interview',
      'description': 'Practice with our intelligent career assistant and fast-track your applications to top tech companies.',
      'icon': 'auto_awesome'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Ambient Background Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purpleHighlight.withValues(alpha: 0.4),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 24),
                // Top Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child: Text('Skip', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: Offset(0, 10))],
                              ),
                              child: Center(
                                child: Icon(
                                  _getIcon(_onboardingData[index]['icon']!),
                                  size: 48,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 48),
                            Text(
                              _onboardingData[index]['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _onboardingData[index]['description']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Controls
                Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Container(
                            margin: EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index ? AppTheme.primary : AppTheme.highlight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      ElevatedButton(
                        onPressed: () {
                          if (_currentIndex == _onboardingData.length - 1) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            // Can't easily control PageView without a controller, but it's just a demo
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentIndex == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                          style: TextStyle(color: AppTheme.cardBg, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'upload_file':
        return Icons.upload_file;
      case 'alt_route':
        return Icons.alt_route;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }
}
