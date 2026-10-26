import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/claim_model.dart';
import '../../models/item_model.dart';

/// Notifications / Activity screen matching Findora design.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final fs = FirestoreService.instance;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Please log in to view notifications'))
          : StreamBuilder<List<ClaimModel>>(
              stream: fs.getUserClaims(uid),
              builder: (context, claimSnap) {
                return StreamBuilder<List<ItemModel>>(
                  stream: fs.getUserItems(uid),
                  builder: (context, itemSnap) {
                    final claims = claimSnap.data ?? [];
                    final items = itemSnap.data ?? [];

                    final List<_NotificationItem> notifications = [];

                    // Generate activity from user claims
                    for (var claim in claims) {
                      if (claim.isApproved) {
                        notifications.add(_NotificationItem(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppTheme.successColor,
                          title: 'Claim Approved',
                          message:
                              'Your claim for ${claim.itemTitle} has been approved.',
                          timeAgo: 'Recently',
                        ));
                      } else if (claim.isRejected) {
                        notifications.add(_NotificationItem(
                          icon: Icons.cancel_rounded,
                          iconColor: AppTheme.errorColor,
                          title: 'Claim Update',
                          message:
                              'Your claim for ${claim.itemTitle} was reviewed.',
                          timeAgo: 'Recently',
                        ));
                      }
                    }

                    // Generate activity from user items
                    for (var item in items) {
                      if (item.isResolved) {
                        notifications.add(_NotificationItem(
                          icon: Icons.assignment_turned_in_rounded,
                          iconColor: AppTheme.primaryTeal,
                          title: 'Item Returned',
                          message:
                              'Your item (${item.title}) has been marked returned.',
                          timeAgo: 'Recently',
                        ));
                      }
                    }

                    // System notifications
                    notifications.add(_NotificationItem(
                      icon: Icons.notifications_active_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Welcome to Findora',
                      message:
                          'Campus Lost & Found is live. Report items anytime.',
                      timeAgo: '1d ago',
                    ));

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: notif.iconColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(notif.icon,
                                    color: notif.iconColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          notif.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          notif.timeAgo,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppTheme.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.message,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String timeAgo;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.timeAgo,
  });
}

