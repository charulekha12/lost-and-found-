import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../core/services/firestore_service.dart';
import '../models/item_model.dart';
import '../widgets/loading_overlay.dart';
import 'items/item_details_screen.dart';

/// Report Item Screen (supports both Lost and Found) matching Findora design.
class ReportItemScreen extends StatefulWidget {
  final String initialType; // 'lost' or 'found'

  const ReportItemScreen({super.key, this.initialType = 'lost'});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _fs = FirestoreService.instance;

  late String _selectedType;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  Uint8List? _imageBytes;
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics',
    'Bags',
    'Books',
    'Accessories',
    'ID Cards & Keys',
    'Clothing',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType.toLowerCase();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isLost => _selectedType == 'lost';

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close sheet
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick photo: $e')),
      );
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
                'Add Item Photo',
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
              if (_imageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppTheme.errorColor),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: AppTheme.errorColor)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _imageBytes = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              surface: AppTheme.cardWhite,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user is logged in. Please log in first.';

      final userProfile = await _fs.getUserProfile(user.uid);
      final userName =
          userProfile?['fullName'] ?? user.displayName ?? 'Campus Student';
      final userPhone = userProfile?['phone'] ?? '';

      final itemId = _fs.generateItemId();
      String imageUrl = '';

      if (_imageBytes != null) {
        try {
          imageUrl = await _fs.uploadItemImageBytes(
            itemId: itemId,
            bytes: _imageBytes!,
          );
        } catch (storageErr) {
          debugPrint('Storage upload note: $storageErr');
        }
      }

      final newItem = ItemModel(
        id: itemId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: _locationController.text.trim(),
        date: _selectedDate,
        type: _selectedType,
        imageUrl: imageUrl,
        userId: user.uid,
        userName: userName,
        userPhone: userPhone,
        userEmail: user.email ?? '',
        createdAt: DateTime.now(),
        status: 'active',
      );

      await _fs.createItem(newItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLost
                ? 'Lost item report published! Hope it gets found soon.'
                : 'Found item report published! Thank you for your honesty.',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Navigate to details of newly created item
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ItemDetailsScreen(itemId: itemId, initialItem: newItem),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isLost ? 'Report Lost Item' : 'Report Found Item';

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Submitting report...',
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
            titleText,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type Switcher Pill ───────────────────────────────
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypeOption('Lost', 'lost'),
                        _buildTypeOption('Found', 'found'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Photo Upload Area ────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerSheet,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.borderMedium,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: AppTheme.primaryTeal,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo\n(Optional)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_imageBytes != null) ...[
                      const SizedBox(width: 14),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _imageBytes!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageBytes = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // ── Item Name * ──────────────────────────────────────
                _buildLabel('Item Name *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Enter item name',
                  prefixIcon: Icons.title_rounded,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Item name is required' : null,
                ),

                const SizedBox(height: 18),

                // ── Category * ───────────────────────────────────────
                _buildLabel('Category *'),
                const SizedBox(height: 8),
                _buildCategoryDropdown(),

                const SizedBox(height: 18),

                // ── Description * ────────────────────────────────────
                _buildLabel('Description *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Description is required'
                      : null,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter description',
                    hintStyle: GoogleFonts.poppins(
                      color: AppTheme.textHint,
                      fontSize: 13,
                    ),
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

                const SizedBox(height: 18),

                // ── Location * ───────────────────────────────────────
                _buildLabel(_isLost ? 'Last Seen Location *' : 'Location *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hint: 'Enter location',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Location is required' : null,
                ),

                const SizedBox(height: 18),

                // ── Date * ───────────────────────────────────────────
                _buildLabel(_isLost ? 'Date Lost *' : 'Date Found *'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd-MM-yyyy').format(_selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Submit Report Button ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Report',
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

  Widget _buildTypeOption(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryNavy : AppTheme.textSecondary,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      onChanged: (val) => setState(() => _selectedCategory = val),
      dropdownColor: AppTheme.cardWhite,
      style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Select category',
        hintStyle: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 13),
        prefixIcon: const Icon(Icons.category_outlined,
            size: 20, color: AppTheme.textSecondary),
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
      items: _categories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
          .toList(),
    );
  }
}
