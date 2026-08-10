import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';

/// User profile screen showing all personal and academic details.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      await context.read<UserProvider>().fetchUser(uid: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primaryTeal,
            backgroundColor: AppTheme.darkCard,
            onRefresh: _loadProfile,
            child: CustomScrollView(
              slivers: [
                // ── Custom App Bar ──────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryTeal,
                        size: 22,
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.editProfile,
                        );
                        if (mounted) _loadProfile();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                SliverToBoxAdapter(
                  child: userProvider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // ── Avatar Header ─────────────────────
                            _buildAvatarHeader(user.initials,
                                user.profileImageUrl),

                            // ── Name & Department ─────────────────
                            _buildNameSection(
                              user.fullName.isNotEmpty
                                  ? user.fullName
                                  : 'Campus User',
                              user.department,
                            ),

                            const SizedBox(height: 24),

                            // ── Info Cards ────────────────────────
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _buildInfoCard(
                                    title: 'Contact Information',
                                    icon: Icons.contact_page_outlined,
                                    items: [
                                      _InfoItem(
                                        icon: Icons.email_outlined,
                                        label: 'Email',
                                        value: user.email.isNotEmpty
                                            ? user.email
                                            : 'Not set',
                                      ),
                                      _InfoItem(
                                        icon: Icons.phone_outlined,
                                        label: 'Phone',
                                        value: user.phone.isNotEmpty
                                            ? user.phone
                                            : 'Not set',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildInfoCard(
                                    title: 'Academic Details',
                                    icon: Icons.school_outlined,
                                    items: [
                                      _InfoItem(
                                        icon: Icons.apartment_outlined,
                                        label: 'Department',
                                        value: user.department.isNotEmpty
                                            ? user.department
                                            : 'Not set',
                                      ),
                                      _InfoItem(
                                        icon: Icons.tag_rounded,
                                        label: 'Roll Number',
                                        value: user.rollNumber.isNotEmpty
                                            ? user.rollNumber
                                            : 'Not set',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildInfoCard(
                                    title: 'Account Info',
                                    icon: Icons.info_outline_rounded,
                                    items: [
                                      _InfoItem(
                                        icon: Icons.calendar_today_outlined,
                                        label: 'Member Since',
                                        value: user.isValid
                                            ? DateFormat('MMMM d, yyyy')
                                                .format(user.createdAt)
                                            : 'Unknown',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Edit Profile Button ────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    AppRoutes.editProfile,
                                  );
                                  if (mounted) _loadProfile();
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  side: const BorderSide(
                                    color: AppTheme.primaryTeal,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppTheme.primaryTeal,
                                ),
                                label: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: AppTheme.primaryTeal,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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

  Widget _buildAvatarHeader(String initials, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _AvatarPlaceholder(
                          initials: initials,
                        ),
                        errorWidget: (_, __, ___) =>
                            _AvatarPlaceholder(initials: initials),
                      )
                    : _AvatarPlaceholder(initials: initials),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 500.ms);
  }

  Widget _buildNameSection(String name, String department) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        if (department.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x1A00B4D8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryTeal.withOpacity(0.4),
              ),
            ),
            child: Text(
              department,
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryTeal, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map(
            (item) => _buildInfoRow(item),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(item.icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _AvatarPlaceholder extends StatelessWidget {
  final String initials;
  const _AvatarPlaceholder({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkCard,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
