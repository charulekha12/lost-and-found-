import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../report_item_screen.dart';
import 'edit_item_screen.dart';
import 'item_details_screen.dart';

/// My Reports Screen matching Findora design.
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

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
          'My Reports',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportItemScreen()),
              );
            },
          ),
        ],
      ),
      body: const MyReportsScreenContent(),
    );
  }
}

/// Standalone content widget embeddable inside MyActivity tab or screen.
class MyReportsScreenContent extends StatefulWidget {
  const MyReportsScreenContent({super.key});

  @override
  State<MyReportsScreenContent> createState() => _MyReportsScreenContentState();
}

class _MyReportsScreenContentState extends State<MyReportsScreenContent> {
  final FirestoreService _fs = FirestoreService.instance;
  String _selectedTab = 'all'; // 'all', 'lost', 'found'

  void _showDeleteDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Report?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This cannot be undone.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _fs.deleteItem(item.id, imageUrl: item.imageUrl);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report deleted successfully.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(ItemModel item) async {
    final newStatus = item.isResolved ? 'active' : 'resolved';
    try {
      await _fs.updateItem(item.id, {'status': newStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'resolved'
                ? 'Item marked as reunited/resolved! 🎉'
                : 'Item status reopened to active.',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text('Please log in to view your reports.'),
      );
    }

    return Column(
      children: [
        // ── Tabs: All | Lost | Found ─────────────────────────────────
        Container(
          color: AppTheme.cardWhite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildFilterTab('All', 'all'),
              const SizedBox(width: 8),
              _buildFilterTab('Lost', 'lost'),
              const SizedBox(width: 8),
              _buildFilterTab('Found', 'found'),
            ],
          ),
        ),

        // ── Reports Stream ───────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<ItemModel>>(
            stream: _fs.getUserItems(uid),
builder: (context, snapshot) {
  if (snapshot.hasError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Failed to load reports:\n${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                );
              }

              final all = snapshot.data ?? [];
              final filtered = all.where((item) {
                if (_selectedTab == 'all') return true;
                return item.type.toLowerCase() == _selectedTab;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 56, color: AppTheme.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _selectedTab == 'all'
                            ? 'No reports published yet'
                            : 'No ${_selectedTab.toUpperCase().substring(0, 1) + _selectedTab.substring(1)} reports found',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportItemScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Publish New Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                        ),
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
                  final item = filtered[index];
                  return _MyReportCard(
                    item: item,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditItemScreen(item: item),
                        ),
                      );
                    },
                    onDelete: () => _showDeleteDialog(item),
                    onToggleStatus: () => _toggleStatus(item),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

// ── Report Card ─────────────────────────────────────────────────────────────

class _MyReportCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _MyReportCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(itemId: item.id),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _fallbackThumb(),
                      )
                    : _fallbackThumb(),
              ),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${item.type.toUpperCase().substring(0, 1) + item.type.substring(1)} • ${item.location}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(item.date),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isLost
                    ? AppTheme.errorColor.withOpacity(0.12)
                    : AppTheme.successColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.isLost ? 'Lost' : 'Found',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      item.isLost ? AppTheme.errorColor : AppTheme.successColor,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderLight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    item.isResolved
                        ? Icons.replay_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  label: Text(
                    item.isResolved ? 'Reopen' : 'Mark Resolved',
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.primaryTeal),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.errorColor),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      color: AppTheme.surfaceLight,
      child: Center(
        child: Icon(
          item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
          color: AppTheme.textHint,
          size: 26,
        ),
      ),
    );
  }
}
