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
import '../../widgets/findora_logo.dart';
import '../../widgets/loading_overlay.dart';


/// Findora Registration Screen — light theme, clean form design.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _rollFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _selectedDepartment;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _rollFocus.dispose();
    _phoneFocus.dispose();
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

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Step 1: Create Firebase Auth user
    final authSuccess = await authProvider.signUp(
      email: _emailController.text.trim(),
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
      SnackbarUtils.showSuccess(context, 'Welcome to Findora! 🎉');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      SnackbarUtils.showError(context, userProvider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final isLoading = authProvider.isLoading || userProvider.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Creating your account...',
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppTheme.scaffoldBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const FindoraLogo(size: 48, showText: false),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Join Findora today',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, duration: 400.ms),

                const SizedBox(height: 28),

                // Full Name
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.fullName,
                  textInputAction: TextInputAction.next,
                  onSubmit: () => FocusScope.of(context).requestFocus(_emailFocus),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Email
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                  onSubmit: () => FocusScope.of(context).requestFocus(_rollFocus),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Student ID / Roll No
                _buildLabel('Student ID / Roll No.'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _rollController,
                  focusNode: _rollFocus,
                  hint: 'Enter your student ID',
                  prefixIcon: Icons.badge_outlined,
                  validator: Validators.rollNumber,
                  textInputAction: TextInputAction.next,
                  onSubmit: () => FocusScope.of(context).requestFocus(_phoneFocus),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Department Dropdown
                _buildLabel('Department'),
                const SizedBox(height: 8),
                _buildDropdown().animate().fadeIn(delay: 225.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Password
                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  hint: 'Create a password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                  onSubmit: () => FocusScope.of(context).requestFocus(_confirmFocus),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Confirm Password
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmFocus,
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  validator: (val) =>
                      Validators.confirmPassword(_passwordController.text)(val),
                  textInputAction: TextInputAction.done,
                  onSubmit: _onRegister,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 28),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
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
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 32),
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      onChanged: (val) => setState(() => _selectedDepartment = val),
      dropdownColor: AppTheme.cardWhite,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Select department',
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        prefixIcon: const Icon(Icons.apartment_outlined, size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      items: AppConstants.departments
          .map((dept) => DropdownMenuItem(
                value: dept,
                child: Text(dept, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      validator: (val) =>
          val == null ? 'Please select your department' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    VoidCallback? onSubmit,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.textSecondary),
        suffixIcon: suffixIcon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
      ),
    );
  }
}
