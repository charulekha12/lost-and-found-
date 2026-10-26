
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/providers/auth_provider.dart' as app_auth;
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';

/// User profile screen matching Findora design.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoad();
  }

  Future<void> _checkAdminAndLoad() async {
    final uid = context.read<app_auth.AuthProvider>().currentUser?.uid;

    if (uid != null) {
      await context.read<UserProvider>().fetchUser(uid: uid);
      final profile = await FirestoreService.instance.getUserProfile(uid);

      if (mounted) {
        setState(() {
          _isAdmin = profile?['role'] == 'admin';
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of Findora?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<app_auth.AuthProvider>().signOut();
              context.read<UserProvider>().clearUser();

              if (!mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final displayName = user.fullName.isNotEmpty
        ? user.fullName
        : (FirebaseAuth.instance.currentUser?.displayName ?? 'Kavitha S');

    final email = user.email.isNotEmpty
        ? user.email
        : (FirebaseAuth.instance.currentUser?.email ??
            'kavitha@example.com');

    final rollNo = user.rollNumber.isNotEmpty
        ? user.rollNumber
        : 'CSE202401';

    final dept = user.department.isNotEmpty
        ? user.department
        : 'Computer Engineering';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: _checkAdminAndLoad,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: [
              // User Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: ClipOval(
                            child: user.profileImageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user.profileImageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Center(
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      user.initials.isNotEmpty
                                          ? user.initials
                                          : 'KS',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.editProfile,
                              );
                              _checkAdminAndLoad();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Student ID: $rollNo',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Department: $dept',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu List
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      iconColor: AppTheme.primaryTeal,
                      title: 'Edit Profile',
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.editProfile,
                        );
                        _checkAdminAndLoad();
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                    _buildMenuItem(
                      icon: Icons.inventory_2_outlined,
                      iconColor: AppTheme.primaryNavy,
                      title: 'My Reports',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.myReports,
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                    _buildMenuItem(
                      icon: Icons.verified_outlined,
                      iconColor: AppTheme.successColor,
                      title: 'My Claims',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.myClaims,
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                    _buildMenuItem(
                      icon: Icons.mark_email_unread_outlined,
                      iconColor: AppTheme.primaryTeal,
                      title: 'Claims on My Items',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.claimsOnMyItems,
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppTheme.warningColor,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.helpSupport,
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppTheme.borderLight,
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppTheme.textSecondary,
                      title: 'Privacy Policy',
                      onTap: _showPrivacyDialog,
                    ),

                    if (_isAdmin) ...[
                      const Divider(
                        height: 1,
                        color: AppTheme.borderLight,
                      ),
                      _buildMenuItem(
                        icon: Icons.admin_panel_settings_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Admin Dashboard',
                        badge: 'Staff',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminDashboard,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppTheme.errorColor,
                  title: 'Logout',
                  textColor: AppTheme.errorColor,
                  hideChevron: true,
                  onTap: _showLogoutDialog,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    String? badge,
    bool hideChevron = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          if (!hideChevron)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textHint,
              size: 20,
            ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Findora respects your privacy. All item data and claim reports '
            'submitted within this application are exclusively used for '
            'campus lost and found coordination.\n\n'
            'Personal contact details are shared only when you submit an '
            'item report or a claim request.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
