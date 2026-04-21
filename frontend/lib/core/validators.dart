class Validators {

  // 📧 EMAIL VALIDATION
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "Email required";
    }

    if (!RegExp(r"^[\w\.-]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(v)) {
      return "Invalid email format";
    }

    return null;
  }

  // 🔐 PASSWORD VALIDATION (STRONG RULES)
  static String? password(String? v) {
    if (v == null || v.isEmpty) {
      return "Password required";
    }

    if (v.length < 6) {
      return "Min 6 chars required";
    }

    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return "At least 1 uppercase required";
    }

    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return "At least 1 number required";
    }

    return null;
  }

  // 👤 NAME VALIDATION
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "Name required";
    }

    if (v.trim().length < 3) {
      return "Name too short";
    }

    return null;
  }

  // 📱 PHONE VALIDATION (optional but professional apps use it)
  static String? phone(String? v) {
    if (v == null || v.isEmpty) {
      return "Phone required";
    }

    if (!RegExp(r'^\d{10,15}$').hasMatch(v)) {
      return "Invalid phone number";
    }

    return null;
  }

  // 🔁 CONFIRM PASSWORD (IMPORTANT FIX)
  static String? confirmPassword(String password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return "Confirm password required";
    }

    if (password != confirm) {
      return "Passwords do not match";
    }

    return null;
  }
}