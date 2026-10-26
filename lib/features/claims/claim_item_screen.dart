import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/claim_model.dart';
import '../../models/item_model.dart';

/// Claim Item Screen matching Findora design.
class ClaimItemScreen extends StatefulWidget {
  final ItemModel item;

  const ClaimItemScreen({super.key, required this.item});

  @override
  State<ClaimItemScreen> createState() => _ClaimItemScreenState();
}

class _ClaimItemScreenState extends State<ClaimItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _fs = FirestoreService.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _proofController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? '';
      final profile = await _fs.getUserProfile(user.uid);
      if (profile != null) {
        if (profile['fullName'] != null &&
            profile['fullName'].toString().isNotEmpty) {
          _nameController.text = profile['fullName'];
        }
        if (profile['phone'] != null &&
            profile['phone'].toString().isNotEmpty) {
          _phoneController.text = profile['phone'];
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Please log in to submit a claim.';

      if (user.uid == widget.item.userId) {
        throw 'You cannot claim an item that you reported.';
      }

      final claimId = _fs.generateClaimId();
      final claim = ClaimModel(
        id: claimId,
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        itemCategory: widget.item.category,
        itemImageUrl: widget.item.imageUrl,
        itemOwnerId: widget.item.userId,
        claimantId: user.uid,
        claimantName: _nameController.text.trim(),
        claimantEmail: _emailController.text.trim(),
        claimantPhone: _phoneController.text.trim(),
        proofDescription: _proofController.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _fs.submitClaim(claim);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.successColor, size: 28),
              const SizedBox(width: 10),
              Text(
                'Claim Submitted',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Your claim for "${widget.item.title}" has been submitted to the college staff. You will be notified once verified.',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close Claim screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK, Got It'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Claim Item',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // ── Item Summary Banner ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: AppTheme.surfaceLight,
                        child: widget.item.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.item.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.inventory_2_outlined,
                                color: AppTheme.primaryTeal),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Found at: ${widget.item.location}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Proof of Ownership Description ────────────────────
              _buildLabel('Proof of Ownership *'),
              const SizedBox(height: 4),
              Text(
                'Describe identifying features (e.g. scratches, lock screen wallpaper, stickers, serial number, contents inside) that prove this item belongs to you.',
                style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _proofController,
                maxLines: 4,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please provide identifying proof details'
                    : null,
                style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. It has a blue keychain and my ID card is in the front pocket...',
                  hintStyle: GoogleFonts.poppins(
                      color: AppTheme.textHint, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.cardWhite,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryTeal, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Claimant Name ────────────────────────────────────
              _buildLabel('Your Full Name *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Your name',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Contact Phone ────────────────────────────────────
              _buildLabel('Contact Phone Number *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: 'Phone number where you can be reached',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Phone is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Contact Email ────────────────────────────────────
              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'Your email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 36),

              // ── Submit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Claim',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 13),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.cardWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
        ),
      ),
    );
  }
}
