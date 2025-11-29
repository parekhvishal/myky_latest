import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaSection extends StatelessWidget {
  const SocialMediaSection({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: const Text(
              'Social Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,

                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // 3 Separate Social Media Cards in Horizontal Layout
          Row(
            children: [
              // YouTube Card
              Expanded(
                child: _buildSocialMediaCard(
                  title: 'YouTube',
                  subtitle: 'Watch Videos',
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/1384/1384060.png',
                  link: 'https://www.youtube.com/@yourchannelname',
                  gradientColors: [
                    const Color(0xFFFF0000),
                    const Color(0xFFCC0000),
                  ],
                  height: 110,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // Facebook Card
              Expanded(
                child: _buildSocialMediaCard(
                  title: 'Facebook',
                  subtitle: 'Get Updates',
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                  link: 'https://www.facebook.com/yourpage',
                  gradientColors: [
                    const Color(0xFF1877F2),
                    const Color(0xFF0C63D4),
                  ],
                  height: 110,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // Instagram Card
              Expanded(
                child: _buildSocialMediaCard(
                  title: 'Instagram',
                  subtitle: 'Daily Stories',
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/2111/2111463.png',
                  link: 'https://www.instagram.com/yourusername',
                  gradientColors: [
                    const Color(0xFFF58529),
                    const Color(0xFFDD2A7B),
                    const Color(0xFF8134AF),
                  ],
                  height: 110,
                  iconColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String link,
    required List<Color> gradientColors,
    required double height,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: () => _launchURL(link),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Content
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Image.network(
                        imageUrl,
                        height: 18,
                        width: 18,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getIconForPlatform(title),
                            color: Colors.white,
                            size: 18,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Tap effect overlay
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _launchURL(link),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_filled;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      default:
        return Icons.link;
    }
  }
}