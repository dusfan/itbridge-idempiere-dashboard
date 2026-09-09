import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:idempiere_sales_app/features/orders/order_line.dart';
import 'package:idempiere_sales_app/utils/rest_json.dart';

/// Wraps iDempiere's C_Order (Sales Order header).
class MOrder extends ModelBase {
  int? adOrgId;
  int? cBPartnerId;
  int? cDocTypeTargetId;
  int? mWarehouseId;
  int? mPriceListId;
  int? cCurrencyId;
  DateTime dateOrdered;

  String? documentNo;
  String? bpartnerName;
  String? docStatus;
  num? grandTotal;
  List<MOrderLine> lines = [];

  /// Build a new header to POST to `/models/c_order`.
  MOrder.newOrder({
    required this.cBPartnerId,
    required this.cDocTypeTargetId,
    this.adOrgId,
    this.mWarehouseId,
    this.mPriceListId,
    this.cCurrencyId,
    DateTime? dateOrdered,
  }) : dateOrdered = dateOrdered ?? DateTime.now(),
       super({});

  /// Deserializing constructor — passed as the ctor closure to
  /// [IdempiereClient.get]/[getRecord], e.g. `(json) => MOrder(json)`.
  MOrder(Map<String, dynamic> json)
    : dateOrdered = DateTime.now(),
      super(json) {
    _populate(json);
  }

  void _populate(Map<String, dynamic> json) {
    id = json['id'] as int? ?? id;
    documentNo = json['DocumentNo']?.toString();
    final rawDate = json['DateOrdered']?.toString();
    if (rawDate != null) {
      dateOrdered = DateTime.tryParse(rawDate) ?? dateOrdered;
    }
    grandTotal = numOf(json['GrandTotal']);
    docStatus =
        identifierOf(json['DocStatus']) ?? json['DocStatus']?.toString();
    cBPartnerId = idOf(json['C_BPartner_ID']) ?? cBPartnerId;
    bpartnerName = identifierOf(json['C_BPartner_ID']);
    adOrgId = idOf(json['AD_Org_ID']) ?? adOrgId;
    mWarehouseId = idOf(json['M_Warehouse_ID']) ?? mWarehouseId;

    final rawLines = json['C_OrderLine'];
    if (rawLines is List) {
      lines = rawLines
          .whereType<Map<String, dynamic>>()
          .map((l) => MOrderLine(l))
          .toList();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'IsSOTrx': 'Y',
      'C_BPartner_ID': cBPartnerId,
      'C_DocTypeTarget_ID': cDocTypeTargetId,
      'DateOrdered': dateOrdered.toIso8601String().split('T').first,
    };
    if (adOrgId != null) data['AD_Org_ID'] = adOrgId;
    if (mWarehouseId != null) data['M_Warehouse_ID'] = mWarehouseId;
    if (mPriceListId != null) data['M_PriceList_ID'] = mPriceListId;
    if (cCurrencyId != null) data['C_Currency_ID'] = cCurrencyId;
    return data;
  }

  @override
  MOrder fromJson(Map<String, dynamic> json) {
    _populate(json);
    return this;
  }
}
