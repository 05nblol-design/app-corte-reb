import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _integerFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 0,
  );

  static final NumberFormat _decimalFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  static final NumberFormat _percentFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '%',
    decimalDigits: 2,
  );

  /// Formata números inteiros com separador de milhar pt-BR (ex: 10582 -> "10.582")
  static String formatInteger(num? value) {
    if (value == null) return '--';
    return _integerFormatter.format(value).trim();
  }

  /// Formata números decimais pt-BR (ex: 12.34 -> "12,34")
  static String formatDecimal(num? value) {
    if (value == null) return '--';
    return _decimalFormatter.format(value).trim();
  }

  /// Formata percentual com % ao final (ex: 4.52 -> "4,52%", ou com 1 casa decimal se necessário)
  static String formatPercent(num? value, {bool includeSymbol = true, int decimalDigits = 2}) {
    if (value == null) return '--';
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: includeSymbol ? '%' : '',
      decimalDigits: decimalDigits,
    );
    final formatted = formatter.format(value).trim();
    return includeSymbol ? '$formatted%' : formatted;
  }

  /// Formata data/hora brasileira
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String formatDate(DateTime time) {
    return DateFormat('dd/MM/yyyy').format(time);
  }
}
