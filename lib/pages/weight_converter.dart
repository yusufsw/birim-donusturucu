import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightConverterPage extends StatefulWidget {
  const WeightConverterPage({super.key});

  @override
  State<WeightConverterPage> createState() => _WeightConverterPageState();
}

class _WeightConverterPageState extends State<WeightConverterPage> {
  final TextEditingController _controller = TextEditingController();

  // Kullanılabilir ağırlık birimleri listesi
  final List<String> units = ['mg', 'g', 'kg', 'ton', 'lb', 'oz'];

  // Her bir birimin kilogram karşılığı
  final Map<String, double> unitToKg = {
    'mg': 0.000001,
    'g': 0.001,
    'kg': 1,
    'ton': 1000,
    'lb': 0.453592,
    'oz': 0.0283495,
  };

  String _inputUnit = 'kg';
  late Map<String, bool> _targetUnits;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    // Tüm birimler başlangıçta seçilmemiş olarak ayarlanır
    _targetUnits = {for (var u in units) u: false};
  }

  Future<String> getLogoUrl() async {
    // Sayfa başlığı için ikon URL'si
    return Future.value(
        'https://cdn-icons-png.flaticon.com/512/11495/11495676.png');
  }

  Future<void> saveConversionHistory({
    required String conversionType,
    required String fromUnit,
    required String toUnit,
    required double fromValue,
    required double toValue,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('conversion_history').insert({
        'firebase_uid': user.uid,
        'conversion_type': conversionType,
        'from_unit': fromUnit,
        'to_unit': toUnit,
        'from_value': fromValue,
        'to_value': toValue,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('🟢 Supabase conversion_history kaydı başarılı!');
    } catch (e) {
      print('🔴 Supabase conversion_history kaydı hatası: $e');
    }
  }

  // Dönüştürme işlemi yapılır
  void _convert() {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() {
        _results = ['Geçerli bir sayı girin!'];
      });
      return;
    }

    // Giriş birimi önce kilogram cinsine dönüştürülür
    double valueInKg = input * unitToKg[_inputUnit]!;

    List<String> tempResults = [];
    _targetUnits.forEach((unit, selected) {
      if (selected) {
        double converted = valueInKg / unitToKg[unit]!;
        tempResults.add('${converted.toStringAsFixed(3)} $unit');
        // Supabase'e kaydet
        saveConversionHistory(
          conversionType: 'weight',
          fromUnit: _inputUnit,
          toUnit: unit,
          fromValue: input,
          toValue: converted,
        );
      }
    });

    // Sonuçlar ekrana yazdırılır
    setState(() {
      _results = tempResults.isEmpty
          ? ['Lütfen hedef birim(leri) seçin']
          : tempResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ağırlık Dönüştürücü'),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text('Başlangıç Birimi:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _inputUnit,
              items: units
                  .map((unit) =>
                  DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _inputUnit = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Değer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Dönüştürmek İstediğin Birimler:',
                style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _targetUnits.keys.map((unit) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  child: CheckboxListTile(
                    title: Text(unit),
                    value: _targetUnits[unit],
                    onChanged: (value) {
                      setState(() {
                        _targetUnits[unit] = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Dönüştür'),
            ),
            const SizedBox(height: 20),
            const Text('Sonuçlar:', style: TextStyle(fontSize: 18)),
            ..._results
                .map((r) => Text(r, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}