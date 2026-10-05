import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'providers/user_data_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppTheme.init();
  runApp(const LuminaCareerApp());
}

class LuminaCareerApp extends StatelessWidget {
  const LuminaCareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkMode,
      builder: (context, isDark, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<UserDataProvider>(
              create: (_) => UserDataProvider(),
            ),
          ],
          child: MaterialApp(
          title: 'Lumina Career AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primary,
              primary: AppTheme.primary,
              secondary: AppTheme.secondary,
              surface: AppTheme.bg,
            ),
          ),
          // Auth-aware root: show login if not signed in, home if signed in
          home: const SplashScreen(nextScreen: AuthGate()),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const MainScreen(),
            '/pricing': (context) => const PricingScreen(),
            '/upload': (context) => const UploadScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
          ),
        );   // closes MultiProvider
      },
    );
  }
}

/// Listens to Firebase auth state — routes to login or home automatically.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Waiting for Firebase to respond
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.bg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome,
                      color: AppTheme.primary, size: 48),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text('Loading Lumina...',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          );
        }
        // Signed in → main app
        if (snapshot.hasData) return const MainScreen();
        // Not signed in → login
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkMode,
      builder: (context, isDark, child) {
        final List<Widget> screens = [
          const DashboardScreen(),
          const LearningScreen(),
          const RoadmapScreen(),
          const JobsScreen(),
          const AssistantScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: KeyedSubtree(
            key: ValueKey(isDark), // Force rebuild of active tab when theme changes
            child: screens[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardBg,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories),
              label: 'Learning',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alt_route_outlined),
              activeIcon: Icon(Icons.alt_route),
              label: 'Roadmap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
    },
  );
  }
}
