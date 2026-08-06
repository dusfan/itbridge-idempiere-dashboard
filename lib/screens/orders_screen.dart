import 'package:flutter/material.dart';
import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../session/auth_session.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import 'create_order_screen.dart';
import 'login_screen.dart';
import 'order_detail_screen.dart';

/// Home screen: card list of the logged-in user's Sales Orders.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<MOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<MOrder>> _load() {
    final filter = FilterBuilder()..addFilter('IsSOTrx', Operators.eq, 'Y');
    return IdempiereClient().get<MOrder>(
      '/models/c_order',
      (json) => MOrder(json),
      filter: filter,
      orderBy: const ['Created desc'],
      top: 50,
    );
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  void _logout() {
    context.read<AuthSession>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openCreateOrder() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
    );
    if (created == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundGradient,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('My Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.navy),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<MOrder>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Could not load orders:\n${snapshot.error}', textAlign: TextAlign.center),
                        ),
                      );
                    }
                    final orders = snapshot.data ?? const <MOrder>[];
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: orders.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(child: Text('No orders yet.')),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return _OrderCard(
                                  order: order,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id!)),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: PrimaryButton(label: 'NEW ORDER', onPressed: _openCreateOrder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(order.documentNo ?? 'Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        subtitle: Text(order.bpartnerName ?? 'BPartner #${order.cBPartnerId ?? '-'}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${(order.grandTotal ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(order.docStatus ?? '', style: const TextStyle(fontSize: 11, color: AppColors.label)),
          ],
        ),
      ),
    );
  }
}
