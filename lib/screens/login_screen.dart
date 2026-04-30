import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  List<Map<String, dynamic>> _stores = [];
  String? _selectedStoreId;

  bool _loading = false;
  bool _loadingStores = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchStores() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('stores').get();
      setState(() {
        _stores = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loadingStores = false;
      });
    } catch (_) {
      setState(() => _loadingStores = false);
    }
  }

  Future<void> _login() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (_selectedStoreId == null) {
      setState(() => _error = 'Please select your store');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final driverId =
        List.generate(16, (_) => Random().nextInt(16).toRadixString(16)).join();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_name', name);
    await prefs.setString('driver_store_id', _selectedStoreId!);
    await prefs.setString('driver_id', driverId);

    try {
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
        'name': name,
        'storeId': _selectedStoreId,
        'status': 'available',
        'registeredAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => HomeScreen(
        driverName: name,
        storeId: _selectedStoreId!,
        driverId: driverId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Brand header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.brand,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.brandShadow(),
                    ),
                    child: const Icon(Icons.delivery_dining_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MR COD',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 2,
                          )),
                      const Text('Driver Portal',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          )),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text('Start Your Shift',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  )),
              const SizedBox(height: 8),
              const Text('Enter your details to begin delivering',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),

              const SizedBox(height: 36),

              // Name field
              _label('Your Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
                decoration: AppTheme.inputDecoration('e.g. Ahmed Karimi'),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 24),

              // Store picker
              _label('Your Store'),
              const SizedBox(height: 8),
              _loadingStores
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.brand, strokeWidth: 2))
                  : Column(
                      children: _stores.map((store) {
                        final isSelected = _selectedStoreId == store['id'];
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedStoreId = store['id'];
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.brandLight
                                  : AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.brand
                                    : AppTheme.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? AppTheme.brandShadow()
                                  : AppTheme.cardShadow(),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.storefront_rounded,
                                    color: isSelected
                                        ? AppTheme.brand
                                        : AppTheme.textMuted,
                                    size: 20),
                                const SizedBox(width: 12),
                                Text(store['name'] ?? store['id'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppTheme.brand
                                          : AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    )),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppTheme.brand, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              if (_error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.brandLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.brand.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ],

              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brand,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.brand.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Start Shift',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          )),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 1.2,
      ));
}
