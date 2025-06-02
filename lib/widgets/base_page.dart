import 'package:flutter/material.dart';

import 'custom_app_bar.dart';
import 'drawer_menu.dart';

/// Uygulamadaki tüm sayfaların türetebileceği temel sayfa.
///
/// * Üstte ortak `CustomAppBar`.
/// * Solda ortak `DrawerMenu`.
/// * Gövde (`content`) parametre olarak alınır.
class BasePage extends StatelessWidget {
  final String title;
  final Widget content;

  const BasePage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),
      drawer: const DrawerMenu(),
      body: content,
    );
  }
} 