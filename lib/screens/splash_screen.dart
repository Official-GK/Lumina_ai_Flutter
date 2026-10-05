import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  String _statusMsg = 'Connecting Neural Vector Mesh...';
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    
    // Cubic ease out curve
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    
    _progressController.addListener(() {
      setState(() {
        final percent = (_progressAnimation.value * 100).toInt();
        if (percent > 70) {
          _statusMsg = 'Synthesizing Leadership Benchmarks...';
        } else if (percent > 35) {
          _statusMsg = 'Analyzing 14,000+ Verified Staff+ Rubrics';
        }
      });
    });
    
    _progressController.forward().then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on AppTheme
    final isDark = AppTheme.isDark;
    
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final primaryGlow = isDark ? Colors.tealAccent.withValues(alpha: 0.3) : Colors.teal.withValues(alpha: 0.2);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.radar, color: subTextColor, size: 18),
                  Text('LAT 37.7749° N • VEC 122.4194° W', style: TextStyle(color: subTextColor, fontSize: 10, letterSpacing: 2, fontFamily: 'monospace')),
                ],
              ),
              
              // Center Hero
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: primaryGlow, blurRadius: 40, spreadRadius: 10),
                      ],
                      border: Border.all(color: Colors.teal.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Center(
                      child: Icon(Icons.auto_awesome, color: AppTheme.primary, size: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lumina',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'YOUR AI CAREER COMPASS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: subTextColor,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: subTextColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          'Neural Trajectory Engine ',
                          style: TextStyle(fontSize: 11, color: subTextColor, fontFamily: 'monospace'),
                        ),
                        const Text(
                          'v4.8',
                          style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Bottom Sync Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Semantic Trajectory Sync', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            final percent = (_progressAnimation.value * 100).toInt();
                            final isDone = percent == 100;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDone ? Colors.teal : Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDone ? Colors.teal : Colors.teal.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '$percent% Synced',
                                style: TextStyle(
                                  color: isDone ? Colors.white : Colors.teal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: subTextColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: _progressAnimation.value,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Colors.tealAccent, Colors.teal, Colors.deepPurpleAccent]),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: Colors.teal, size: 14),
                              const SizedBox(width: 4),
                              Expanded(child: Text(_statusMsg, style: TextStyle(color: subTextColor, fontSize: 11), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        Text('38ms', style: TextStyle(color: subTextColor, fontSize: 10, fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bottom Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: Colors.teal, size: 14),
                    const SizedBox(width: 6),
                    Text('SOC-2 Type II  •  Zero-Retention Encryption', style: TextStyle(color: subTextColor, fontSize: 10, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
