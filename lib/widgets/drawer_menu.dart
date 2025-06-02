import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış'),
          content: const Text('Çıkmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Çıkış yapıldı!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                accountName: Text(user?.displayName ?? 'Kullanıcı'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                      ? const Icon(Icons.person, size: 40, color: Colors.blue)
                      : null,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () => _navigate(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Uzunluk'),
            onTap: () => _navigate(context, '/length'),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Ağırlık'),
            onTap: () => _navigate(context, '/weight'),
          ),
          ListTile(
            leading: const Icon(Icons.square_foot),
            title: const Text('Alan'),
            onTap: () => _navigate(context, '/area'),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: const Text('Sıcaklık'),
            onTap: () => _navigate(context, '/weather'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Zaman'),
            onTap: () => _navigate(context, '/time'),
          ),
          ListTile(
            leading: const Icon(Icons.local_drink),
            title: const Text('Hacim'),
            onTap: () => _navigate(context, '/volume'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () => _navigate(context, '/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Çıkış'),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () => _navigate(context, '/profile'),
          ),
        ],
      ),
    );
  }
} 