import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _livingPlaceController = TextEditingController();

  DateTime? _selectedBirthDate;

  void _signup() async {
    final name = _usernameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final birthPlace = _birthPlaceController.text.trim();
    final livingPlace = _livingPlaceController.text.trim();

    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty || birthPlace.isEmpty || livingPlace.isEmpty || _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifreler uyuşmuyor')));
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      final user = cred.user!;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'surname': surname,
        'birth_date': DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
        'birth_place': birthPlace,
        'living_place': livingPlace,
        'profile_picture_url': user.photoURL ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Firebase user kaydı başarılı!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Firebase user kaydı başarılı!')),
      );

      // SUPABASE user_profiles tablosuna ekle/güncelle (hata yönetimi try-catch ile)
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('user_profiles').insert({
          'firebase_uid': user.uid,
          'email': email,
          'name': name,
          'surname': surname,
          'birth_date': DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
          'birth_place': birthPlace,
          'living_place': livingPlace,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('🟢 Supabase user_profiles kaydı başarılı!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🟢 Supabase user_profiles kaydı başarılı!')),
        );
      } catch (e) {
        print('🔴 Supabase HATASI: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🔴 Supabase kayıt hatası: $e')),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Hata oluştu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person_add,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Yeni Hesap Oluştur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Ad',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        labelText: 'Soyad',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Şifre (Tekrar)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _birthPlaceController,
                      decoration: InputDecoration(
                        labelText: 'Doğum Yeri',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _livingPlaceController,
                      decoration: InputDecoration(
                        labelText: 'Yaşadığı Şehir',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(now.year - 18),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) {
                          setState(() => _selectedBirthDate = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Doğum Tarihi',
                            prefixIcon: const Icon(Icons.calendar_today),
                            hintText: _selectedBirthDate == null
                                ? 'YYYY-AA-GG'
                                : DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Zaten hesabın var mı? Giriş Yap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
