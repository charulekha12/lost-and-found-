import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../../widgets/loading_overlay.dart';

/// Edit Report screen matching Findora design.
class EditItemScreen extends StatefulWidget {
  final ItemModel item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _fs = FirestoreService.instance;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  Uint8List? _newImageBytes;
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
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _locationController = TextEditingController(text: widget.item.location);
    _selectedType = widget.item.type;
    _selectedCategory = widget.item.category;
    _selectedDate = widget.item.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
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
        setState(() => _newImageBytes = bytes);
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
                'Change Photo',
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
              surface: AppTheme.cardWhite,
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

  Future<void> _updateReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.item.imageUrl;

      if (_newImageBytes != null) {
        try {
          imageUrl = await _fs.uploadItemImageBytes(
            itemId: widget.item.id,
            bytes: _newImageBytes!,
          );
        } catch (uploadErr) {
          debugPrint('Upload error notice: $uploadErr');
        }
      }

      final updateData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'type': _selectedType,
        'date': _selectedDate,
        'imageUrl': imageUrl,
      };

      await _fs.updateItem(widget.item.id, updateData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update report: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Updating report...',
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
            'Edit Report',
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
                // ── Photo Preview & Change ───────────────────────────
                GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _newImageBytes != null
                              ? Image.memory(
                                  _newImageBytes!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                )
                              : widget.item.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.item.imageUrl,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image, size: 48),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 48,
                                      color: AppTheme.textHint,
                                    ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Change Photo',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Item Name * ──────────────────────────────────────
                _buildLabel('Item Name *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Enter item name',
                  prefixIcon: Icons.title_rounded,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Item name is required'
                      : null,
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
                _buildLabel('Location *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hint: 'Enter location',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Location is required'
                      : null,
                ),

                const SizedBox(height: 18),

                // ── Date * ───────────────────────────────────────────
                _buildLabel('Date *'),
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

                // ── Update Report Button ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update Report',
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
      value: _categories.contains(_selectedCategory)
          ? _selectedCategory
          : _categories.first,
      onChanged: (val) => setState(() => _selectedCategory = val!),
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
