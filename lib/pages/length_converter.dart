import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LengthConverterPage extends StatefulWidget {
  const LengthConverterPage({super.key});

  @override
  State<LengthConverterPage> createState() => _LengthConverterPageState();
}

class _LengthConverterPageState extends State<LengthConverterPage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> units = [
    'mm',
    'cm',
    'dm',
    'm',
    'dam',
    'hm',
    'km',
    'inç',
    'ft',
  ];

  final Map<String, double> unitToMeter = {
    'mm': 0.001,
    'cm': 0.01,
    'dm': 0.1,
    'm': 1.0,
    'dam': 10.0,
    'hm': 100.0,
    'km': 1000.0,
    'inç': 0.0254,
    'ft': 0.3048,
  };

  String _inputUnit = 'm';
  late Map<String, bool> _targetUnits;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
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

    double valueInMeters = input * unitToMeter[_inputUnit]!;

    List<String> tempResults = [];
    _targetUnits.forEach((unit, isSelected) {
      if (isSelected) {
        double converted = valueInMeters / unitToMeter[unit]!;
        tempResults.add('${converted.toStringAsFixed(3)} $unit');
        // Supabase'e kaydet
        saveConversionHistory(
          conversionType: 'length',
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
    // uzunluk ikonu: metre görseli
    return Future.value(
        'https://cdn-icons-png.flaticon.com/512/335/335648.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Uzunluk Dönüştürücü'),
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