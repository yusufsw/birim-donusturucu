import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/base_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _livingPlaceController = TextEditingController();

  DateTime? _birthDate;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('user_profiles')
        .select()
        .eq('firebase_uid', user.uid)
        .maybeSingle();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _surnameController.text = data['surname'] ?? '';
      _birthPlaceController.text = data['birth_place'] ?? '';
      _livingPlaceController.text = data['living_place'] ?? '';
      if ((data['birth_date'] ?? '').toString().isNotEmpty) {
        _birthDate = DateTime.tryParse(data['birth_date']);
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Firestore'da güncelle
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'birth_place': _birthPlaceController.text.trim(),
        'living_place': _livingPlaceController.text.trim(),
        'birth_date': _birthDate != null ? DateFormat('yyyy-MM-dd').format(_birthDate!) : '',
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore profil güncellendi!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Firestore profil güncellendi!')),
      );
    } catch (e) {
      print('❌ Firestore profil güncelleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Firestore profil güncelleme hatası: $e')),
      );
    }

    // 2. Supabase'de güncelle
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('user_profiles').update({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'birth_place': _birthPlaceController.text.trim(),
        'living_place': _livingPlaceController.text.trim(),
        'birth_date': _birthDate != null ? DateFormat('yyyy-MM-dd').format(_birthDate!) : '',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('firebase_uid', user.uid);
      print('🟢 Supabase profil güncellendi!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🟢 Supabase profil güncellendi!')),
      );
    } catch (e) {
      print('🔴 Supabase profil güncelleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔴 Supabase profil güncelleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Profil',
      content: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Ad'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: 'Soyad'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _birthPlaceController,
                      decoration: const InputDecoration(labelText: 'Doğum Yeri'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _livingPlaceController,
                      decoration: const InputDecoration(labelText: 'Yaşadığı Şehir'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime(now.year - 18),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) setState(() => _birthDate = picked);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Doğum Tarihi',
                            hintText: _birthDate == null ? 'Tarih seç' : DateFormat('yyyy-MM-dd').format(_birthDate!),
                          ),
                          validator: (_) => _birthDate == null ? 'Gerekli' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 