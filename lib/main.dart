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
      title: 'Codex Excess Baggage Estimator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000), 
          primary: const Color(0xFFFF0000),      
          secondary: const Color(0xFF111111),    
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
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
          indicatorColor: const Color(0xFFFF0000).withOpacity(0.15),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.luggage_outlined),
              selectedIcon: Icon(Icons.luggage, color: Color(0xFFFF0000)),
              label: 'Estimator',
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
        _totalPayable = _excessCharge + (_excessCharge * 0.08); // 8% Service Tax
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF111111), Color(0xFFFF0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CodeX Excess Baggage\nEstimator',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Know your fee before you get to the counter.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
                  // Quick Info Pills
                  Row(
                    children: [
                      _buildHeaderInfoPill(Icons.luggage, 'Economy 20 kg'),
                      const SizedBox(width: 8),
                      _buildHeaderInfoPill(Icons.business_center, 'Business 40 kg'),
                      const SizedBox(width: 8),
                      _buildHeaderInfoPill(Icons.receipt_long, '8% tax'),
                    ],
                  ),
                ],
              ),
            ),

            // Form Body
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Ticket Class Segmented Selector
                    const Text('1. Choose your ticket class', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _ticketClass = 'Economy'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _ticketClass == 'Economy' ? const Color(0xFFFF0000) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Economy • 20 kg',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _ticketClass == 'Economy' ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _ticketClass = 'Business'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _ticketClass == 'Business' ? const Color(0xFFFF0000) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Business • 40 kg',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _ticketClass == 'Business' ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Step 2: Weight Input
                    const Text('2. Weigh your checked bag', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.4), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Checked Baggage Weight',
                          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.scale, color: Color(0xFFFF0000)),
                          suffixText: 'kg',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter baggage weight.';
                          if (double.tryParse(value) == null || double.parse(value) < 0) return 'Enter a valid positive number.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Step 3: Excess Rate Input & Presets
                    const Text('3. Set the excess rate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.4), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: TextFormField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Excess Rate per kg',
                          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.monetization_on, color: Color(0xFFFF0000)),
                          suffixText: 'RM',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter rate per kg.';
                          if (double.tryParse(value) == null || double.parse(value) < 0) return 'Enter a valid positive number.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quick Preset Chips
                    Row(
                      children: [
                        _buildRatePresetChip('RM 10/kg', '10'),
                        const SizedBox(width: 8),
                        _buildRatePresetChip('RM 15/kg', '15'),
                        const SizedBox(width: 8),
                        _buildRatePresetChip('RM 20/kg', '20'),
                        const SizedBox(width: 8),
                        _buildRatePresetChip('RM 25/kg', '25'),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _calculateBaggageFee,
                            icon: const Icon(Icons.flight_takeoff, color: Colors.white),
                            label: const Text('Calculate Fee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _resetForm,
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Results Pass Card
                    if (_hasCalculated) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF0000), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Card Header Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF0000),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.flight, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text('BAGGAGE PASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ],
                                  ),
                                  Text(_ticketClass.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                            // Card Body Values
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildResultColumn('BAG WEIGHT', '${double.parse(_weightController.text).toStringAsFixed(1)} kg'),
                                      _buildResultColumn('ALLOWANCE', '${_ticketClass == 'Economy' ? 20 : 40} kg'),
                                      _buildResultColumn('EXCESS', '${_excessWeight.toStringAsFixed(1)} kg', isHighlight: true),
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                                  _buildOutputRow('Excess Baggage Charge:', 'RM ${_excessCharge.toStringAsFixed(2)}', isTotal: false),
                                  const SizedBox(height: 8),
                                  _buildOutputRow('Service Tax (8%):', 'RM ${(_excessCharge * 0.08).toStringAsFixed(2)}', isTotal: false),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                                  _buildOutputRow('Total Amount Payable:', 'RM ${_totalPayable.toStringAsFixed(2)}', isTotal: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfoPill(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatePresetChip(String label, String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _rateController.text = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildResultColumn(String title, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isHighlight ? const Color(0xFFFF0000) : Colors.black87)),
      ],
    );
  }

  Widget _buildOutputRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFFFF0000) : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
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
        title: const Text('About Application', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
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
              child: const Icon(Icons.luggage, size: 64, color: Color(0xFFFF0000)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Author Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF0000))),
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
