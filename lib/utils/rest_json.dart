/// iDempiere REST returns foreign-key/list columns as either a plain scalar
/// (typically on write echoes) or an object `{propertyLabel, id, identifier,
/// model-name}` (on normal reads). These helpers accept either shape so
/// model `fromJson`/populate logic doesn't have to guess.
int? idOf(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is Map) return value['id'] as int?;
  return int.tryParse(value.toString());
}

String? identifierOf(dynamic value) {
  if (value is Map) return value['identifier']?.toString();
  return null;
}

num? numOf(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}
