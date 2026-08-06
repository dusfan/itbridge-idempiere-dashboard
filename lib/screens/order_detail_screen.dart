import 'package:flutter/material.dart';
import 'package:idempiere_rest/idempiere_rest.dart';

import '../models/order.dart';
import '../theme.dart';

/// GET /models/c_order/{id}?$expand=C_OrderLine — fetches the order header
/// and its lines in one call.
class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<MOrder?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<MOrder?> _load() {
    final expand = ExpandBuilder()..expand('C_OrderLine');
    return IdempiereClient().getRecord<MOrder>(
      '/models/c_order',
      widget.orderId,
      (json) => MOrder(json),
      expand: expand,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundGradient,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: FutureBuilder<MOrder?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Could not load order:\n${snapshot.error}', textAlign: TextAlign.center),
                  ),
                );
              }
              final order = snapshot.data;
              if (order == null) {
                return const Center(child: Text('Order not found.'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          order.documentNo ?? 'Order #${order.id}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.bpartnerName ?? 'BPartner #${order.cBPartnerId}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Status: ${order.docStatus ?? '-'}', style: const TextStyle(color: AppColors.label)),
                        const SizedBox(height: 4),
                        Text('Grand Total: \$${(order.grandTotal ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        const Text('Lines', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: order.lines.isEmpty
                        ? const Center(child: Text('No lines.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: order.lines.length,
                            itemBuilder: (context, index) {
                              final line = order.lines[index];
                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(line.productName ?? 'Product #${line.mProductId}'),
                                  subtitle: Text('Qty ${line.qtyOrdered}  ×  \$${line.priceActual}'),
                                  trailing: Text(
                                    '\$${(line.lineNetAmt ?? (line.qtyOrdered * line.priceActual)).toStringAsFixed(2)}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
