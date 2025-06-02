import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ana Sayfa'),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Dönüştürmek istediğiniz birimi seçin:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.straighten,
                  label: 'Uzunluk',
                  route: '/length',
                ),
                _buildNavButton(
                  context,
                  icon: Icons.monitor_weight,
                  label: 'Ağırlık',
                  route: '/weight',
                ),
                _buildNavButton(
                  context,
                  icon: Icons.square_foot,
                  label: 'Alan',
                  route: '/area',
                ),
                _buildNavButton(
                  context,
                  icon: Icons.wb_sunny,
                  label: 'Sıcaklık',
                  route: '/weather',
                ),
                _buildNavButton(
                  context,
                  icon: Icons.access_time,
                  label: 'Zaman',
                  route: '/time',
                ),
                _buildNavButton(
                  context,
                  icon: Icons.local_drink,
                  label: 'Hacim',
                  route: '/volume',
                ),

              ],
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Uygulama Hakkında',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              '🔹 Uzunluk: mm, cm, dm, m, km, inç ve ft gibi uzunluk birimlerini birbirine dönüştürür.',
              textAlign: TextAlign.left,
            ),
            const Text(
              '🔹 Ağırlık: g, kg, ton, lb ve oz gibi ağırlık birimleri arasında dönüşüm yapar.',
              textAlign: TextAlign.left,
            ),
            const Text(
              '🔹 Alan: m², cm², hektar, dönüm gibi alan ölçümlerini birbirine çevirir.',
              textAlign: TextAlign.left,
            ),
            const Text(
              '🔹 Sıcaklık: Celsius, Fahrenheit, Kelvin dönüşümleri sağlar.',
              textAlign: TextAlign.left,
            ),
            const Text(
              '🔹 Zaman: saniye, dakika, saat, gün, hafta gibi zaman birimlerini dönüştürür.',
              textAlign: TextAlign.left,
            ),
            const Text(
              '🔹 Döviz: Farklı para birimleri arasında çevrim (USD, EUR, TRY) yapılabilir.',
              textAlign: TextAlign.left,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 30,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}