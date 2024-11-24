import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rayvana',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController radiationController = TextEditingController();
  final TextEditingController airTempController = TextEditingController();
  final TextEditingController sunshineController = TextEditingController();
  final TextEditingController hourSinController = TextEditingController();
  final TextEditingController hourCosController = TextEditingController();

  void _showResultsDialog(double result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Text(
                  'Predicted energy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result != 0
                      ? '${result.toStringAsFixed(2)} kWh'
                      : "Loading ...",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA2B00),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _predictSolarPower() async {
    final Map<String, dynamic> data = {
      "Radiation": double.tryParse(radiationController.text) ?? 0,
      "AirTemperature": double.tryParse(airTempController.text) ?? 0,
      "Sunshine": double.tryParse(sunshineController.text) ?? 0,
      "Hour_Sin": double.tryParse(hourSinController.text) ?? 0,
      "Hour_Cos": double.tryParse(hourCosController.text) ?? 0,
    };

    const String apiUrl =
        "https://linear-regression-model-qw86.onrender.com/predict";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final double predictedValue = responseData['prediction'];
        _showResultsDialog(predictedValue);
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorDialog(
            'Error: ${response.statusCode}', responseData['detail'][0]['msg']?.toString() ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorDialog('Failed to connect', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Column(
                  children: [
                    Image.asset(
                      'logo.png',
                      height: 100,
                      width: 360,
                    ),
                    const SizedBox(height: 16),
                  ],
                )),
                const Center(
                    child: Text(
                  'A solar powered Utopia',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEA2B00),
                  ),
                )),
                const SizedBox(height: 24),
                const Center(
                  child: Text('Solar Power Predictor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEA2B00),
                      )),
                ),
                const SizedBox(height: 24),
                _buildInputField('Radiation', radiationController),
                _buildInputField('Air Temperature', airTempController),
                _buildInputField('Sunshine', sunshineController),
                _buildInputField('Hour sin', hourSinController),
                _buildInputField('Hour cos', hourCosController),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _predictSolarPower,
                    child: const Text(
                      'Predict solar power',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    radiationController.dispose();
    airTempController.dispose();
    sunshineController.dispose();
    hourSinController.dispose();
    hourCosController.dispose();
    super.dispose();
  }
}
