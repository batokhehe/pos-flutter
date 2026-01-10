import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

final formatCurrency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

int parseIntCurrency(String text) {
  return int.tryParse(
        text.replaceAll('.', ''),
      ) ??
      0;
}

class ThousandsInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final cleaned = newValue.text.replaceAll('.', '');
    final value = int.tryParse(cleaned);
    if (value == null) return oldValue;

    final formatted = formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
