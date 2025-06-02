import 'package:flutter/material.dart';

/// Uygulamanın her sayfasında ortak şekilde kullanılacak özel **AppBar**.
///
/// Gereksinimlere göre sağ tarafta ayar (settings) butonu/ikonu bulunur ve
/// tıklandığında `/settings` rotasına yönlendirir.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;

  const CustomAppBar({super.key, required this.title, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: const Icon(Icons.settings),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 