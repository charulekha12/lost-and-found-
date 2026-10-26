import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';

/// Manage Users Screen for Admin.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirestoreService _fs = FirestoreService.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
          'Manage Users',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ───────────────────────────────────────────
            Container(
              color: AppTheme.cardWhite,
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppTheme.textHint, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, roll no...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppTheme.textHint,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Users Stream ─────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fs.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load users: ${snapshot.error}'),
                    );
                  }

                  final allUsers = snapshot.data ?? [];
                  final q = _searchController.text.trim().toLowerCase();
                  final filtered = allUsers.where((u) {
                    if (q.isEmpty) return true;
                    final name = (u['fullName'] ?? '').toString().toLowerCase();
                    final email = (u['email'] ?? '').toString().toLowerCase();
                    final roll = (u['rollNumber'] ?? '').toString().toLowerCase();
                    final dept = (u['department'] ?? '').toString().toLowerCase();
                    return name.contains(q) ||
                        email.contains(q) ||
                        roll.contains(q) ||
                        dept.contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      final name = u['fullName'] ?? 'Campus User';
                      final email = u['email'] ?? '';
                      final roll = u['rollNumber'] ?? '';
                      final dept = u['department'] ?? '';
                      final role = (u['role'] ?? 'student').toString().toLowerCase();
                      final isAdmin = role == 'admin';

                      return Container(
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
                                color: isAdmin
                                    ? const Color(0xFF8B5CF6).withOpacity(0.15)
                                    : AppTheme.primaryTeal.withOpacity(0.12),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty
                                      ? name.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: isAdmin
                                        ? const Color(0xFF8B5CF6)
                                        : AppTheme.primaryTeal,
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isAdmin)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B5CF6)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Admin',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF8B5CF6),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  if (dept.isNotEmpty || roll.isNotEmpty)
                                    Text(
                                      '$dept ${roll.isNotEmpty ? '• $roll' : ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppTheme.textHint,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

