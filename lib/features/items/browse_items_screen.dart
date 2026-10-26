import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../report_item_screen.dart';
import 'item_details_screen.dart';

/// Explore / Browse Items Screen matching the Findora design.
class BrowseItemsScreen extends StatefulWidget {
  final String initialTypeFilter; // 'all', 'lost', 'found'
  final String? initialCategory;

  const BrowseItemsScreen({
    super.key,
    this.initialTypeFilter = 'all',
    this.initialCategory,
  });

  @override
  State<BrowseItemsScreen> createState() => _BrowseItemsScreenState();
}

class _BrowseItemsScreenState extends State<BrowseItemsScreen> {
  final FirestoreService _fs = FirestoreService.instance;
  final TextEditingController _searchController = TextEditingController();

  late String _selectedType;
  late String _selectedCategory;
  String _selectedLocation = 'All';
  String _selectedStatus = 'all'; // 'all', 'active', 'resolved'
  String _sortOrder = 'newest'; // 'newest', 'oldest'

  final List<String> _categories = [
    'All',
    'Electronics',
    'Bags',
    'Books',
    'Accessories',
    'ID Cards & Keys',
    'Clothing',
    'Others',
  ];

  final List<String> _locations = [
    'All',
    'CSE Block',
    'Library',
    'Main Gate',
    'Hostel',
    'Canteen',
    'Sports Ground',
    'Auditorium',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTypeFilter.toLowerCase();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

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
          'Explore',
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filter Controls ─────────────────────────────
            Container(
              color: AppTheme.cardWhite,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  // Search Bar
                  Container(
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
                              hintText: 'Search items...',
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
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(Icons.close_rounded,
                                color: AppTheme.textHint, size: 18),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Type Pills: All | Lost | Found
                  Row(
                    children: [
                      _buildTypePill('All', 'all'),
                      const SizedBox(width: 8),
                      _buildTypePill('Lost', 'lost'),
                      const SizedBox(width: 8),
                      _buildTypePill('Found', 'found'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Filter Chips: Category, Location, Status
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDropdownFilter(
                          label: _selectedCategory == 'All'
                              ? 'Category'
                              : _selectedCategory,
                          isSelected: _selectedCategory != 'All',
                          onTap: _showCategoryPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildDropdownFilter(
                          label: _selectedLocation == 'All'
                              ? 'Location'
                              : _selectedLocation,
                          isSelected: _selectedLocation != 'All',
                          onTap: _showLocationPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildDropdownFilter(
                          label: _selectedStatus == 'all'
                              ? 'Status'
                              : (_selectedStatus == 'active' ? 'Active' : 'Resolved'),
                          isSelected: _selectedStatus != 'all',
                          onTap: _showStatusPicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Sort Row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sortOrder = _sortOrder == 'newest' ? 'oldest' : 'newest';
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Sort by: ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          _sortOrder == 'newest' ? 'Newest' : 'Oldest',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: AppTheme.primaryTeal),
                      ],
                    ),
                  ),
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: _clearAllFilters,
                      child: Text(
                        'Clear filters',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Items List ────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: _fs.getAllItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load items: ${snapshot.error}',
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    );
                  }

                  final allItems = snapshot.data ?? [];
                  final filtered = _applyFilters(allItems);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56, color: AppTheme.textHint),
                          const SizedBox(height: 12),
                          Text(
                            'No items match your filters',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your search or category filter',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _ExploreItemCard(item: item);
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

  bool get _hasActiveFilters =>
      _selectedType != 'all' ||
      _selectedCategory != 'All' ||
      _selectedLocation != 'All' ||
      _selectedStatus != 'all' ||
      _searchController.text.isNotEmpty;

  void _clearAllFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedCategory = 'All';
      _selectedLocation = 'All';
      _selectedStatus = 'all';
      _searchController.clear();
    });
  }

  List<ItemModel> _applyFilters(List<ItemModel> items) {
    return items.where((item) {
      // Type filter
      if (_selectedType != 'all' &&
          item.type.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }

      // Category filter
      if (_selectedCategory != 'All' &&
          !item.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
        return false;
      }

      // Location filter
      if (_selectedLocation != 'All' &&
          !item.location.toLowerCase().contains(_selectedLocation.toLowerCase())) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'all') {
        if (_selectedStatus == 'active' && item.isResolved) return false;
        if (_selectedStatus == 'resolved' && !item.isResolved) return false;
      }

      // Search query
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final title = item.title.toLowerCase();
        final desc = item.description.toLowerCase();
        final loc = item.location.toLowerCase();
        final cat = item.category.toLowerCase();
        if (!title.contains(q) &&
            !desc.contains(q) &&
            !loc.contains(q) &&
            !cat.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => _sortOrder == 'newest'
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));
  }

  Widget _buildTypePill(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceLight,
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

  Widget _buildDropdownFilter({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.12) : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    _showOptionsSheet(
      title: 'Select Category',
      options: _categories,
      selected: _selectedCategory,
      onSelected: (val) => setState(() => _selectedCategory = val),
    );
  }

  void _showLocationPicker() {
    _showOptionsSheet(
      title: 'Select Location',
      options: _locations,
      selected: _selectedLocation,
      onSelected: (val) => setState(() => _selectedLocation = val),
    );
  }

  void _showStatusPicker() {
    _showOptionsSheet(
      title: 'Select Status',
      options: ['all', 'active', 'resolved'],
      selected: _selectedStatus,
      onSelected: (val) => setState(() => _selectedStatus = val),
    );
  }

  void _showOptionsSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderLight),
            ...options.map((opt) {
              final isSel = opt.toLowerCase() == selected.toLowerCase();
              return ListTile(
                title: Text(
                  opt,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    color: isSel ? AppTheme.primaryTeal : AppTheme.textPrimary,
                  ),
                ),
                trailing: isSel
                    ? const Icon(Icons.check_rounded,
                        color: AppTheme.primaryTeal, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(opt);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Explore Item Card ────────────────────────────────────────────────────────

class _ExploreItemCard extends StatelessWidget {
  final ItemModel item;
  const _ExploreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsScreen(itemId: item.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                height: 68,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.surfaceLight,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _fallbackThumb(),
                      )
                    : _fallbackThumb(),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        item.isLost ? Icons.search_rounded : Icons.place_outlined,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${item.type.toUpperCase().substring(0, 1) + item.type.substring(1)} • ${item.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(item.date),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  color: item.isLost ? AppTheme.errorColor : AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
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
          size: 28,
        ),
      ),
    );
  }
}
