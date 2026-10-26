
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../models/item_model.dart';
import '../items/browse_items_screen.dart';
import '../items/item_details_screen.dart';
import '../report_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _fs = FirestoreService.instance;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF168AAD),
    },
    {
      'name': 'Bags',
      'icon': Icons.backpack_rounded,
      'color': const Color(0xFF7868E6),
    },
    {
      'name': 'Books',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFF4A261),
    },
    {
      'name': 'Accessories',
      'icon': Icons.watch_rounded,
      'color': const Color(0xFF2A9D8F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final fbUser = FirebaseAuth.instance.currentUser;

    final firstName = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().split(' ').first
        : (fbUser?.displayName?.split(' ').first ?? 'there');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryTeal,
          onRefresh: () async {
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              await context.read<UserProvider>().fetchUser(uid: uid);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and profile shortcut.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15324B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Let’s reunite people with their belongings.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF718397),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.userProfile,
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB8E7EF),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: user.profileImageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user.profileImageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _avatarFallback(user.initials),
                                  )
                                : _avatarFallback(user.initials),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 350.ms),

                const SizedBox(height: 22),

                // Findora hero banner.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(21),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF102A43),
                        Color(0xFF087E8B),
                        Color(0xFF16A6B5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF087E8B).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -8,
                        bottom: -12,
                        child: Icon(
                          Icons.travel_explore_rounded,
                          size: 112,
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '✦  FINDORA CAMPUS COMMUNITY',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Lost something?\nLet’s find it together.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 21,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Every item deserves a way home.',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 17),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFB9F3F0),
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Helping our campus, one item at a time',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.06),

                const SizedBox(height: 20),

                // Search shortcut.
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrowseItemsScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFE1EBF2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF168AAD),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search items, keywords...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF91A0AF),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.tune_rounded,
                            color: Color(0xFF718397),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _sectionHeading('What would you like to do?'),
                const SizedBox(height: 13),

                // Report cards.
                Row(
                  children: [
                    Expanded(
                      child: _ReportActionCard(
                        title: 'Report Lost',
                        subtitle: 'I lost an item',
                        icon: Icons.search_rounded,
                        colors: const [
                          Color(0xFF173B60),
                          Color(0xFF285B83),
                        ],
                        onTap: () => _openReport('lost'),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: _ReportActionCard(
                        title: 'Report Found',
                        subtitle: 'I found an item',
                        icon: Icons.inventory_2_rounded,
                        colors: const [
                          Color(0xFF00A6B7),
                          Color(0xFF168AAD),
                        ],
                        onTap: () => _openReport('found'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Claim on my item.
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.claimsOnMyItems,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: const Color(0xFFDDECF2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 49,
                            height: 49,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F7F7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.fact_check_rounded,
                              color: Color(0xFF078B9A),
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Claim on My Item',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF17324B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Review requests for your reported items',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    color: const Color(0xFF77899A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF168AAD),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                _sectionHeading('Quick Categories'),
                const SizedBox(height: 14),

                Row(
                  children: _categories.map((category) {
                    final color = category['color'] as Color;
                    final name = category['name'] as String;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrowseItemsScreen(
                                initialCategory: name,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Icon(
                                  category['icon'] as IconData,
                                  color: color,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF52687B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                // Live community stats.
                StreamBuilder<Map<String, int>>(
                  stream: _fs.getStatsStream(),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ??
                        {'lost': 0, 'found': 0, 'reunited': 0};

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: const Color(0xFFE1EBF2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Lost',
                              stats['lost'] ?? 0,
                              const Color(0xFFE76F78),
                              Icons.search_rounded,
                            ),
                          ),
                          _statDivider(),
                          Expanded(
                            child: _buildStatItem(
                              'Found',
                              stats['found'] ?? 0,
                              const Color(0xFF259B80),
                              Icons.check_circle_outline_rounded,
                            ),
                          ),
                          _statDivider(),
                          Expanded(
                            child: _buildStatItem(
                              'Reunited',
                              stats['reunited'] ?? 0,
                              const Color(0xFF168AAD),
                              Icons.favorite_border_rounded,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeading('Recent Items'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.browseItems,
                      ),
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF078B9A),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                StreamBuilder<List<ItemModel>>(
                  stream: _fs.getActiveItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _emptyItems(
                        'Could not load items right now.',
                        Icons.cloud_off_rounded,
                      );
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return _emptyItems(
                        'No recent reports yet',
                        Icons.inbox_outlined,
                      );
                    }

                    return SizedBox(
                      height: 192,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.take(6).length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 13),
                        itemBuilder: (context, index) =>
                            _RecentItemCard(item: items[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReport(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportItemScreen(initialType: type),
      ),
    );
  }

  Widget _avatarFallback(String initials) {
    return Container(
      color: const Color(0xFFE4F6F8),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty ? initials : 'U',
        style: GoogleFonts.poppins(
          color: const Color(0xFF087E8B),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF17324B),
      ),
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 38,
        color: const Color(0xFFE6EEF3),
      );

  Widget _buildStatItem(
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(height: 5),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF17324B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF718397),
          ),
        ),
      ],
    );
  }

  Widget _emptyItems(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EBF2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF91A0AF)),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF718397),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Ink(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.2),
                blurRadius: 13,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentItemCard extends StatelessWidget {
  final ItemModel item;

  const _RecentItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLost = item.isLost;

    return SizedBox(
      width: 158,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailsScreen(itemId: item.id),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1EBF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 105,
                  width: double.infinity,
                  child: item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imageFallback(isLost),
                          errorWidget: (_, __, ___) =>
                              _imageFallback(isLost),
                        )
                      : _imageFallback(isLost),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF17324B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLost
                                  ? const Color(0xFFFFE9EB)
                                  : const Color(0xFFE2F7EF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              isLost ? 'LOST' : 'FOUND',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: isLost
                                    ? const Color(0xFFD64E61)
                                    : const Color(0xFF218568),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF718397),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback(bool isLost) {
    return Container(
      color: const Color(0xFFEAF4F8),
      alignment: Alignment.center,
      child: Icon(
        isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
        size: 34,
        color: const Color(0xFF7CABB9),
      ),
    );
  }
}
