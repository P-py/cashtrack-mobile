class TypeLabels {
  // Incomes
  static const Map<String, String> labelsPtBr = {
    'SALARY': 'REMUNERAÇÃO',
    'EXTRA' : 'EXTRAS',
    'GIFT'  : 'PRESENTES',
    'MONTHLY_ESSENTIAL' : 'ESSENCIAIS MENSAIS',
    'ENTERTAINMENT'     : 'ENTRETENIMENTO',
    'INVESTMENTS'       : 'INVESTIMENTOS',
    'LONGTIME_PURCHASE' : 'LONGO PRAZO',
  };

  static String labelType(String? code) {
    if (code == null || code.trim().isEmpty) return '-';
    return labelsPtBr[code] ?? code;
  }
}
