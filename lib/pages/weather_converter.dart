import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drawer_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeatherConverterPage extends StatefulWidget {
  const WeatherConverterPage({super.key});

  @override
  State<WeatherConverterPage> createState() => _WeatherConverterPageState();
}

class _WeatherConverterPageState extends State<WeatherConverterPage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> units = ['Celsius', 'Kelvin', 'Fahrenheit'];
  String _inputUnit = 'Celsius';
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
        _results = ['Geçerli bir sıcaklık değeri girin!'];
      });
      return;
    }

    double valueInCelsius;

    // Önce değeri °C'ye çevir
    switch (_inputUnit) {
      case 'Celsius':
        valueInCelsius = input;
        break;
      case 'Kelvin':
        valueInCelsius = input - 273.15;
        break;
      case 'Fahrenheit':
        valueInCelsius = (input - 32) * 5 / 9;
        break;
      default:
        valueInCelsius = input;
    }

    List<String> tempResults = [];
    _targetUnits.forEach((unit, selected) {
      if (selected) {
        double converted;
        switch (unit) {
          case 'Celsius':
            converted = valueInCelsius;
            break;
          case 'Kelvin':
            converted = valueInCelsius + 273.15;
            break;
          case 'Fahrenheit':
            converted = (valueInCelsius * 9 / 5) + 32;
            break;
          default:
            converted = valueInCelsius;
        }
        tempResults.add('${converted.toStringAsFixed(2)} °$unit');
        // Supabase'e kaydet
        saveConversionHistory(
          conversionType: 'temperature',
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
        'https://cdn-icons-png.flaticon.com/512/15301/15301838.png'); // bulutlu güneşli simge
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sıcaklık Dönüştürücü'),
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
                labelText: 'Sıcaklık',
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