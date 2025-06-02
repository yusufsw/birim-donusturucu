import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Ayarlar'),
      drawer: DrawerMenu(),
      body: Center(
        child: Text('Ayarlar sayfası (henüz uygulanmadı).'),
      ),
    );
  }
} 