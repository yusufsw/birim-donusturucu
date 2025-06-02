import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AreaConverterPage extends StatefulWidget {
  const AreaConverterPage({super.key});

  @override
  State<AreaConverterPage> createState() => _AreaConverterPageState();
}

class _AreaConverterPageState extends State<AreaConverterPage> {
  final TextEditingController _controller = TextEditingController();

  // Kullanılabilir alan birimleri listesi
  final List<String> units = [
    'mm²',
    'cm²',
    'm²',
    'a',
    'ha',
    'km²',
    'in²',
    'ft²',
  ];

  // Her bir birimin metrekareye karşılık gelen katsayısı
  final Map<String, double> unitToSquareMeter = {
    'mm²': 0.000001,
    'cm²': 0.0001,
    'm²': 1.0,
    'a': 100.0,
    'ha': 10000.0,
    'km²': 1e6,
    'in²': 0.00064516,
    'ft²': 0.092903,
  };

  String _inputUnit = 'm²';
  late Map<String, bool> _targetUnits;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    // Tüm hedef birimler başlangıçta seçilmemiş
    _targetUnits = {for (var u in units) u: false};
  }

  void _convert() {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() {
        _results = ['Geçerli bir sayı girin!'];
      });
      return;
    }

    // Giriş değeri önce metrekareye çevrilir
    double valueInSquareMeters = input * unitToSquareMeter[_inputUnit]!;

    List<String> tempResults = [];
    _targetUnits.forEach((unit, isSelected) {
      if (isSelected) {
        double converted = valueInSquareMeters / unitToSquareMeter[unit]!;
        tempResults.add('${converted.toStringAsFixed(3)} $unit');
        // Supabase'e kaydet
        saveConversionHistory(
          conversionType: 'area',
          fromUnit: _inputUnit,
          toUnit: unit,
          fromValue: input,
          toValue: converted,
        );
      }
    });

    setState(() {
      _results = tempResults.isEmpty
          ? ['Lütfen hedef birim(leri) seçin']
          : tempResults;
    });
  }

  Future<String> getLogoUrl() async {
    return Future.value(
      'https://cdn-icons-png.flaticon.com/512/4228/4228892.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Alan Dönüştürücü'),
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
}