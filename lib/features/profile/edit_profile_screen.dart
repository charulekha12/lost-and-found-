import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../widgets/loading_overlay.dart';

/// Edit Profile screen matching Findora design.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();

  Uint8List? _newImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillForm();
  }

  void _prefillForm() {
    final user = context.read<UserProvider>().user;
    final fbUser = FirebaseAuth.instance.currentUser;

    _nameController.text = user.fullName.isNotEmpty
        ? user.fullName
        : (fbUser?.displayName ?? 'Kavitha S');
    _rollController.text =
        user.rollNumber.isNotEmpty ? user.rollNumber : 'CSE202401';
    _departmentController.text = user.department.isNotEmpty
        ? user.department
        : 'Computer Engineering';
    _phoneController.text = user.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close sheet
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _newImageBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to pick image: $e');
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppTheme.primaryTeal),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppTheme.primaryTeal),
                title: const Text('Take a Photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              if (_newImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppTheme.errorColor),
                  title: const Text('Remove Selection',
                      style: TextStyle(color: AppTheme.errorColor)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _newImageBytes = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      String? photoUrl;
      if (_newImageBytes != null) {
        photoUrl =
            await userProvider.uploadProfileImageBytes(_newImageBytes!);
      }

      final success = await userProvider.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
        rollNumber: _rollController.text.trim(),
        profileImageUrl: photoUrl,
      );

      if (!mounted) return;

      if (success) {
        SnackbarUtils.showSuccess(context, 'Profile updated successfully!');
        Navigator.pop(context);
      } else {
        SnackbarUtils.showError(
          context,
          userProvider.errorMessage.isNotEmpty
              ? userProvider.errorMessage
              : 'Failed to update profile.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Error saving profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final email = user.email.isNotEmpty
        ? user.email
        : (FirebaseAuth.instance.currentUser?.email ?? 'kavitha@example.com');

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Saving changes...',
      child: Scaffold(
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
            'Edit Profile',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar with camera badge ─────────────────────────
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          border: Border.all(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _newImageBytes != null
                              ? Image.memory(
                                  _newImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : user.profileImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.profileImageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Center(
                                        child: Text(
                                          user.initials,
                                          style: const TextStyle(
                                            color: AppTheme.primaryTeal,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        user.initials.isNotEmpty
                                            ? user.initials
                                            : 'KS',
                                        style: const TextStyle(
                                          color: AppTheme.primaryTeal,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Display Name ─────────────────────────────────────
                _buildLabel('Display Name *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Enter your name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
                ),

                const SizedBox(height: 18),

                // ── Email (Read-only) ────────────────────────────────
                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined,
                        size: 20, color: AppTheme.textHint),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Student ID ───────────────────────────────────────
                _buildLabel('Student ID'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _rollController,
                  hint: 'e.g. CSE202401',
                  prefixIcon: Icons.badge_outlined,
                ),

                const SizedBox(height: 18),

                // ── Department ───────────────────────────────────────
                _buildLabel('Department'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _departmentController,
                  hint: 'e.g. Computer Engineering',
                  prefixIcon: Icons.apartment_outlined,
                ),

                const SizedBox(height: 18),

                // ── Phone ────────────────────────────────────────────
                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _phoneController,
                  hint: 'e.g. 9876543210',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 36),

                // ── Save Changes Button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Changes',
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
      style: GoogleFonts.poppins(
        color: AppTheme.textPrimary,
        fontSize: 14,
      ),
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
