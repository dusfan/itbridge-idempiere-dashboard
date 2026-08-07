import 'package:idempiere_rest/idempiere_rest.dart';

import 'rest_json.dart';

/// Wraps iDempiere's C_OrderLine (Sales Order line item).
class MOrderLine extends ModelBase {
  int? cOrderId;
  int? mProductId;
  int? line;
  num qtyOrdered;
  num priceActual;

  String? productName;
  num? lineNetAmt;

  /// Build a new line to POST to `/models/c_orderline`.
  MOrderLine.newLine({
    required this.cOrderId,
    required this.mProductId,
    required this.qtyOrdered,
    required this.priceActual,
    this.line,
  }) : super({});

  /// Deserializing constructor — passed as the ctor closure to
  /// [IdempiereClient.get]/[getRecord], e.g. `(json) => MOrderLine(json)`.
  MOrderLine(Map<String, dynamic> json)
      : qtyOrdered = 0,
        priceActual = 0,
        super(json) {
    _populate(json);
  }

  void _populate(Map<String, dynamic> json) {
    id = json['id'] as int? ?? id;
    cOrderId = idOf(json['C_Order_ID']) ?? cOrderId;
    mProductId = idOf(json['M_Product_ID']) ?? mProductId;
    productName = identifierOf(json['M_Product_ID']);
    line = json['Line'] is int ? json['Line'] as int : int.tryParse('${json['Line']}') ?? line;
    qtyOrdered = numOf(json['QtyOrdered']) ?? qtyOrdered;
    priceActual = numOf(json['PriceActual']) ?? priceActual;
    lineNetAmt = numOf(json['LineNetAmt']);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'C_Order_ID': cOrderId,
      'M_Product_ID': mProductId,
      'QtyOrdered': qtyOrdered,
      'QtyEntered': qtyOrdered,
      'PriceEntered': priceActual,
      'PriceActual': priceActual,
    };
    if (line != null) data['Line'] = line;
    return data;
  }

  @override
  MOrderLine fromJson(Map<String, dynamic> json) {
    _populate(json);
    return this;
  }
}
