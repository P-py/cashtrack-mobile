import 'dart:convert';
import 'package:cashtrack_mobile/components/main_navigation.dart';
import 'package:cashtrack_mobile/features/auth/data/auth_service.dart';
import 'package:cashtrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:cashtrack_mobile/features/dashboard/data/expense_service.dart';
import 'package:cashtrack_mobile/features/dashboard/data/income_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? account;
  Map<String, dynamic>? balance;
  List<dynamic> incomes = [];
  List<dynamic> expenses = [];
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
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.loadTokenIfNeeded(context);
      final headers = auth.authHeaders;

      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/users/account'), headers: headers),
        http.get(Uri.parse('$baseUrl/users/balance'), headers: headers),
        http.get(Uri.parse('$baseUrl/incomes'), headers: headers),
        http.get(Uri.parse('$baseUrl/expenses'), headers: headers),
      ]);

      if (responses.any((r) => r.statusCode != 200)) {
        throw Exception('Erro em uma das requisições');
      }

      setState(() {
        account = jsonDecode(responses[0].body);
        balance = jsonDecode(responses[1].body);

        incomes =
            (jsonDecode(responses[2].body) as List)..sort(
              (a, b) => DateTime.parse(
                b["dateCreated"],
              ).compareTo(DateTime.parse(a["dateCreated"])),
            );

        expenses =
            (jsonDecode(responses[3].body) as List)..sort(
              (a, b) => DateTime.parse(
                b["dateCreated"],
              ).compareTo(DateTime.parse(a["dateCreated"])),
            );

        loading = false;
      });
    } catch (e, stack) {
      debugPrint('[STACK] $stack');
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  // Modal para criar ou editar uma entrada
  void _showIncomeDialog({Map<String, dynamic>? income}) {
    final labelCtrl = TextEditingController(text: income?['incomeLabel'] ?? '');
    final valueCtrl = TextEditingController(
      text: income?['value']?.toString() ?? '',
    );
    String selectedType = income?['type'] ?? 'SALARY';

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFF201D1E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
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
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo descrição
                    TextField(
                      controller: labelCtrl,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Color(0xFF8E6E53),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E6E53),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2728),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo valor
                    TextField(
                      controller: valueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Color(0xFF8E6E53),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E6E53),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2728),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown tipo
                    StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tipo de entrada',
                            labelStyle: const TextStyle(
                              color: Color(0xFFC0B7B1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF8E6E53),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2728),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedType,
                              dropdownColor: const Color(0xFF2A2728),
                              style: const TextStyle(color: Color(0xFFC0B7B1)),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'SALARY',
                                  child: Text('Salário'),
                                ),
                                DropdownMenuItem(
                                  value: 'EXTRA',
                                  child: Text('Extra'),
                                ),
                                DropdownMenuItem(
                                  value: 'GIFT',
                                  child: Text('Presente'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setStateDialog(() {
                                    selectedType = v;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E6E53),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final auth = Provider.of<AuthService>(
                                context,
                                listen: false,
                              );
                              final service = IncomeService(auth);
                              try {
                                if (income == null) {
                                  await service.create(
                                    labelCtrl.text.trim(),
                                    double.tryParse(valueCtrl.text.trim()) ??
                                        0.0,
                                    selectedType,
                                  );
                                } else {
                                  await service.update(
                                    income['id'],
                                    labelCtrl.text.trim(),
                                    double.tryParse(valueCtrl.text.trim()) ??
                                        0.0,
                                    selectedType,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        income == null
                                            ? '✅ Entrada criada com sucesso!'
                                            : '✅ Entrada atualizada!',
                                      ),
                                    ),
                                  );
                                  _loadDashboardData();
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('❌Erro ao criar novo registro. Tente novamente mais tarde.')),
                                );
                              }
                            },
                            child: Text(
                              income == null ? 'Salvar' : 'Atualizar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
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

  void _showExpenseDialog({Map<String, dynamic>? expense}) {
    final labelCtrl = TextEditingController(text: expense?['expenseLabel'] ?? '');
    final valueCtrl = TextEditingController(
      text: expense?['value']?.toString() ?? '',
    );
    String selectedType = expense?['type'] ?? 'MONTHLY_ESSENTIAL';

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFF201D1E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          expense == null ? 'Nova despesa' : 'Editar despesa',
                          style: const TextStyle(
                            color: Color(0xFFC0B7B1),
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo descrição
                    TextField(
                      controller: labelCtrl,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Color(0xFF8E6E53),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E6E53),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2728),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo valor
                    TextField(
                      controller: valueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Color(0xFF8E6E53),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: const TextStyle(color: Color(0xFFC0B7B1)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E6E53),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2728),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown tipo
                    StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tipo de despesa',
                            labelStyle: const TextStyle(
                              color: Color(0xFFC0B7B1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF8E6E53),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2728),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedType,
                              dropdownColor: const Color(0xFF2A2728),
                              style: const TextStyle(color: Color(0xFFC0B7B1)),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'MONTHLY_ESSENTIAL',
                                  child: Text('Essencial'),
                                ),
                                DropdownMenuItem(
                                  value: 'ENTERTAINMENT',
                                  child: Text('Entretenimento'),
                                ),
                                DropdownMenuItem(
                                  value: 'INVESTMENTS',
                                  child: Text('Investimentos'),
                                ),
                                DropdownMenuItem(
                                  value: 'LONGTIME_PURCHASE',
                                  child: Text('Compras a Longo Prazo'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setStateDialog(() {
                                    selectedType = v;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E6E53),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final auth = Provider.of<AuthService>(
                                context,
                                listen: false,
                              );
                              final service = ExpenseService(auth);
                              try {
                                if (expense == null) {
                                  await service.create(
                                    labelCtrl.text.trim(),
                                    double.tryParse(valueCtrl.text.trim()) ??
                                        0.0,
                                    selectedType,
                                  );
                                } else {
                                  await service.update(
                                    expense['id'],
                                    labelCtrl.text.trim(),
                                    double.tryParse(valueCtrl.text.trim()) ??
                                        0.0,
                                    selectedType,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        expense == null
                                            ? '✅ Despesa criada com sucesso!'
                                            : '✅ Despesa atualizada!',
                                      ),
                                    ),
                                  );
                                  _loadDashboardData();
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('❌Erro ao criar novo registro. Tente novamente mais tarde.')),
                                );
                              }
                            },
                            child: Text(
                              expense == null ? 'Salvar' : 'Atualizar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
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

  // Função para deletar uma entrada
  Future<void> _deleteIncome(Map<String, dynamic> income) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = IncomeService(auth);

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF201D1E),
            title: const Text(
              'Excluir entrada',
              style: TextStyle(color: Color(0xFFC0B7B1)),
            ),
            content: Text(
              'Deseja realmente excluir "${income['incomeLabel']}"?',
              style: const TextStyle(color: Color(0xFFC0B7B1)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await service.delete(income['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Entrada excluída com sucesso!')),
        );
        _loadDashboardData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌Erro ao excluir. Tente novamente mais tarde.')));
      }
    }
  }

  // Função para deletar uma despesa
  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final service = ExpenseService(auth);

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF201D1E),
            title: const Text(
              'Excluir despesa',
              style: TextStyle(color: Color(0xFFC0B7B1)),
            ),
            content: Text(
              'Deseja realmente excluir "${expense['expenseLabel']}"?',
              style: const TextStyle(color: Color(0xFFC0B7B1)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await service.delete(expense['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Despesa excluída com sucesso!')),
        );
        _loadDashboardData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌Erro ao excluir. Tente novamente mais tarde.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkSecondaryBg = Color(0xFF201D1E);
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryHighlight = Color(0xFF8E6E53);
    const incomeColor = Color(0xFF4B8A08);
    const expenseColor = Color(0xFF964646);

    return Scaffold(
      backgroundColor: darkMainBg,
      appBar: AppBar(
        backgroundColor: darkSecondaryBg,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 36,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              "Cashtrack",
              style: TextStyle(
                color: darkFontColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
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
      body:
          loading
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _UserCard(
                        username: account?['username'] ?? 'Usuário',
                        balance: balance?['balance'] ?? 0.0,
                      ),
                      const SizedBox(height: 32),

                      // CARD ENTRADAS
                      _DashboardCard(
                        title: "Entradas",
                        totalLabel: "Total de Entradas",
                        totalValue:
                            "R\$ ${(balance?['totalIncomes'] ?? 0).toStringAsFixed(2)}",
                        color: incomeColor,
                        highlightColor: darkSecondaryHighlight,
                        items: incomes,
                        onAdd: () => _showIncomeDialog(),
                        onEdit: (item) => _showIncomeDialog(income: item),
                        onDelete: (item) => _deleteIncome(item),
                        onViewAll: () {
                          final navState = context.findAncestorStateOfType<MainNavigationState>();
                          navState?.switchTab(1); // índice da aba de IncomesDashboard
                        },
                      ),

                      const SizedBox(height: 24),

                      // CARD DESPESAS (placeholder)
                      _DashboardCard(
                        title: "Despesas",
                        totalLabel: "Total de Despesas",
                        totalValue:
                            "- R\$ ${(balance?['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                        color: expenseColor,
                        highlightColor: darkSecondaryHighlight,
                        items: expenses,
                        onAdd: () => _showExpenseDialog(),
                        onEdit: (item) => _showExpenseDialog(expense: item),
                        onDelete: (item) => _deleteExpense(item),
                        onViewAll: () {
                          final navState = context.findAncestorStateOfType<MainNavigationState>();
                          navState?.switchTab(2); // índice da aba de ExpensesDashboard
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// ================================================
// COMPONENTES
// ================================================

class _UserCard extends StatelessWidget {
  final String username;
  final double balance;
  const _UserCard({required this.username, required this.balance});

  @override
  Widget build(BuildContext context) {
    const darkSecondaryBg = Color(0xFF201D1E);
    const darkFontColor = Color(0xFFC0B7B1);
    const darkSecondaryHighlight = Color(0xFF8E6E53);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkSecondaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: darkSecondaryHighlight.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Olá, $username!",
            style: const TextStyle(
              color: darkFontColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Seu saldo está em ",
            style: TextStyle(color: darkFontColor, fontSize: 16),
          ),
          Text(
            "R\$ ${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: darkSecondaryHighlight,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String totalLabel;
  final String totalValue;
  final Color color;
  final Color highlightColor;
  final List<dynamic> items;
  final Function()? onAdd;
  final Function()? onViewAll;
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
    this.onViewAll,
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
        border: Border.all(color: highlightColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "$totalLabel: $totalValue",
              style: const TextStyle(color: darkFontColor, fontSize: 15),
            ),
          ),
          const SizedBox(height: 16),

          // Botões principais
          Row(
            children: [
              if (onAdd != null)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      "Adicionar Novo",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlightColor.withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onAdd,
                  ),
                ),
              if (onAdd != null) const SizedBox(width: 10),
              if (onViewAll != null)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.list,
                      size: 18,
                      color: darkFontColor,
                    ),
                    label: const Text(
                      "Ver Todos",
                      style: TextStyle(color: darkFontColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: highlightColor.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onViewAll,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Últimos registros",
              style: TextStyle(
                color: darkFontColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (items.isEmpty)
            const Text(
              "Nenhum registro encontrado",
              style: TextStyle(color: darkFontColor),
              textAlign: TextAlign.center,
            )
          else
            Column(
              children:
                  items.take(3).map((item) {
                    final label =
                        item["incomeLabel"] ?? item["expenseLabel"] ?? "-";
                    final value = (item["value"] ?? 0).toStringAsFixed(2);
                    final type = item["type"] ?? "-";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
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
