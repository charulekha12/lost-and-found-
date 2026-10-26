import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../items/item_details_screen.dart';

/// Manage Reports Screen for Admin / College Staff.
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _fs = FirestoreService.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Invalid Report?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'As admin, are you sure you want to remove "${item.title}" from Findora?',
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
                  const SnackBar(content: Text('Report deleted by admin.')),
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

  Future<void> _toggleResolve(ItemModel item) async {
    final newStatus = item.isResolved ? 'active' : 'resolved';
    try {
      await _fs.updateItem(item.id, {'status': newStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'resolved'
                ? 'Item marked as returned/reunited.'
                : 'Item marked as active.',
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
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Manage Reports',
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
          unselectedLabelColor: Colors.white60,
          labelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList('all'),
          _buildReportsList('lost'),
          _buildReportsList('found'),
          _buildReportsList('resolved'),
        ],
      ),
    );
  }

  Widget _buildReportsList(String filter) {
    return StreamBuilder<List<ItemModel>>(
      stream: _fs.getAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryTeal),
          );
        }

        final all = snapshot.data ?? [];
        final filtered = all.where((item) {
          if (filter == 'all') return true;
          if (filter == 'lost') return item.isLost && !item.isResolved;
          if (filter == 'found') return item.isFound && !item.isResolved;
          if (filter == 'resolved') return item.isResolved;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 48, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text(
                  'No reports in this category',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
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
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: ListTile(
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
                    width: 54,
                    height: 54,
                    child: item.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _fallbackThumb(item),
                          )
                        : _fallbackThumb(item),
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
                    Text(
                      '${item.type.toUpperCase()} • ${item.location}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'By: ${item.userName} • ${DateFormat('MMM d').format(item.date)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isResolved
                            ? Icons.replay_rounded
                            : Icons.check_circle_outline_rounded,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      tooltip: item.isResolved ? 'Reopen' : 'Mark Returned',
                      onPressed: () => _toggleResolve(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.errorColor, size: 20),
                      tooltip: 'Delete Report',
                      onPressed: () => _showDeleteDialog(item),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fallbackThumb(ItemModel item) {
    return Container(
      color: AppTheme.surfaceLight,
      child: Center(
        child: Icon(
          item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
          color: AppTheme.textHint,
          size: 24,
        ),
      ),
    );
  }
}

