import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Edit Profile screen — pre-fills form with existing user data,
/// supports image picker, and updates Firestore on save.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();

  String? _selectedDepartment;
  File? _pickedImageFile;
  bool _isUploadingImage = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _prefillForm();
  }

  void _prefillForm() {
    final user = context.read<UserProvider>().user;
    _nameController.text = user.fullName;
    _phoneController.text = user.phone;
    _rollController.text = user.rollNumber;
    _selectedDepartment = user.department.isNotEmpty ? user.department : null;

    // Detect changes
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _rollController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  // ── Image Picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
        _hasChanges = true;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      SnackbarUtils.showWarning(context, 'Please select your department');
      return;
    }

    final userProvider = context.read<UserProvider>();
    String? newImageUrl;

    // Upload new profile image if picked
    if (_pickedImageFile != null) {
      setState(() => _isUploadingImage = true);
      newImageUrl = await userProvider.uploadProfileImage(_pickedImageFile!);
      setState(() => _isUploadingImage = false);

      if (!mounted) return;
      if (newImageUrl == null) {
        SnackbarUtils.showError(context, userProvider.errorMessage);
        return;
      }
    }

    // Update profile
    final success = await userProvider.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment!,
      rollNumber: _rollController.text.trim(),
      profileImageUrl: newImageUrl,
    );

    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Profile updated successfully!');
      setState(() => _hasChanges = false);
      Navigator.pop(context);
    } else {
      SnackbarUtils.showError(context, userProvider.errorMessage);
    }
  }

  // ── Discard Confirmation ──────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final isLoading = userProvider.isLoading || _isUploadingImage;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.pop(context);
        }
      },
      child: LoadingOverlay(
        isLoading: isLoading,
        message: _isUploadingImage ? 'Uploading photo...' : 'Saving profile...',
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── App Bar ───────────────────────────────────
                  _buildAppBar(isLoading),

                  // ── Form ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Avatar picker
                            _buildAvatarPicker(
                              user.initials,
                              user.profileImageUrl,
                            ),
                            const SizedBox(height: 32),

                            // Personal section
                            _buildFieldCard(
                              title: 'Personal Info',
                              icon: Icons.person_outline_rounded,
                              children: [
                                CustomTextField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                  prefixIcon: Icons.badge_outlined,
                                  validator: Validators.fullName,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 14),
                                CustomTextField(
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: Validators.phone,
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Academic section
                            _buildFieldCard(
                              title: 'Academic Details',
                              icon: Icons.school_outlined,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedDepartment,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedDepartment = val;
                                      _hasChanges = true;
                                    });
                                  },
                                  dropdownColor: AppTheme.darkCard,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Department',
                                    prefixIcon: const Icon(
                                      Icons.apartment_outlined,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.darkBorder),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.darkBorder),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppTheme.primaryTeal,
                                          width: 1.5),
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.darkCard,
                                  ),
                                  items: AppConstants.departments
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(
                                            d,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  hint: const Text(
                                    'Select department',
                                    style: TextStyle(color: AppTheme.textHint),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                CustomTextField(
                                  label: 'Roll Number',
                                  controller: _rollController,
                                  prefixIcon: Icons.tag_rounded,
                                  validator: Validators.rollNumber,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Save button
                            CustomButton(
                              label: 'Save Changes',
                              onPressed: _onSave,
                              isLoading: isLoading,
                              prefixIcon: Icons.save_rounded,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(String initials, String imageUrl) {
    final displayImage = _pickedImageFile != null
        ? FileImage(_pickedImageFile!) as ImageProvider
        : (imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null);

    return Center(
      child: GestureDetector(
        onTap: _showImagePickerOptions,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: displayImage == null ? AppTheme.primaryGradient : null,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: displayImage != null
                    ? Image(image: displayImage, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
            // Camera badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryTeal,
                  border: Border.all(color: AppTheme.darkBackground, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
  }

  Widget _buildFieldCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x1A00B4D8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryTeal, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ── Picker Option ──────────────────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x1A00B4D8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryTeal, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
