class ValidationMixin {
  bool validateEmail(String email) {
    RegExp exp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (exp.hasMatch(email)) return true;
    return false;
  }

  bool validatePassword(String password) {
    RegExp exp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (exp.hasMatch(password)) return true;
    return false;
  }

  bool validatePseudo(String pseudo) {
    if (!pseudo.startsWith(" ") && pseudo.isNotEmpty) return true;
    return false;
  }
}
