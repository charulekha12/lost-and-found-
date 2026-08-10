import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Help & Support screen with FAQ accordion, contact info cards,
/// and a support request submission form.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  int? _expandedFaqIndex;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = context.read<UserProvider>().user;

      await FirestoreService.instance.submitSupportRequest(
        userId: authProvider.currentUser?.uid ?? 'guest',
        name: user.fullName.isNotEmpty ? user.fullName : 'Anonymous',
        email: user.email.isNotEmpty
            ? user.email
            : (authProvider.currentUser?.email ?? ''),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();
      SnackbarUtils.showSuccess(
        context,
        'Support request submitted! We\'ll get back to you soon.',
      );
    } on FirestoreException catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isSubmitting,
      message: 'Submitting request...',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── App Bar ─────────────────────────────────────
                _buildAppBar(),

                // ── Content ─────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHelpHeader(),
                        const SizedBox(height: 24),
                        _buildContactCards(),
                        const SizedBox(height: 24),
                        _buildFaqSection(),
                        const SizedBox(height: 24),
                        _buildContactForm(),
                        const SizedBox(height: 24),
                        _buildAppVersion(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Help & Support',
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

  Widget _buildHelpHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00B4D8), Color(0xFF005F7A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Find answers in our FAQ or reach out to us directly.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildContactCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.email_outlined,
                label: 'Email',
                value: AppConstants.supportEmail,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ContactCard(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: AppConstants.supportPhone,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ContactCard(
          icon: Icons.location_on_outlined,
          label: 'Office',
          value: AppConstants.supportLocation,
          color: AppTheme.warningColor,
          isWide: true,
        ),
        const SizedBox(height: 10),
        _ContactCard(
          icon: Icons.access_time_rounded,
          label: 'Hours',
          value: AppConstants.supportHours,
          color: AppTheme.accentGreen,
          isWide: true,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: List.generate(
              AppConstants.faqItems.length,
              (i) => _FaqTile(
                question: AppConstants.faqItems[i]['q']!,
                answer: AppConstants.faqItems[i]['a']!,
                isExpanded: _expandedFaqIndex == i,
                isLast: i == AppConstants.faqItems.length - 1,
                onTap: () {
                  setState(() {
                    _expandedFaqIndex = _expandedFaqIndex == i ? null : i;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send a Message',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Subject',
                  hint: 'What is your query about?',
                  controller: _subjectController,
                  prefixIcon: Icons.subject_rounded,
                  validator: Validators.required('Subject'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Message',
                  hint: 'Describe your issue or question...',
                  controller: _messageController,
                  prefixIcon: Icons.message_outlined,
                  validator: Validators.message,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Send Message',
                  onPressed: _onSubmit,
                  isLoading: _isSubmitting,
                  prefixIcon: Icons.send_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        '${AppConstants.appName} v${AppConstants.appVersion}',
        style: const TextStyle(
          color: AppTheme.textHint,
          fontSize: 12,
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

// ── Contact Card ───────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isWide;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Tile ───────────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            isExpanded || isLast ? 0 : 12,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      color: isExpanded
                          ? AppTheme.primaryTeal
                          : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded
                        ? AppTheme.primaryTeal
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
