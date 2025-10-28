import 'dart:convert';
import 'package:cashtrack/features/auth/data/auth_service.dart';
import 'package:cashtrack/features/auth/presentation/login_screen.dart';
import 'package:cashtrack/features/dashboard/data/income_service.dart';
import 'package:cashtrack/features/dashboard/presentation/transactions_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IncomesDashboardScreen extends StatefulWidget {
  const IncomesDashboardScreen({super.key});

  @override
  State<IncomesDashboardScreen> createState() => _IncomesDashboardScreenState();
}

class _IncomesDashboardScreenState extends State<IncomesDashboardScreen> {
  List<dynamic> incomes = [];
  bool loading = true;
  bool error = false;
  final String baseUrl = 'https://cash-track-api-production.up.railway.app';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.checkTokenExpiryProactively(context);
    });
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.loadTokenIfNeeded(context);
      final headers = auth.authHeaders;

      final res = await http.get(Uri.parse('$baseUrl/incomes'), headers: headers);
      if (res.statusCode != 200) throw Exception('Erro ao carregar entradas');

      setState(() {
        incomes = (jsonDecode(res.body) as List)
          ..sort((a, b) => DateTime.parse(b["dateCreated"])
              .compareTo(DateTime.parse(a["dateCreated"])));
        loading = false;
      });
    } catch (e) {
      debugPrint('Erro: $e');
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  // === Diálogo de criação/edição ===
  void _showIncomeDialog({Map<String, dynamic>? income}) {
    final labelCtrl = TextEditingController(text: income?['incomeLabel'] ?? '');
    final valueCtrl = TextEditingController(
        text: income?['value']?.toString() ?? '');
    String selectedType = income?['type'] ?? 'SALARY';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF201D1E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      income == null ? 'Nova entrada' : 'Editar entrada',
                      style: const TextStyle(
                        color: Color(0xFFC0B7B1),
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelCtrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Color(0xFF8E6E53),
                  decoration: _inputDecoration('Descrição'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Color(0xFF8E6E53),
                  decoration: _inputDecoration('Valor'),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return InputDecorator(
                      decoration: _inputDecoration('Tipo de entrada'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          dropdownColor: const Color(0xFF2A2728),
                          style: const TextStyle(color: Color(0xFFC0B7B1)),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'SALARY', child: Text('Salário')),
                            DropdownMenuItem(value: 'EXTRA', child: Text('Extra')),
                            DropdownMenuItem(value: 'GIFT', child: Text('Presente')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setStateDialog(() => selectedType = v);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E6E53),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final auth = Provider.of<AuthService>(context, listen: false);
                          final service = IncomeService(auth);
                          try {
                            if (income == null) {
                              await service.create(
                                labelCtrl.text.trim(),
                                double.tryParse(valueCtrl.text.trim()) ?? 0.0,
                                selectedType,
                              );
                            } else {
                              await service.update(
                                income['id'],
                                labelCtrl.text.trim(),
                                double.tryParse(valueCtrl.text.trim()) ?? 0.0,
                                selectedType,
                              );
                            }
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(income == null
                                    ? '✅ Entrada criada com sucesso!'
                                    : '✅ Entrada atualizada!'),
                              ));
                              _loadIncomes();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('❌Erro ao salvar entrada. Tente novamente mais tarde.')));
                          }
                        },
                        child: Text(
                          income == null ? 'Salvar' : 'Atualizar',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Deletar entrada ===
  Future<void> _deleteIncome(Map<String, dynamic> income) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = IncomeService(auth);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF201D1E),
        title: const Text('Excluir entrada',
            style: TextStyle(color: Color(0xFFC0B7B1))),
        content: Text('Deseja realmente excluir "${income['incomeLabel']}"?',
            style: const TextStyle(color: Color(0xFFC0B7B1))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Excluir', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.delete(income['id']);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('🗑️ Entrada excluída com sucesso!')));
        _loadIncomes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌Erro ao excluir. Tente novamente mais tarde.')));
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8E6E53)),
          borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFF2A2728),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkSecondaryBg = Color(0xFF201D1E);
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryHighlight = Color(0xFF8E6E53);
    const incomeColor = Color(0xFF4B8A08);

    return Scaffold(
      backgroundColor: darkMainBg,
      appBar: AppBar(
        backgroundColor: darkSecondaryBg,
        elevation: 0,
        title: const Text(
          "Entradas",
          style: TextStyle(
            color: darkFontColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: darkSecondaryHighlight),
            onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await auth.logout(context);
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: darkSecondaryHighlight),
            )
          : error
              ? const Center(
                  child: Text(
                    'Erro ao carregar dados',
                    style: TextStyle(color: darkFontColor),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        _DashboardCard(
                          title: "Entradas",
                          totalLabel: "Total de Entradas",
                          totalValue:
                              "R\$ ${incomes.fold<double>(0, (sum, e) => sum + (e['value'] ?? 0)).toStringAsFixed(2)}",
                          color: incomeColor,
                          highlightColor: darkSecondaryHighlight,
                          items: incomes,
                          onAdd: () => _showIncomeDialog(),
                          onEdit: (item) => _showIncomeDialog(income: item),
                          onDelete: (item) => _deleteIncome(item),
                        ),
                        const SizedBox(height: 24),
                        // 👇 Gráfico de evolução das entradas
                        TransactionsChart(
                          transactions: incomes,
                          title: "Evolução das Entradas",
                          accentColor: incomeColor,
                          isIncome: true,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// === Reuso do componente de card ===
class _DashboardCard extends StatelessWidget {
  final String title;
  final String totalLabel;
  final String totalValue;
  final Color color;
  final Color highlightColor;
  final List<dynamic> items;
  final Function()? onAdd;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(Map<String, dynamic>)? onDelete;

  const _DashboardCard({
    required this.title,
    required this.totalLabel,
    required this.totalValue,
    required this.color,
    required this.highlightColor,
    required this.items,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryBg = Color(0xFF201D1E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkSecondaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text("$totalLabel: $totalValue",
                style: const TextStyle(color: darkFontColor, fontSize: 15)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text("Adicionar Novo",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: highlightColor.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onAdd,
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Registros",
                style: TextStyle(
                    color: darkFontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text("Nenhum registro encontrado",
                style: TextStyle(color: darkFontColor),
                textAlign: TextAlign.center)
          else
            Column(
              children: items.map((item) {
                final label = item["incomeLabel"] ?? "-";
                final value = (item["value"] ?? 0).toStringAsFixed(2);
                final type = item["type"] ?? "-";
                DateTime? createdAt;
                String createdAtText = '-';
                try {
                  final raw = item["dateCreated"] as String?;
                  if (raw != null && raw.isNotEmpty) {
                    createdAt = DateTime.parse(raw);
                    createdAtText = DateFormat('dd/MM/yyyy').format(createdAt.toLocal());
                  }
                } catch (_) {
                  // mantém '-' caso parsing falhe
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: highlightColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho com nome e valor
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: darkFontColor,
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                "R\$ $value",
                                style: TextStyle(
                                  color: color,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: Colors.white60),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  createdAtText,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Tipo e botões
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (onEdit != null)
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => onEdit!(item),
                                    ),
                                  if (onDelete != null)
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => onDelete!(item),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
