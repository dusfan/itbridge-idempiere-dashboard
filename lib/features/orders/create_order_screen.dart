import 'package:flutter/material.dart';
import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:provider/provider.dart';

import 'order.dart';
import 'order_line.dart';
import '../auth/auth_session.dart';
import '../../core/theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class _PendingLine {
  final int productId;
  final num qty;
  final num price;
  _PendingLine(this.productId, this.qty, this.price);
}

/// Builds a Sales Order header, then adds each line as a separate REST
/// call (POST c_order, then POST c_orderline per line referencing the
/// new header's id).
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _bpartnerController = TextEditingController();
  final _docTypeController = TextEditingController();
  final _priceListController = TextEditingController();
  final _currencyController = TextEditingController();

  final _productController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  DateTime _dateOrdered = DateTime.now();
  late final TextEditingController _dateController = TextEditingController(text: _formatDate(_dateOrdered));

  final List<_PendingLine> _lines = [];
  bool _submitting = false;
  String? _error;

  static String _formatDate(DateTime d) => d.toIso8601String().split('T').first;

  @override
  void dispose() {
    _bpartnerController.dispose();
    _docTypeController.dispose();
    _priceListController.dispose();
    _currencyController.dispose();
    _productController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOrdered,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateOrdered = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _addLine() {
    final productId = int.tryParse(_productController.text.trim());
    final qty = num.tryParse(_qtyController.text.trim());
    final price = num.tryParse(_priceController.text.trim());
    if (productId == null || qty == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product, quantity and price must be valid numbers.')),
      );
      return;
    }
    setState(() {
      _lines.add(_PendingLine(productId, qty, price));
      _productController.clear();
      _qtyController.text = '1';
      _priceController.clear();
    });
  }

  Future<void> _submit() async {
    final bpartnerId = int.tryParse(_bpartnerController.text.trim());
    final docTypeId = int.tryParse(_docTypeController.text.trim());
    final priceListText = _priceListController.text.trim();
    final currencyText = _currencyController.text.trim();
    final priceListId = priceListText.isEmpty ? null : int.tryParse(priceListText);
    final currencyId = currencyText.isEmpty ? null : int.tryParse(currencyText);

    if (bpartnerId == null || docTypeId == null) {
      setState(() => _error = 'Business Partner and Doc Type IDs are required.');
      return;
    }
    if (_lines.isEmpty) {
      setState(() => _error = 'Add at least one order line.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final session = context.read<AuthSession>().session;
      final header = MOrder.newOrder(
        cBPartnerId: bpartnerId,
        cDocTypeTargetId: docTypeId,
        adOrgId: session?.organizationId,
        mWarehouseId: session?.warehouseId,
        mPriceListId: priceListId,
        cCurrencyId: currencyId,
        dateOrdered: _dateOrdered,
      );

      final created = await IdempiereClient().post<MOrder>('/models/c_order', header);

      var lineNo = 10;
      for (final pending in _lines) {
        final line = MOrderLine.newLine(
          cOrderId: created.id,
          mProductId: pending.productId,
          qtyOrdered: pending.qty,
          priceActual: pending.price,
          line: lineNo,
        );
        await IdempiereClient().post<MOrderLine>('/models/c_orderline', line);
        lineNo += 10;
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const Text('New Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(label: 'Business Partner ID', controller: _bpartnerController, keyboardType: TextInputType.number),
                      AppTextField(label: 'Doc Type (Target) ID', controller: _docTypeController, keyboardType: TextInputType.number),
                      AppTextField(label: 'Date Ordered', controller: _dateController, readOnly: true, onTap: _pickDate),
                      AppTextField(label: 'Price List ID (optional)', controller: _priceListController, keyboardType: TextInputType.number),
                      AppTextField(label: 'Currency ID (optional)', controller: _currencyController, keyboardType: TextInputType.number),
                      const Divider(height: 32),
                      const Text('Order Lines', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(label: 'Product ID', controller: _productController, keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: AppTextField(label: 'Qty', controller: _qtyController, keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: AppTextField(label: 'Price', controller: _priceController, keyboardType: TextInputType.number)),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _addLine,
                          icon: const Icon(Icons.add, color: AppColors.navy),
                          label: const Text('ADD LINE', style: TextStyle(color: AppColors.navy)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._lines.asMap().entries.map((entry) {
                        final i = entry.key;
                        final line = entry.value;
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            title: Text('Product #${line.productId}  ·  Qty ${line.qty}  ·  \$${line.price}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => setState(() => _lines.removeAt(i)),
                            ),
                          ),
                        );
                      }),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: PrimaryButton(label: 'CREATE ORDER', onPressed: _submit, loading: _submitting),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
