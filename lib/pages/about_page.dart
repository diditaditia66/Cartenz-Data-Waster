import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Header card
          Card(
            color: const Color(0xFF10273F),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF80D6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cartenz Data Waster',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Internal tool to stress test VPN, quota policy, and bandwidth shaping.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cartenz VPN Labs',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detail card
          Card(
            color: const Color(0xFF10273F),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Version'),
                  const SizedBox(height: 4),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.tag, size: 20),
                    title: Text(
                      '1.0.0',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Cartenz-Internal build'),
                  ),
                  const SizedBox(height: 12),

                  _sectionTitle('Backend'),
                  const SizedBox(height: 4),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.dns_rounded, size: 20),
                    title: Text('waster.anya-vpn.my.id'),
                    subtitle: Text('Node.js • Nginx • HTTPS (Let\'s Encrypt)'),
                  ),
                  const SizedBox(height: 12),

                  _sectionTitle('Notes'),
                  const SizedBox(height: 4),
                  _bullet(
                    icon: Icons.warning_amber_rounded,
                    text:
                        'Intended for internal testing only. Do not distribute publicly.',
                  ),
                  _bullet(
                    icon: Icons.sim_card_rounded,
                    text:
                        'Use over test SIM / test VPN profile to avoid unwanted charges.',
                  ),
                  _bullet(
                    icon: Icons.bolt_rounded,
                    text:
                        'High concurrency and infinite mode may quickly consume large amounts of data.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer kecil
          Align(
            alignment: Alignment.center,
            child: Text(
              '© ${DateTime.now().year} Cartenz VPN',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _bullet({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
