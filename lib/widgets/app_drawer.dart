import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: fetchLogoUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, size: 48, color: Colors.white);
                    } else {
                      return Image.network(
                        snapshot.data!,
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Birim Dönüştürücü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Uzunluk Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/length'),
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight),
                  title: const Text('Ağırlık Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/weight'),
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Alan Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/area'),
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('Sıcaklık Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/weather'),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Zaman Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/time'),
                ),
                ListTile(
                  leading: const Icon(Icons.local_drink),
                  title: const Text('Hacim Dönüştürücü'),
                  onTap: () => Navigator.pushNamed(context, '/volume'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (Route<dynamic> route) => false,
              );
            },
          ),

        ],
      ),
    );
  }

  Future<String> fetchLogoUrl() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://cdn-icons-png.flaticon.com/512/18995/18995004.png';
  }
}