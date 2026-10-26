
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _fs = FirestoreService.instance;

  late final Future<bool> _adminCheck;

  @override
  void initState() {
    super.initState();
    _adminCheck = _isAdmin();
  }

  /// Allows dashboard access only when the signed-in user's
  /// Firestore profile contains role: "admin".
  Future<bool> _isAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return false;
      }

      final profile = await _fs.getUserProfile(user.uid);

      if (profile == null) {
        return false;
      }

      return profile['role']?.toString().toLowerCase() == 'admin';
    } catch (e) {
      debugPrint('Admin verification failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _adminCheck,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.scaffoldBg,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryTeal,
              ),
            ),
          );
        }

        if (snap.hasError || snap.data != true) {
          return _buildAccessDenied();
        }

        return _buildDashboard();
      },
    );
  }

  // ── Access Denied ────────────────────────────────────────────────

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have admin privileges\nto access this section.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main Dashboard ───────────────────────────────────────────────

  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildRecentReportsSection(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ───────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.navyGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppTheme.primaryTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'College In-charge',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Statistics Grid ──────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return StreamBuilder<List<ItemModel>>(
      stream: _fs.getAllItems(),
      builder: (context, itemSnap) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _fs.getAllUsers(),
          builder: (context, userSnap) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fs.getAllClaims(),
              builder: (context, claimSnap) {
                final items = itemSnap.data ?? [];
                final users = userSnap.data ?? [];
                final claims = claimSnap.data ?? [];

                final totalUsers = users.length;
                final lostReports =
                    items.where((item) => item.isLost).length;
                final foundReports =
                    items.where((item) => item.isFound).length;

                final pendingClaims = claims
                    .where((claim) =>
                        (claim['status'] ?? '').toString().toLowerCase() ==
                        'pending')
                    .length;

                final approvedClaims = claims
                    .where((claim) =>
                        (claim['status'] ?? '').toString().toLowerCase() ==
                        'approved')
                    .length;

                final returnedItems =
                    items.where((item) => item.isResolved).length;

                final stats = [
                  _StatData(
                    'Total Users',
                    totalUsers,
                    Icons.people_alt_rounded,
                    AppTheme.primaryNavy,
                  ),
                  _StatData(
                    'Lost Reports',
                    lostReports,
                    Icons.search_rounded,
                    AppTheme.errorColor,
                  ),
                  _StatData(
                    'Found Reports',
                    foundReports,
                    Icons.inventory_2_rounded,
                    AppTheme.successColor,
                  ),
                  _StatData(
                    'Pending Claims',
                    pendingClaims,
                    Icons.pending_actions_rounded,
                    AppTheme.warningColor,
                  ),
                  _StatData(
                    'Approved Claims',
                    approvedClaims,
                    Icons.check_circle_rounded,
                    AppTheme.primaryTeal,
                  ),
                  _StatData(
                    'Returned Items',
                    returnedItems,
                    Icons.assignment_turned_in_rounded,
                    const Color(0xFF8B5CF6),
                  ),
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: stats.length,
                  itemBuilder: (_, index) =>
                      _StatCard(data: stats[index]),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Recent Reports ───────────────────────────────────────────────

  Widget _buildRecentReportsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.adminReports),
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<ItemModel>>(
          stream: _fs.getAllItems(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryTeal,
                  ),
                ),
              );
            }

            if (snap.hasError) {
              return _buildErrorState('Failed to load reports.');
            }

            final items = (snap.data ?? []).take(5).toList();

            if (items.isEmpty) {
              return _buildEmptyState(
                Icons.article_outlined,
                'No reports yet.',
              );
            }

            return Column(
              children: items
                  .map((item) => _RecentItemRow(item: item))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _ActionData(
        'Manage Claims',
        Icons.fact_check_rounded,
        AppTheme.primaryTeal,
        AppRoutes.adminClaims,
      ),
      _ActionData(
        'Manage Reports',
        Icons.article_rounded,
        AppTheme.primaryNavy,
        AppRoutes.adminReports,
      ),
      _ActionData(
        'Manage Users',
        Icons.manage_accounts_rounded,
        const Color(0xFF8B5CF6),
        AppRoutes.adminUsers,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: action != actions.last ? 10 : 0,
                    ),
                    child: _QuickActionButton(data: action),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.textHint),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatData(this.label, this.value, this.icon, this.color);
}

class _ActionData {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionData(this.label, this.icon, this.color, this.route);
}

// ── Reusable Widgets ───────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.value}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                data.label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
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

class _RecentItemRow extends StatelessWidget {
  final ItemModel item;

  const _RecentItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLost = item.isLost;
    final isResolved = item.isResolved;

    final typeColor =
        isLost ? AppTheme.errorColor : AppTheme.successColor;
    final statusColor =
        isResolved ? AppTheme.successColor : AppTheme.warningColor;
    final statusLabel = isResolved ? 'Resolved' : 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isLost
                  ? Icons.search_rounded
                  : Icons.inventory_2_rounded,
              color: typeColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category} • ${item.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Badge(
                label: isLost ? 'Lost' : 'Found',
                color: typeColor,
              ),
              const SizedBox(height: 4),
              _Badge(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _ActionData data;

  const _QuickActionButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, data.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: data.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(data.icon, color: data.color, size: 24),
            const SizedBox(height: 6),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: data.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
