import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class DeliveryScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String driverId;
  final String driverName;

  const DeliveryScreen({
    super.key,
    required this.order,
    required this.driverId,
    required this.driverName,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Timer? _locationTimer;
  bool _locationSharing = false;
  final _pinCtrl = TextEditingController();
  bool _pinError = false;
  bool _completing = false;
  String? _lastKnownAddress;

  @override
  void initState() {
    super.initState();
    _startLocationSharing();
    _lastKnownAddress = widget.order['deliveryAddress'] ??
        widget.order['address'] ??
        'Address not set';
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _startLocationSharing() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) return;

    setState(() => _locationSharing = true);

    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.order['id'])
            .update({
          'liveLocation': {
            'lat': pos.latitude,
            'lng': pos.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        });
      } catch (_) {}
    });
  }

  Future<void> _openMaps() async {
    final address = Uri.encodeComponent(_lastKnownAddress ?? '');
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _confirmDelivery() async {
    final enteredPin = _pinCtrl.text.trim();
    final expectedPin = widget.order['deliveryPin']?.toString() ?? '';

    if (expectedPin.isNotEmpty && enteredPin != expectedPin) {
      setState(() => _pinError = true);
      return;
    }

    setState(() {
      _completing = true;
      _pinError = false;
    });

    try {
      _locationTimer?.cancel();

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order['id'])
          .update({
        'status': 'Delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
        'liveLocation': FieldValue.delete(),
      });

      // Update driver status back to available
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.driverId)
          .update({'status': 'available'});

      if (!mounted) return;
      _showDeliveredSuccess();
    } catch (e) {
      setState(() => _completing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDeliveredSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Delivered!',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  )),
              const SizedBox(height: 8),
              const Text('Order successfully delivered.\nGreat work! 🚀',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Back to Dashboard',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderNumber = order['orderNumber'] ??
        order['id'].toString().substring(0, 6).toUpperCase();
    final items = (order['items'] as List<dynamic>? ?? []);
    final total = (order['total'] ?? 0.0).toDouble();
    final hasPin = (order['deliveryPin'] ?? '').toString().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border:
                    const Border(bottom: BorderSide(color: AppTheme.divider)),
                boxShadow: AppTheme.cardShadow(),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppTheme.textMuted, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text('Active Delivery',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      )),
                  const Spacer(),
                  if (_locationSharing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppTheme.success, size: 12),
                          SizedBox(width: 5),
                          Text('Live',
                              style: TextStyle(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order number + total
                    Row(
                      children: [
                        Text('#$orderNumber',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            )),
                        const Spacer(),
                        Text('€${total.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Delivery address card
                    GestureDetector(
                      onTap: _openMaps,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.cardShadow(),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.brand.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppTheme.brand, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DELIVERY ADDRESS',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(_lastKnownAddress ?? 'Not set',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded,
                                color: AppTheme.brand, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Items
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: AppTheme.cardShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ORDER ITEMS',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              )),
                          const SizedBox(height: 12),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppTheme.brand,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text('${item['quantity']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(item['name'] ?? '',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          )),
                                    ),
                                    Text(
                                        '€${((item['price'] ?? 0.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        )),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PIN Confirmation
                    const Text('DELIVERY CONFIRMATION',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        )),
                    const SizedBox(height: 10),

                    if (hasPin) ...[
                      const Text(
                          'Ask the customer for their 4-digit PIN to confirm handover.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 12,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '• • • •',
                          hintStyle: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 24,
                            letterSpacing: 12,
                          ),
                          filled: true,
                          fillColor: AppTheme.bgMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color:
                                  _pinError ? AppTheme.brand : AppTheme.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color:
                                  _pinError ? AppTheme.brand : AppTheme.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color:
                                  _pinError ? AppTheme.brand : AppTheme.warning,
                              width: 1.5,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onChanged: (_) => setState(() => _pinError = false),
                      ),
                      if (_pinError) ...[
                        const SizedBox(height: 8),
                        const Text('Incorrect PIN. Ask the customer again.',
                            style: TextStyle(
                                color: Color(0xFFFF2800),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                      const SizedBox(height: 16),
                    ] else ...[
                      const Text('No PIN required for this order.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 16),
                    ],

                    // Confirm Delivered button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _completing ? null : _confirmDelivery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.success.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _completing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 20),
                                  const SizedBox(width: 10),
                                  Text('Confirm Delivered',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      )),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
