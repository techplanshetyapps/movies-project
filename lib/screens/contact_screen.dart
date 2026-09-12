import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/social_icon_button.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Contact',
      currentRouteLabel: 'Contact',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in touch', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Questions, feedback, or partnership ideas — reach us on any of the '
              'channels below.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                SocialIconButton(
                  icon: Icons.business_center_rounded,
                  label: 'LinkedIn',
                  url: 'https://www.linkedin.com/in/nataliia-rudnikova/',
                  color: Color(0xFF0A66C2),
                ),
                SocialIconButton(
                  icon: Icons.videocam_rounded,
                  label: 'Vimeo',
                  url: 'https://vimeo.com/',
                  color: Color(0xFF1AB7EA),
                ),
                SocialIconButton(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  url: 'https://github.com/techplanshetyapps',
                  color: Color(0xFFF5F5F7),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
