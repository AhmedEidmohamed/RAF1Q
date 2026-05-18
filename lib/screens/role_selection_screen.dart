import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';

/// Role Selection Screen
/// Allow user to select Parent/Guardian or Specialist/Therapist role
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  AppLocalizations.t('who_are_you', locale: currentLanguage),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.t('select_role_continue',
                      locale: currentLanguage),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Image Cards Row - Tilted images
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ImageRoleCard(
                          imagePath: 'assets/images/famil.jpg',
                          title: AppLocalizations.t('parent_guardian',
                              locale: currentLanguage),
                          description: AppLocalizations.t('parent_desc',
                              locale: currentLanguage),
                          onTap: () {
                            // TODO: Save user role to local storage/database
                            Navigator.of(context)
                                .pushReplacementNamed('/child-login');
                          },
                          tiltAngle: -0.15, // Left tilt
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ImageRoleCard(
                          imagePath: 'assets/images/dector.jpg',
                          title: AppLocalizations.t('specialist_therapist',
                              locale: currentLanguage),
                          description: AppLocalizations.t('specialist_desc',
                              locale: currentLanguage),
                          onTap: () {
                            // TODO: Save user role to local storage/database
                            Navigator.of(context)
                                .pushReplacementNamed('/doctor-registration');
                          },
                          tiltAngle: 0.15, // Right tilt
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Image Role Card Widget
class _ImageRoleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;
  final double tiltAngle;

  const _ImageRoleCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
    required this.tiltAngle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Tilted Image Container
          Container(
            height: 200,
            child: Transform.rotate(
              angle: tiltAngle,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Text Content Below Image
          Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
