import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'delivery_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final String driverName;
  final String storeId;
  final String driverId;

  const HomeScreen({
    super.key,
    required this.driverName,
    required this.storeId,
    required this.driverId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Claim a delivery order
  Future<void> _claimOrder(Map<String, dynamic> order) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order['id'])
          .update({
        'assignedDriverId': widget.driverId,
        'assignedDriverName': widget.driverName,
        'driverClaimedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DeliveryScreen(
          order: order,
          driverId: widget.driverId,
          driverName: widget.driverName,
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to claim order: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Shift?',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18)),
        content: const Text('This will log you out of the driver portal.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brand,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Shift',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Update driver status in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.driverId)
          .update({'status': 'offline'});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Stream<List<Map<String, dynamic>>> _availableOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('storeId', isEqualTo: widget.storeId)
        .where('status', isEqualTo: 'Out for Delivery')
        .where('type', isEqualTo: 'Delivery')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .where((o) =>
                o['assignedDriverId'] == null ||
                o['assignedDriverId'] == '' ||
                o['assignedDriverId'] == widget.driverId)
            .toList());
  }

  Stream<List<Map<String, dynamic>>> _myActiveOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('assignedDriverId', isEqualTo: widget.driverId)
        .where('status', isEqualTo: 'Out for Delivery')
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildHeader(),

            // ── My Active Delivery ───────────────────────────────────────────
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _myActiveOrdersStream(),
              builder: (context, snap) {
                final myOrders = snap.data ?? [];
                if (myOrders.isEmpty) return const SizedBox.shrink();
                return _buildMyActiveSection(myOrders);
              },
            ),

            // ── Available Orders ─────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _availableOrdersStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF2800), strokeWidth: 2),
                    );
                  }
                  final orders = snap.data ?? [];
                  if (orders.isEmpty) return _buildEmptyState();
                  return _buildOrderList(orders);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: const Border(bottom: BorderSide(color: AppTheme.divider)),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.brand,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.brandShadow(),
            ),
            child: const Icon(Icons.delivery_dining_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.driverName,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    )),
                const Text('Driver • On Shift',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          // Status dot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Online',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _logout,
            child: const Icon(Icons.logout_rounded,
                color: AppTheme.textMuted, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMyActiveSection(List<Map<String, dynamic>> orders) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.brandLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_rounded,
                  color: AppTheme.brand, size: 16),
              SizedBox(width: 8),
              Text('YOUR ACTIVE DELIVERY',
                  style: TextStyle(
                    color: AppTheme.brand,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((o) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DeliveryScreen(
                    order: o,
                    driverId: widget.driverId,
                    driverName: widget.driverName,
                  ),
                )),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow(),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${o['orderNumber'] ?? o['id'].toString().substring(0, 6).toUpperCase()}',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Text('Tap to open →',
                          style: TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text('AVAILABLE DELIVERIES',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.brandLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${orders.length}',
                    style: const TextStyle(
                      color: AppTheme.brand,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    )),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: orders.length,
            itemBuilder: (_, i) => _OrderCard(
              key: ValueKey(orders[i]['id']),
              order: orders[i],
              driverId: widget.driverId,
              onClaim: () => _claimOrder(orders[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.two_wheeler_rounded,
              size: 72, color: AppTheme.bgMuted),
          const SizedBox(height: 16),
          Text('No deliveries yet',
              style: GoogleFonts.outfit(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              )),
          const SizedBox(height: 6),
          const Text('Orders marked "Out for Delivery" will appear here',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String driverId;
  final VoidCallback onClaim;

  const _OrderCard({
    super.key,
    required this.order,
    required this.driverId,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber = order['orderNumber'] ??
        order['id'].toString().substring(0, 6).toUpperCase();
    final items = (order['items'] as List<dynamic>? ?? []);
    final address =
        order['deliveryAddress'] ?? order['address'] ?? 'Address not set';
    final total = (order['total'] ?? 0.0).toDouble();
    final isMine = order['assignedDriverId'] == driverId;
    final createdAt = order['createdAt'];
    String timeLabel = '';
    if (createdAt is Timestamp) {
      timeLabel = DateFormat('HH:mm').format(createdAt.toDate());
    } else if (createdAt is String) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) timeLabel = DateFormat('HH:mm').format(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMine ? AppTheme.brand.withValues(alpha: 0.4) : AppTheme.border,
          width: isMine ? 1.5 : 1,
        ),
        boxShadow: isMine ? AppTheme.brandShadow() : AppTheme.cardShadow(),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: isMine ? AppTheme.brandLight : Colors.transparent,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Text('#$orderNumber',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    )),
                if (timeLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(timeLabel,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
                const Spacer(),
                Text('€${total.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    )),
              ],
            ),
          ),

          // Address
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Color(0xFFFF2800), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(address,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),

          // Items summary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              items
                  .take(3)
                  .map((i) => '${i['quantity']}x ${i['name']}')
                  .join(', '),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Claim button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2800),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.two_wheeler_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Take This Delivery',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
