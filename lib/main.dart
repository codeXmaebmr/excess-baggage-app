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
      title: 'Excess Baggage Estimator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000), // AirAsia Red
          primary: const Color(0xFFFF0000),      // AirAsia Red
          secondary: const Color(0xFF111111),    // Jet Black
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== NAVIGATION BAR SCREEN ====================
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
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFF0000).withOpacity(0.12),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFFFF0000)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info, color: Color(0xFFFF0000)),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME / CALCULATOR SCREEN ====================
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

  void _calculateBaggageFee() {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      double rate = double.parse(_rateController.text);
      
      double allowance = (_ticketClass == 'Economy') ? 20.0 : 40.0;

      setState(() {
        _excessWeight = (weight > allowance) ? (weight - allowance) : 0.0;
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
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000),
                borderRadius: BorderRadius.circular(4),
              ),
              
            ),
            const SizedBox(width: 8),
            const Text(
              'Baggage Estimator',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AirAsia Red Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111111), Color(0xFFFF0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0000).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Baggage Guidelines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Economy Class: 20 kg allowance (X = 20)\n'
                      '• Premium Flatbed / Business: 40 kg allowance (X = 40)\n'
                      '• Includes 8% Government Service Tax',
                      style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Weight Input Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Checked Baggage Weight (kg)',
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.scale, color: Color(0xFFFF0000)),
                    border: InputBorder.none,
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
              ),
              const SizedBox(height: 16),
              
              // Ticket Class Dropdown Card (Clean Box Layout)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _ticketClass,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Ticket Class',
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.airline_seat_recline_normal, color: Color(0xFFFF0000)),
                    border: InputBorder.none,
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
              ),
              const SizedBox(height: 16),
              
              // Rate Input Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: TextFormField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Excess Rate per kg (RM)',
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.monetization_on, color: Color(0xFFFF0000)),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rate per kg.';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Please enter a valid positive number.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculateBaggageFee,
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      label: const Text('Calculate Fee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                        shadowColor: const Color(0xFFFF0000).withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Calculation Results Card
              if (_hasCalculated) ...[
                const Text(
                  'Calculation Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildOutputRow('1. Excess Baggage Weight:', '${_excessWeight.toStringAsFixed(1)} kg', isTotal: false),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      _buildOutputRow('2. Excess Baggage Charge:', 'RM ${_excessCharge.toStringAsFixed(2)}', isTotal: false),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      _buildOutputRow('3. Total Amount Payable (Inc. 8% Tax):', 'RM ${_totalPayable.toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutputRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFFFF0000) : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFFF0000) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ==================== ABOUT SCREEN ====================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchGitHub(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/codeXmaebmr/excess-baggage-app');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Application',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.luggage,
                size: 64,
                color: Color(0xFFFF0000),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Baggage Estimator',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
            ),
            const Text(
              'Version 1.0.0 • Mobile Technology Assignment',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF0000)),
                    ),
                    Divider(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline, color: Color(0xFFFF0000)),
                      title: Text('Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text('MUHAMMAD AMIRUL EZMEER BIN MOHD RAZALI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.badge_outlined, color: Color(0xFFFF0000)),
                      title: Text('Matric Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text('2024273814', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.school_outlined, color: Color(0xFFFF0000)),
                      title: Text('Course', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text('CS2515A', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _launchGitHub(context),
              icon: const Icon(Icons.code, color: Colors.white, size: 20),
              label: const Text('View GitHub Repository', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '© 2026 Mobile Technology Assignment.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
