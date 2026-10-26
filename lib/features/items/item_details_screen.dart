import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../claims/claim_item_screen.dart';
import 'edit_item_screen.dart';

/// Item details screen matching Findora design.
class ItemDetailsScreen extends StatefulWidget {
  final String itemId;
  final ItemModel? initialItem;

  const ItemDetailsScreen({
    super.key,
    required this.itemId,
    this.initialItem,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final FirestoreService _fs = FirestoreService.instance;
  bool _isFavorite = false;

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
          'Are you sure you want to delete this report? This cannot be undone.',
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
                Navigator.pop(context);
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

  void _shareItem(ItemModel item) {
    Clipboard.setData(ClipboardData(
      text:
          'Findora Lost & Found: ${item.title} (${item.type.toUpperCase()}) at ${item.location}. Contact via Findora app.',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item summary copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<ItemModel>>(
      stream: _fs.getAllItems(),
      builder: (context, snapshot) {
        ItemModel? item = widget.initialItem;

        if (snapshot.hasData) {
          final found = snapshot.data!.where((i) => i.id == widget.itemId);
          if (found.isNotEmpty) {
            item = found.first;
          }
        }

        if (item == null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppTheme.scaffoldBg,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppTheme.scaffoldBg,
            appBar: AppBar(title: const Text('Item Not Found')),
            body: const Center(child: Text('This report is no longer available.')),
          );
        }

        final isOwner = currentUid != null && currentUid == item.userId;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg,
          appBar: AppBar(
            backgroundColor: AppTheme.cardWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorite ? AppTheme.errorColor : AppTheme.textSecondary,
                ),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
                onPressed: () => _shareItem(item!),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Large Photo Display ───────────────────────────────
                _buildPhotoDisplay(item),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.isLost
                              ? AppTheme.errorColor.withOpacity(0.12)
                              : AppTheme.successColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.isLost ? 'Lost' : 'Found',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.isLost
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Metadata Rows: Category, Location, Date
                      _buildMetaRow(
                        icon: Icons.category_outlined,
                        text: item.category,
                      ),
                      const SizedBox(height: 8),
                      _buildMetaRow(
                        icon: Icons.location_on_outlined,
                        text: item.location,
                      ),
                      const SizedBox(height: 8),
                      _buildMetaRow(
                        icon: Icons.calendar_today_outlined,
                        text: DateFormat('MMMM d, yyyy').format(item.date),
                      ),

                      const SizedBox(height: 24),

                      // Description Section
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          item.description.isNotEmpty
                              ? item.description
                              : 'No description provided.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reported By Section
                      Text(
                        'Reported by',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryTeal.withOpacity(0.12),
                              ),
                              child: Center(
                                child: Text(
                                  item.userName.isNotEmpty
                                      ? item.userName.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.userName.isNotEmpty
                                        ? item.userName
                                        : 'Campus Student',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Student Reporter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwner)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'You',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Button
                      if (isOwner) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditItemScreen(item: item!),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryNavy,
                                  side: const BorderSide(
                                      color: AppTheme.borderMedium, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  minimumSize: const Size(0, 52),
                                ),
                                child: const Text('Edit Report'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showDeleteDialog(item!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  minimumSize: const Size(0, 52),
                                ),
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              if (item!.isFound) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClaimItemScreen(item: item!),
                                  ),
                                );
                              } else {
                                _showContactSheet(item!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              item.isFound ? 'Claim This Item' : 'I Found This Item',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoDisplay(ItemModel item) {
    return Container(
      width: double.infinity,
      height: 260,
      color: AppTheme.surfaceLight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          item.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 260,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                  ),
                  errorWidget: (_, __, ___) => _fallbackImage(item),
                )
              : _fallbackImage(item),
          // Page Indicator Pill
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1/1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(ItemModel item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 8),
          Text(
            'No photo available',
            style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryTeal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showContactSheet(ItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Reporter',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppTheme.primaryTeal),
                title: Text(item.userName.isNotEmpty ? item.userName : 'Student'),
                subtitle: const Text('Reporter Name'),
              ),
              if (item.userEmail.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
                  title: Text(item.userEmail),
                  subtitle: const Text('Email Address'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.userEmail));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied!')),
                      );
                    },
                  ),
                ),
              if (item.userPhone.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppTheme.primaryTeal),
                  title: Text(item.userPhone),
                  subtitle: const Text('Phone Number'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.userPhone));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Phone copied!')),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
