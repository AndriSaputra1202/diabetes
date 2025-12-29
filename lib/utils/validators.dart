// Utility class untuk form validation
//// Menyediakan berbagai validator untuk input form di aplikasi

class Validators {
  static String? validateEmail(String? value) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    // Regex untuk validasi email
    // Format: username@domain.extension
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    // Check null atau kosong
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    // Check panjang minimum
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }

    return null;
  }

  static String? validateStrongPassword(String? value) {
    // Check null atau kosong
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    // Check panjang minimum
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    // Check harus ada huruf besar
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar';
    }

    // Check harus ada huruf kecil
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil';
    }

    // Check harus ada angka
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }

    return null;
  }

  // Validate password confirmation
  // Returns: String? error message atau null jika valid
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }

    if (value != password) {
      return 'Password tidak sama';
    }

    return null;
  }

  //NAME VALIDATOR

  // Validate name
  // Returns: String? error message atau null jika valid
  static String? validateName(String? value, {int minLength = 3}) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi';
    }

    // Check panjang minimum
    if (value.trim().length < minLength) {
      return 'Nama minimal $minLength karakter';
    }

    // Check tidak boleh angka saja
    if (RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Nama tidak boleh angka saja';
    }

    // Check harus mengandung huruf
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Nama harus mengandung huruf';
    }

    return null;
  }

  //NUMBER VALIDATORS

  //Validate apakah input berupa angka
  // Parameters:
  // - value: String yang akan divalidasi
  // Returns: String? error message atau null jika valid
  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Harus berupa angka';
    }

    return null;
  }

  /// Validate age
  ///
  /// Parameters:
  /// - value: Umur yang akan divalidasi
  /// - minAge: Umur minimum (default: 1)
  /// - maxAge: Umur maksimum (default: 120)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateAge(
    String? value, {
    int minAge = 1,
    int maxAge = 120,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Umur wajib diisi';
    }

    // Check apakah angka
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Umur harus berupa angka';
    }

    // Check range
    if (age < minAge || age > maxAge) {
      return 'Umur harus antara $minAge-$maxAge tahun';
    }

    return null;
  }

  /// Validate weight (berat badan)
  ///
  /// Parameters:
  /// - value: Berat badan yang akan divalidasi
  /// - minWeight: Berat minimum (default: 20 kg)
  /// - maxWeight: Berat maksimum (default: 300 kg)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateWeight(
    String? value, {
    double minWeight = 20,
    double maxWeight = 300,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Berat badan wajib diisi';
    }

    // Check apakah angka
    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Berat badan harus berupa angka';
    }

    // Check range
    if (weight < minWeight || weight > maxWeight) {
      return 'Berat badan harus antara $minWeight-$maxWeight kg';
    }

    // Check tidak boleh negatif
    if (weight <= 0) {
      return 'Berat badan harus lebih dari 0';
    }

    return null;
  }

  /// Validate height (tinggi badan)
  ///
  /// Parameters:
  /// - value: Tinggi badan yang akan divalidasi
  /// - minHeight: Tinggi minimum (default: 50 cm)
  /// - maxHeight: Tinggi maksimum (default: 250 cm)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateHeight(
    String? value, {
    double minHeight = 50,
    double maxHeight = 250,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Tinggi badan wajib diisi';
    }

    // Check apakah angka
    final height = double.tryParse(value.trim());
    if (height == null) {
      return 'Tinggi badan harus berupa angka';
    }

    // Check range
    if (height < minHeight || height > maxHeight) {
      return 'Tinggi badan harus antara $minHeight-$maxHeight cm';
    }

    // Check tidak boleh negatif
    if (height <= 0) {
      return 'Tinggi badan harus lebih dari 0';
    }

    return null;
  }

  /// Validate blood sugar (gula darah)
  /// Parameters:
  /// - value: Gula darah yang akan divalidasi (mg/dL)
  /// - minValue: Nilai minimum (default: 20 mg/dL)
  /// - maxValue: Nilai maksimum (default: 600 mg/dL)
  /// Returns: String? error message atau null jika valid
  static String? validateBloodSugar(
    String? value, {
    double minValue = 20,
    double maxValue = 600,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Gula darah wajib diisi';
    }

    // Check apakah angka
    final bloodSugar = double.tryParse(value.trim());
    if (bloodSugar == null) {
      return 'Gula darah harus berupa angka';
    }

    // Check range
    if (bloodSugar < minValue || bloodSugar > maxValue) {
      return 'Gula darah harus antara $minValue-$maxValue mg/dL';
    }

    // Check tidak boleh negatif
    if (bloodSugar <= 0) {
      return 'Gula darah harus lebih dari 0';
    }

    return null;
  }

  /// Validate carbs (karbohidrat)
  ///
  /// Parameters:
  /// - value: Karbohidrat yang akan divalidasi (gram)
  /// - minValue: Nilai minimum (default: 0 gram)
  /// - maxValue: Nilai maksimum (default: 1000 gram)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateCarbs(
    String? value, {
    double minValue = 0,
    double maxValue = 1000,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Karbohidrat wajib diisi';
    }

    // Check apakah angka
    final carbs = double.tryParse(value.trim());
    if (carbs == null) {
      return 'Karbohidrat harus berupa angka';
    }

    // Check range
    if (carbs < minValue || carbs > maxValue) {
      return 'Karbohidrat harus antara $minValue-$maxValue gram';
    }

    // Check tidak boleh negatif
    if (carbs < 0) {
      return 'Karbohidrat tidak boleh negatif';
    }

    return null;
  }

  /// Validate calories (kalori)
  /// Parameters:
  /// - value: Kalori yang akan divalidasi
  /// - minValue: Nilai minimum (default: 0)
  /// - maxValue: Nilai maksimum (default: 5000)
  /// Returns: String? error message atau null jika valid
  static String? validateCalories(
    String? value, {
    double minValue = 0,
    double maxValue = 5000,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Kalori wajib diisi';
    }

    // Check apakah angka
    final calories = double.tryParse(value.trim());
    if (calories == null) {
      return 'Kalori harus berupa angka';
    }

    // Check range
    if (calories < minValue || calories > maxValue) {
      return 'Kalori harus antara $minValue-$maxValue kcal';
    }

    // Check tidak boleh negatif
    if (calories < 0) {
      return 'Kalori tidak boleh negatif';
    }

    return null;
  }

  /// Validate food weight (berat makanan)
  ///
  /// Parameters:
  /// - value: Berat makanan yang akan divalidasi (gram)
  /// - minValue: Nilai minimum (default: 1 gram)
  /// - maxValue: Nilai maksimum (default: 10000 gram / 10 kg)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateFoodWeight(
    String? value, {
    double minValue = 1,
    double maxValue = 10000,
  }) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Berat makanan wajib diisi';
    }

    // Check apakah angka
    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Berat makanan harus berupa angka';
    }

    // Check range
    if (weight < minValue || weight > maxValue) {
      return 'Berat makanan harus antara $minValue-$maxValue gram';
    }

    // Check tidak boleh negatif atau 0
    if (weight <= 0) {
      return 'Berat makanan harus lebih dari 0';
    }

    return null;
  }

  // ==================== GENERIC VALIDATORS ====================

  /// Validate required field
  ///
  /// Parameters:
  /// - value: Value yang akan divalidasi
  /// - fieldName: Nama field untuk error message
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    return null;
  }

  /// Validate minimum length
  ///
  /// Parameters:
  /// - value: Value yang akan divalidasi
  /// - minLength: Panjang minimum
  /// - fieldName: Nama field untuk error message
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }

    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }

    return null;
  }

  /// Validate maximum length
  ///
  /// Parameters:
  /// - value: Value yang akan divalidasi
  /// - maxLength: Panjang maksimum
  /// - fieldName: Nama field untuk error message
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }

    return null;
  }

  // ==================== PHONE NUMBER VALIDATOR ====================

  /// Validate phone number (Indonesia)
  ///
  /// Parameters:
  /// - value: Nomor telepon yang akan divalidasi
  ///
  /// Returns: String? error message atau null jika valid
  static String? validatePhoneNumber(String? value) {
    // Check null atau kosong
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }

    // Remove spaces dan dashes
    String cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');

    // Regex untuk format Indonesia
    // Format: 08xx-xxxx-xxxx atau +628xx-xxxx-xxxx atau 628xx-xxxx-xxxx
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');

    if (!phoneRegex.hasMatch(cleanNumber)) {
      return 'Format nomor telepon tidak valid';
    }

    // Check panjang minimum (minimal 10 digit setelah kode negara)
    if (cleanNumber.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    return null;
  }

  // ==================== DATE VALIDATOR ====================

  /// Validate date (tidak boleh tanggal masa depan)
  ///
  /// Parameters:
  /// - value: Tanggal yang akan divalidasi
  ///
  /// Returns: String? error message atau null jika valid
  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal wajib diisi';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Tanggal tidak boleh di masa depan';
    }

    return null;
  }

  /// Validate age from birth date
  ///
  /// Parameters:
  /// - birthDate: Tanggal lahir
  /// - minAge: Umur minimum (default: 1)
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateBirthDate(DateTime? birthDate, {int minAge = 1}) {
    if (birthDate == null) {
      return 'Tanggal lahir wajib diisi';
    }

    if (birthDate.isAfter(DateTime.now())) {
      return 'Tanggal lahir tidak boleh di masa depan';
    }

    // Calculate age
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < minAge) {
      return 'Umur minimal $minAge tahun';
    }

    return null;
  }

  // ==================== CUSTOM VALIDATORS ====================

  /// Validate dropdown selection
  ///
  /// Parameters:
  /// - value: Value yang dipilih
  /// - fieldName: Nama field untuk error message
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateDropdown(dynamic value, String fieldName) {
    if (value == null || value.toString().isEmpty) {
      return '$fieldName wajib dipilih';
    }

    return null;
  }

  /// Validate checkbox (must be checked)
  ///
  /// Parameters:
  /// - value: Status checkbox
  /// - message: Custom error message
  ///
  /// Returns: String? error message atau null jika valid
  static String? validateCheckbox(bool? value, String message) {
    if (value == null || !value) {
      return message;
    }

    return null;
  }

  /// Combine multiple validators
  ///
  /// Parameters:
  /// - value: Value yang akan divalidasi
  /// - validators: List of validator functions
  ///
  /// Returns: String? error message dari validator pertama yang gagal, atau null jika semua valid
  static String? combineValidators(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
