import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() => _user = currentUser);
      try {
        await currentUser.reload();
        if (mounted) {
          setState(() {
            _user = FirebaseAuth.instance.currentUser;
          });
        }
      } catch (e) {
        debugPrint('Error reloading user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header Section ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName?.toUpperCase() ?? 'GUEST USER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'guest@shopwave.com',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Orders', '24'),
                      _buildDivider(),
                      _buildStat('Wishlist', '18'),
                      _buildDivider(),
                      _buildStat('Reviews', '12'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Menu Items ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      color: AppTheme.textLightPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    Icons.shopping_bag_rounded,
                    'My Orders',
                    color: AppTheme.primaryPurple,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.local_shipping_rounded,
                    'Shipping Address',
                    color: AppTheme.accentTeal,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.payment_rounded,
                    'Payment Methods',
                    color: AppTheme.neonYellow,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.notifications_rounded,
                    'Notifications',
                    color: AppTheme.accentPink,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.favorite_border_rounded,
                    'My Wishlist',
                    color: AppTheme.neonPink,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.lock_outline_rounded,
                    'Privacy & Security',
                    color: AppTheme.neonCyan,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    Icons.help_outline_rounded,
                    'Help & Support',
                    color: AppTheme.neonBlue,
                    onTap: () {},
                  ),
                  _buildMenuSwitch(
                    isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    'Dark Mode',
                    color: Colors.indigo,
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  _buildMenuItem(
                    Icons.language_rounded,
                    'Language',
                    color: AppTheme.accentOrange,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.logout_rounded,
                    'Log Out',
                    color: AppTheme.neonRed,
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure you want to log out of ShopWave?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textLightSecondary)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                if (context.mounted) {
                                  Provider.of<NavigationProvider>(context, listen: false).goHome();
                                }
                                await FirebaseAuth.instance.signOut();
                              },
                              child: const Text('Log Out', style: TextStyle(color: AppTheme.neonRed)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ─── App Info ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppTheme.textLightMuted, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ShopWave v1.0.0',
                          style: TextStyle(
                            color: AppTheme.textLightMuted,
                            fontSize: 13,
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label, {
    required Color color,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDestructive
            ? color.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isDestructive ? color : AppTheme.textLightPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textLightMuted,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMenuSwitch(
    IconData icon,
    String label, {
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: AppTheme.textLightPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
        activeTrackColor: color.withValues(alpha: 0.4),
      ),
    );
  }
}