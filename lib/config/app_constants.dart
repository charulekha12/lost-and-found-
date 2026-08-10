/// App-wide constants for the Campus Lost & Found app.
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────────────────────────
  static const String appName = 'Campus Lost & Found';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Reconnecting campus community';

  // ── Firestore Collections ──────────────────────────────────────
  static const String usersCollection = 'users';
  static const String itemsCollection = 'items';
  static const String supportCollection = 'support_requests';

  // ── Firestore User Fields ──────────────────────────────────────
  static const String fieldUid = 'uid';
  static const String fieldFullName = 'fullName';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldDepartment = 'department';
  static const String fieldRollNumber = 'rollNumber';
  static const String fieldProfileImageUrl = 'profileImageUrl';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // ── Storage Paths ──────────────────────────────────────────────
  static const String profileImagesPath = 'profile_images';

  // ── Validation ─────────────────────────────────────────────────
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxMessageLength = 500;

  // ── UI Dimensions ──────────────────────────────────────────────
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double sectionSpacing = 24.0;

  // ── Animation Durations ────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(milliseconds: 2800);

  // ── FAQ Data ───────────────────────────────────────────────────
  static const List<Map<String, String>> faqItems = [
    {
      'q': 'How do I report a lost item?',
      'a':
          'Go to the Home screen and tap "Report Lost Item". Fill in the details about your item including description, location last seen, and date. You can also add a photo to help identify it.',
    },
    {
      'q': 'How do I report a found item?',
      'a':
          'Go to the Home screen and tap "Report Found Item". Describe the item and where you found it. The owner will be notified if there is a match.',
    },
    {
      'q': 'How do I reset my password?',
      'a':
          'On the Login screen, tap "Forgot Password?". Enter your registered email and we will send you a password reset link.',
    },
    {
      'q': 'Can I edit my profile?',
      'a':
          'Yes! Navigate to your Profile screen and tap the "Edit Profile" button. You can update your name, phone number, department, roll number, and profile picture.',
    },
    {
      'q': 'How will I know if my item is found?',
      'a':
          'You will receive a notification when someone reports an item matching your description. Check the app regularly for matches.',
    },
    {
      'q': 'Is my personal information safe?',
      'a':
          'Yes. We use Firebase Authentication and Firestore with proper security rules. Your data is only visible to authorized users.',
    },
  ];

  // ── Support Contact ────────────────────────────────────────────
  static const String supportEmail = 'support@campuslostfound.edu';
  static const String supportPhone = '+91 98765 43210';
  static const String supportLocation =
      'Student Affairs Office, Main Building';
  static const String supportHours = 'Mon–Fri, 9:00 AM – 5:00 PM';

  // ── Departments ────────────────────────────────────────────────
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Electronics & Communication Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Information Technology',
    'Chemical Engineering',
    'Biotechnology',
    'Physics',
    'Mathematics',
    'Management Studies',
    'Other',
  ];
}
