import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';

/// Onboarding Screen with 3 slides
/// Explains the app purpose and features
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  // Removed PageController to stop automatic movements

  @override
  void initState() {
    super.initState();
    // Check login status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isLoggedIn) {
      // User is already logged in, skip building this screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isLoggedIn) {
      return const Scaffold(backgroundColor: Colors.white);
    }

    final currentLanguage = appState.currentLanguage;

    final List<OnboardingSlide> slides = [
      OnboardingSlide(
        imagePath: 'assets/images/hero-robot.png',
        title: AppLocalizations.t('welcome_to_rafiq', locale: currentLanguage),
        description:
            AppLocalizations.t('welcome_desc', locale: currentLanguage),
        color: Colors.pink,
      ),
      OnboardingSlide(
        imagePath: 'assets/images/hero dr.png',
        title:
            AppLocalizations.t('learn_grow_together', locale: currentLanguage),
        description:
            AppLocalizations.t('learn_grow_desc', locale: currentLanguage),
        color: Colors.blue,
      ),
      OnboardingSlide(
        imagePath: 'assets/images/family.png',
        title: AppLocalizations.t('track_progress', locale: currentLanguage),
        description:
            AppLocalizations.t('track_progress_desc', locale: currentLanguage),
        color: Colors.purple,
      ),
    ];

    void nextSlide() {
      if (_currentPage < slides.length - 1) {
        setState(() {
          _currentPage++;
        });
      } else {
        Navigator.of(context).pushReplacementNamed('/role-selection');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < slides.length - 1)
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/role-selection'),
                      child: Text(
                          AppLocalizations.t('skip', locale: currentLanguage)),
                    ),
                ],
              ),
            ),

            // Static Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (slides[_currentPage].imagePath != null)
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                slides[_currentPage].imagePath!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Icon(slides[_currentPage].icon,
                              size: 64, color: slides[_currentPage].color),
                        const SizedBox(height: 48),
                        Text(
                          slides[_currentPage].title,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slides[_currentPage].description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Dots Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GradientButton(
                text: _currentPage == slides.length - 1
                    ? AppLocalizations.t('get_started', locale: currentLanguage)
                    : AppLocalizations.t('next', locale: currentLanguage),
                onPressed: nextSlide,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Onboarding Slide Model
class OnboardingSlide {
  final String? imagePath;
  final IconData? icon;
  final String title;
  final String description;
  final Color color;

  OnboardingSlide({
    this.imagePath,
    this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
