import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ExcessBaggageApp());
}

class ExcessBaggageApp extends StatelessWidget {
  const ExcessBaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Fee Estimator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Baggage Fee Calculator' : 'About Application'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  
  String _ticketClass = 'Economy';
  
  double _excessWeight = 0.0;
  double _excessCharge = 0.0;
  double _totalPayable = 0.0;
  bool _hasCalculated = false;

  void _calculateFee() {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      double rate = double.parse(_rateController.text);
      
      double allowance = _ticketClass == 'Economy' ? 20.0 : 40.0;

      setState(() {
        _excessWeight = weight > allowance ? weight - allowance : 0.0;
        _excessCharge = _excessWeight * rate;
        _totalPayable = _excessCharge + (_excessCharge * 0.08);
        _hasCalculated = true;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _weightController.clear();
    _rateController.clear();
    setState(() {
      _ticketClass = 'Economy';
      _excessWeight = 0.0;
      _excessCharge = 0.0;
      _totalPayable = 0.0;
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.indigo[50],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff, color: Color(0xFF1E3A8A)),
                        SizedBox(width: 8),
                        Text(
                          'Excess Baggage Guidelines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Economy Class allowance: 20 kg (X = 20)\n'
                      '• Business Class allowance: 40 kg (X = 40)\n'
                      '• Service Tax: 8% applied automatically\n'
                      'Enter your baggage details below to compute charges.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Checked Baggage Weight (kg)',
                hintText: 'e.g., 25.5',
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter baggage weight.';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Please enter a valid positive number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _ticketClass,
              decoration: InputDecoration(
                labelText: 'Ticket Class',
                prefixIcon: const Icon(Icons.airline_seat_recline_normal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg allowance)')),
                DropdownMenuItem(value: 'Business', child: Text('Business (40 kg allowance)')),
              ],
              onChanged: (value) {
                setState(() {
                  _ticketClass = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Excess Baggage Rate per kg (RM)',
                hintText: 'e.g., 15.00',
                prefixIcon: const Icon(Icons.monetization_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter excess rate per kg.';
                }
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Please enter a valid positive number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateFee,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Fee', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_hasCalculated) ...[
              const Text(
                'Calculation Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildOutputRow('1. Excess Baggage Weight:', '${_excessWeight.toStringAsFixed(1)} kg'),
                      const Divider(height: 24),
                      _buildOutputRow('2. Excess Baggage Charge:', 'RM ${_excessCharge.toStringAsFixed(2)}'),
                      const Divider(height: 24),
                      _buildOutputRow('3. Total Amount Payable (Inc. 8% Tax):', 'RM ${_totalPayable.toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutputRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed from MainAxisAlignment.between
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF1E3A8A) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchGitHub(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/your-username/excess-baggage-app');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open GitHub link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage,
              size: 80,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Excess Baggage Estimator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
          ),
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Author Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person, color: Color(0xFF1E3A8A)),
                    title: Text('Name'),
                    subtitle: Text('MUHAMMAD AMIRUL EZMEER BIN MOHD RAZALI'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.badge, color: Color(0xFF1E3A8A)),
                    title: Text('Matric Number'),
                    subtitle: Text('2024273814'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.school, color: Color(0xFF1E3A8A)),
                    title: Text('Course'),
                    subtitle: Text('CS2515A'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _launchGitHub(context),
            icon: const Icon(Icons.code),
            label: const Text('View GitHub Repository'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            '© 2026 Excess Baggage App. All rights reserved.\nDeveloped for ICT602 - MOBILE TECHNOLOGY AND DEVELOPMENT',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}