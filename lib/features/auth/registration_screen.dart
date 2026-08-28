import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Registration screen with a multi-field form for new users.
/// Creates Firebase Auth user + stores Firestore profile on success.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes for keyboard traversal
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _rollFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _selectedDepartment;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _rollFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      SnackbarUtils.showWarning(context, 'Please select your department');
      return;
    }

    if (!_termsAccepted) {
      SnackbarUtils.showWarning(
        context,
        'Please accept the terms and conditions',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Step 1: Create Firebase Auth user
    final authSuccess = await authProvider.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!authSuccess) {
      SnackbarUtils.showError(context, authProvider.errorMessage);
      return;
    }

    // Step 2: Store user profile in Firestore
    final uid = authProvider.currentUser?.uid;
    if (uid == null) {
      SnackbarUtils.showError(context, 'Registration error. Please try again.');
      return;
    }

    final now = DateTime.now();
    final user = UserModel(
      uid: uid,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment!,
      rollNumber: _rollController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final profileSuccess = await userProvider.createUser(user);

    if (!mounted) return;

    if (profileSuccess) {
      SnackbarUtils.showSuccess(context, 'Welcome to Campus Lost & Found! 🎉');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      SnackbarUtils.showError(
        context,
        userProvider.errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final isLoading = authProvider.isLoading || userProvider.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Creating account...',
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

                // ── Scrollable Form ──────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildPersonalSection(),
                          const SizedBox(height: 16),
                          _buildAcademicSection(),
                          const SizedBox(height: 16),
                          _buildSecuritySection(),
                          const SizedBox(height: 20),
                          _buildTermsRow(),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: 'Create Account',
                            onPressed: _onRegister,
                            isLoading: isLoading,
                            prefixIcon: Icons.person_add_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildLoginLink(),
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
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppTheme.textPrimary,
          ),
          const Expanded(
            child: Text(
              'Create Account',
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Join Campus\nLost & Found',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fill in your details to get started',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    int delay = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Form(
        key: _formKey,
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
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: delay.ms,
          duration: 500.ms,
        );
  }

  Widget _buildPersonalSection() {
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
          _SectionTitle(icon: Icons.person_outline_rounded, title: 'Personal Info'),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Full Name',
            hint: 'e.g. Rahul Sharma',
            controller: _nameController,
            prefixIcon: Icons.badge_outlined,
            validator: Validators.fullName,
            textInputAction: TextInputAction.next,
            focusNode: _nameFocus,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocus),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Email Address',
            hint: 'your@email.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.next,
            focusNode: _emailFocus,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_phoneFocus),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Phone Number',
            hint: '9876543210',
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
            textInputAction: TextInputAction.next,
            focusNode: _phoneFocus,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_rollFocus),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 500.ms);
  }

  Widget _buildAcademicSection() {
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
          _SectionTitle(icon: Icons.school_outlined, title: 'Academic Details'),
          const SizedBox(height: 16),
          // Department Dropdown
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            onChanged: (val) => setState(() => _selectedDepartment = val),
            dropdownColor: AppTheme.darkCard,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Department',
              prefixIcon: const Icon(Icons.apartment_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
              ),
              filled: true,
              fillColor: AppTheme.darkCard,
            ),
            items: AppConstants.departments
                .map(
                  (dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(dept, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            hint: const Text(
              'Select department',
              style: TextStyle(color: AppTheme.textHint, fontSize: 14),
            ),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Roll Number',
            hint: 'e.g. CS2021001',
            controller: _rollController,
            prefixIcon: Icons.tag_rounded,
            validator: Validators.rollNumber,
            textInputAction: TextInputAction.next,
            focusNode: _rollFocus,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocus),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms);
  }

  Widget _buildSecuritySection() {
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
          _SectionTitle(icon: Icons.security_outlined, title: 'Security'),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            hint: 'Min. 6 characters',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: Validators.password,
            textInputAction: TextInputAction.next,
            focusNode: _passwordFocus,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_confirmFocus),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: (val) => Validators.confirmPassword(
              _passwordController.text,
            )(val),
            textInputAction: TextInputAction.done,
            focusNode: _confirmFocus,
            onFieldSubmitted: (_) => _onRegister(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, delay: 300.ms, duration: 500.ms);
  }

  Widget _buildTermsRow() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _termsAccepted,
            onChanged: (val) => setState(() => _termsAccepted = val ?? false),
            activeColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppTheme.darkBorder, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppTheme.primaryTeal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}

// ── Section Title Helper ───────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
