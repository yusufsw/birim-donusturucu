import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ===============================================================
///  VolumeConverterPage — çevrim dışı hacim dönüştürücü
///  mililitre ⇄ litre ⇄ metreküp ⇄ gallon ⇄ pint
/// ===============================================================
class VolumeConverterPage extends StatefulWidget {
  const VolumeConverterPage({super.key});

  @override
  State<VolumeConverterPage> createState() => _VolumeConverterPageState();
}

class _VolumeConverterPageState extends State<VolumeConverterPage> {
  final TextEditingController _controller = TextEditingController();

  // Kullanılabilir hacim birimleri
  final List<String> units = [
    'mililitre',
    'litre',
    'metreküp',
    'gallon',
    'pint',
  ];

  // Her bir hacim biriminin litre cinsinden katsayısı
  final Map<String, double> unitToLiters = {
    'mililitre': 0.001,
    'litre': 1,
    'metreküp': 1000,
    'gallon': 3.78541,
    'pint': 0.473176,
  };

  String _inputUnit = 'mililitre';
  late Map<String, bool> _targetUnits;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _targetUnits = {for (var u in units) u: false};
  }

  void _convert() {
    final input = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (input == null) {
      setState(() {
        _results = ['Geçerli bir sayı girin!'];
      });
      return;
    }

    // Giriş birimi önce litreye çevrilir
    double valueInLiters = input * unitToLiters[_inputUnit]!;

    // Ardından seçili hedef birimlere dönüştürülür
    List<String> tempResults = [];
    _targetUnits.forEach((unit, selected) {
      if (selected) {
        double converted = valueInLiters / unitToLiters[unit]!;
        tempResults.add('${converted.toStringAsFixed(3)} $unit');
        // Supabase'e kaydet
        saveConversionHistory(
          conversionType: 'volume',
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

  // Sağ üst hacim ikonu
  Future<String> getLogoUrl() async =>
      'https://cdn-icons-png.flaticon.com/512/2983/2983783.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Hacim Dönüştürücü'),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text('Başlangıç Birimi:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _inputUnit,
              items: units
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (value) => setState(() => _inputUnit = value!),
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
                    onChanged: (val) => setState(() => _targetUnits[unit] = val!),
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
            ..._results.map((r) => Text(r, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
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
