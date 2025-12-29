import 'package:flutter/material.dart';
import 'package:diabetes/services/auth_service.dart';
import 'package:diabetes/utils/validators.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _gulaPuasaController = TextEditingController();
  final _targetKarboController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedGender = 'Laki-laki';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    _gulaPuasaController.dispose();
    _targetKarboController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final auth = AuthService();

      //Persiapan data user
      final userData = {
        'name': _namaController.text.trim(),
        'age': int.parse(_umurController.text.trim()),
        'gender': _selectedGender,
        'weight': double.parse(_beratController.text.trim()),
        'height': double.parse(_tinggiController.text.trim()),
        'bloodSugar': double.parse(_gulaPuasaController.text.trim()),
        'targetCarbs': double.parse(_targetKarboController.text.trim()),
        'role': 'patient',
      };

      // Register 
      await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        userData,
      );

      if (!mounted) return;
      Navigator.pop(context); 

      // Success logout user yang baru dibuat agar user login ulang
      await auth.signOut();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login dengan akun Anda.'),
          backgroundColor: Color(0xFF009688), // Teal color
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to login screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema warna Pasien 
    const primaryColor = Color(0xFF009688);
    const secondaryColor = Color(0xFF00796B);
    const backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      // Menggunakan SingleChildScrollView sebagai parent utama agar Header ikut ter-scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Lengkapi data diri untuk mulai memantau kesehatan.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ================= FORM SECTION =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Bagian 1: Identitas & Akun 
                    _buildSectionTitle('Identitas & Akun'),
                    _buildCardContainer(
                      children: [
                        _buildTextField(
                          controller: _namaController,
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline,
                          validator: Validators.validateName,
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    //Bagian 2: Data Fisik 
                    _buildSectionTitle('Data Fisik'),
                    _buildCardContainer(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // UMUR (Flex: 2)
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _umurController,
                                label: 'Umur',
                                suffix: 'thn',
                                inputType: TextInputType.number,
                                validator: Validators.validateAge,
                                action: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // GENDER 
                            Expanded(flex: 3, child: _buildGenderDropdown()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _beratController,
                                label: 'Berat',
                                suffix: 'kg',
                                inputType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: Validators.validateWeight,
                                action: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _tinggiController,
                                label: 'Tinggi',
                                suffix: 'cm',
                                inputType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: Validators.validateHeight,
                                action: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    //Bagian 3: Kondisi Kesehatan
                    _buildSectionTitle('Kondisi Kesehatan Awal'),
                    _buildCardContainer(
                      children: [
                        _buildTextField(
                          controller: _gulaPuasaController,
                          label: 'Kadar Gula Puasa',
                          suffix: 'mg/dL',
                          icon: Icons.water_drop_outlined,
                          inputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: Validators.validateBloodSugar,
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _targetKarboController,
                          label: 'Target Karbohidrat',
                          suffix: 'g/hari',
                          icon: Icons.restaurant_menu_outlined,
                          inputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: Validators.validateCarbs,
                          action: TextInputAction.done,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '*Konsultasikan target ini dengan dokter Anda.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    //TOMBOL DAFTAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //HELPER WIDGETS

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    IconData? icon,
    TextInputType inputType = TextInputType.text,
    required String? Function(String?) validator,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.teal[300], size: 22)
            : null,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.teal[300], size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
      ),
      validator: Validators.validatePassword,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      isExpanded: true, // PENTING: Mencegah overflow teks dropdown
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        // Mengurangi padding horizontal agar muat di layar kecil
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      items: ['Laki-laki', 'Perempuan']
          .map(
            (gender) => DropdownMenuItem(
              value: gender,
              child: Text(
                gender,
                overflow: TextOverflow.ellipsis, // Potong jika kepanjangan
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value!),
      validator: (value) => Validators.validateDropdown(value, 'Jenis kelamin'),
    );
  }
}
