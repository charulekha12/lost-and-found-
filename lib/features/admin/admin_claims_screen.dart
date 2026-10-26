import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';

class AdminClaimsScreen extends StatefulWidget {
  const AdminClaimsScreen({super.key});

  @override
  State<AdminClaimsScreen> createState() => _AdminClaimsScreenState();
}

class _AdminClaimsScreenState extends State<AdminClaimsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _fs = FirestoreService.instance;
  final String? _adminUid = FirebaseAuth.instance.currentUser?.uid;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Manage Claims',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryTeal,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ClaimsListView(
              status: 'pending', adminUid: _adminUid, fs: _fs),
          _ClaimsListView(
              status: 'approved', adminUid: _adminUid, fs: _fs),
          _ClaimsListView(
              status: 'rejected', adminUid: _adminUid, fs: _fs),
        ],
      ),
    );
  }
}

// ── Claims List View ─────────────────────────────────────────────────

class _ClaimsListView extends StatelessWidget {
  final String status;
  final String? adminUid;
  final FirestoreService fs;

  const _ClaimsListView({
    required this.status,
    required this.adminUid,
    required this.fs,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fs.getAllClaims(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal));
        }
        if (snap.hasError) {
          return _buildError('Failed to load claims: ${snap.error}');
        }

        final allClaims = snap.data ?? [];
        final filtered = allClaims
            .where((c) =>
                (c['status'] as String? ?? '').toLowerCase() ==
                status.toLowerCase())
            .toList();

        if (filtered.isEmpty) {
          return _buildEmpty(status);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => _ClaimCard(
            claim: filtered[i],
            adminUid: adminUid,
            fs: fs,
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String status) {
    final icons = {
      'pending': Icons.pending_actions_rounded,
      'approved': Icons.check_circle_rounded,
      'rejected': Icons.cancel_rounded,
    };
    final msgs = {
      'pending': 'No pending claims',
      'approved': 'No approved claims yet',
      'rejected': 'No rejected claims',
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[status] ?? Icons.inbox, size: 52, color: AppTheme.textHint),
          const SizedBox(height: 12),
          Text(
            msgs[status] ?? 'No claims',
            style: GoogleFonts.poppins(
                fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(msg,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.poppins(fontSize: 13, color: AppTheme.errorColor)),
      ),
    );
  }
}

// ── Claim Card ───────────────────────────────────────────────────────

class _ClaimCard extends StatefulWidget {
  final Map<String, dynamic> claim;
  final String? adminUid;
  final FirestoreService fs;

  const _ClaimCard({
    required this.claim,
    required this.adminUid,
    required this.fs,
  });

  @override
  State<_ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<_ClaimCard> {
  bool _loading = false;

  Map<String, dynamic> get _c => widget.claim;
  String get _status => (_c['status'] as String? ?? 'pending').toLowerCase();
  bool get _isPending => _status == 'pending';
  bool get _isApproved => _status == 'approved';

  DateTime? get _createdAt {
    final ts = _c['createdAt'];
    if (ts is Timestamp) return ts.toDate();
    return null;
  }

  Future<void> _approve() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.fs.updateClaim(_c['id'] as String, {
        'status': 'approved',
        'decidedBy': widget.adminUid ?? '',
        'decidedAt': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final remarksController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Claim',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for rejection (optional):',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Admin remarks...',
                hintStyle:
                    GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reject',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await widget.fs.updateClaim(_c['id'] as String, {
        'status': 'rejected',
        'decidedBy': widget.adminUid ?? '',
        'decidedAt': Timestamp.now(),
        'adminRemarks': remarksController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isPending
        ? AppTheme.warningColor
        : _isApproved
            ? AppTheme.successColor
            : AppTheme.errorColor;

    final remarks = (_c['adminRemarks'] as String? ?? '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _c['itemTitle'] as String? ?? 'Unknown Item',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: _status, color: statusColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Claim ID: ${_c['id'] ?? 'N/A'}',
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppTheme.textHint),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 10),

            // Claimant details
            _InfoRow(
                icon: Icons.person_rounded,
                label: 'Claimant',
                value: _c['claimantName'] as String? ?? 'N/A'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.email_rounded,
                label: 'Email',
                value: _c['claimantEmail'] as String? ?? 'N/A'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: _c['claimantPhone'] as String? ?? 'N/A'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.description_rounded,
                label: 'Proof',
                value: _c['proofDescription'] as String? ?? 'N/A'),
            if (_createdAt != null) ...[
              const SizedBox(height: 6),
              _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: DateFormat('dd MMM yyyy, hh:mm a')
                      .format(_createdAt!)),
            ],

            // Admin remarks (approved/rejected)
            if (!_isPending && remarks.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Admin Remarks: $remarks',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons for pending claims
            if (_isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _approve,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _loading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white),
                      label: Text('Approve',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _reject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        minimumSize: const Size(0, 42),
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: AppTheme.errorColor),
                      label: Text('Reject',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorColor)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryTeal),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
