import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/claim_model.dart';
import '../items/browse_items_screen.dart';

/// My Claims Screen matching Findora design.
class MyClaimsScreen extends StatelessWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'My Claims',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const MyClaimsScreenContent(),
    );
  }
}

/// Standalone content widget embeddable inside MyActivity tab.
class MyClaimsScreenContent extends StatefulWidget {
  const MyClaimsScreenContent({super.key});

  @override
  State<MyClaimsScreenContent> createState() => _MyClaimsScreenContentState();
}

class _MyClaimsScreenContentState extends State<MyClaimsScreenContent> {
  final FirestoreService _fs = FirestoreService.instance;
  String _selectedTab = 'all'; // 'all', 'pending', 'approved', 'rejected'

  void _showCancelDialog(ClaimModel claim) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Claim?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to withdraw your claim for "${claim.itemTitle}"?',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Claim'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _fs.cancelClaim(claim.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Claim withdrawn.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text('Please log in to view your claims.'),
      );
    }

    return Column(
      children: [
        // ── Tabs: All | Pending | Approved | Rejected ────────────────
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTab('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterTab('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterTab('Approved', 'approved'),
                const SizedBox(width: 8),
                _buildFilterTab('Rejected', 'rejected'),
              ],
            ),
          ),
        ),

        // ── Claims Stream ────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<ClaimModel>>(
            stream: _fs.getUserClaims(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                );
              }

              if (snapshot.hasError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Could not load claims:\n${snapshot.error}',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

              final all = snapshot.data ?? [];
              final filtered = all.where((c) {
                if (_selectedTab == 'all') return true;
                return c.status.toLowerCase() == _selectedTab;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 56, color: AppTheme.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _selectedTab == 'all'
                            ? 'No claims submitted yet'
                            : 'No $_selectedTab claims found',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Found an item that belongs to you? Submit a claim.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BrowseItemsScreen(
                                initialTypeFilter: 'found',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Browse Found Items'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final claim = filtered[index];
                  return _ClaimCard(
                    claim: claim,
                    onCancel: () => _showCancelDialog(claim),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Claim Card ───────────────────────────────────────────────────────────────

class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final VoidCallback onCancel;

  const _ClaimCard({required this.claim, required this.onCancel});

  Color get _statusColor {
    switch (claim.status.toLowerCase()) {
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortId =
        claim.id.length > 8 ? claim.id.substring(0, 8).toUpperCase() : claim.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppTheme.primaryTeal, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.itemTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Claim #$shortId • ${DateFormat('MMM d, yyyy').format(claim.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  claim.status.toUpperCase().substring(0, 1) +
                      claim.status.substring(1),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),

          if (claim.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Proof: ${claim.description}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],

          if (claim.adminRemarks != null && claim.adminRemarks!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Admin Remarks: ${claim.adminRemarks}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (claim.isPending) ...[
            const Divider(height: 20, color: AppTheme.borderLight),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded,
                    size: 16, color: AppTheme.errorColor),
                label: const Text(
                  'Withdraw Claim',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
