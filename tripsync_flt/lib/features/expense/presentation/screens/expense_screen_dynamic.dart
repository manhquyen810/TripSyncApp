import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../data/datasources/expense_remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/settlement.dart';
import '../widgets/add_expense_button.dart';
import '../widgets/balance_item.dart';
import '../widgets/expense_history_item.dart';
import '../widgets/payment_request_item.dart';
import '../widgets/total_expense_card.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  final Trip trip;

  const ExpenseScreen({super.key, required this.trip});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late final ExpenseRepositoryImpl _repository;
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepositoryImpl(
      ExpenseRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );
    _loadData();
  }

  void _loadData() {
    if (widget.trip.id == null) return;
    
    setState(() {
      _dataFuture = Future.wait([
        _repository.getExpenses(widget.trip.id!),
        _repository.getBalances(widget.trip.id!),
        _repository.getSettlements(widget.trip.id!),
      ]).then((results) {
        return {
          'expenses': results[0] as List<Expense>,
          'balances': results[1] as BalanceResponse,
          'settlements': results[2] as List<Settlement>,
        };
      });
    });
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )} đ';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trip.id == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              TripHeader(
                title: widget.trip.title,
                location: widget.trip.location,
              ),
              const Expanded(
                child: Center(
                  child: Text('Không tìm thấy thông tin chuyến đi'),
                ),
              ),
              TripBottomNavigation(currentIndex: 2),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            TripHeader(
              title: widget.trip.title,
              location: widget.trip.location,
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi: ${snapshot.error}'),
                    );
                  }

                  final data = snapshot.data;
                  if (data == null) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final expenses = data['expenses'] as List<Expense>;
                  final balanceResponse = data['balances'] as BalanceResponse;
                  final settlements = data['settlements'] as List<Settlement>;

                  final balances = balanceResponse.balances;
                  final totalExpense = balanceResponse.totalExpense;
                  
                  final currentUserBalance = balances.isNotEmpty
                      ? balances.first.balance
                      : 0.0;

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 19),
                            child: TotalExpenseCard(
                              totalAmount: _formatCurrency(totalExpense),
                              owedAmount: _formatCurrency(
                                currentUserBalance.abs(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 19),
                            child: AddExpenseButton(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddExpenseScreen(
                                      tripId: widget.trip.id!,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 19),
                            child: Text(
                              'Đề hòa, cần thanh toán:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (settlements.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 19),
                              child: Text(
                                'Chưa có thanh toán nào',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                children: settlements
                                    .map(
                                      (s) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: PaymentRequestItem(
                                          fromName: s.fromUserName,
                                          toName: s.toUserName,
                                          amount: _formatCurrency(s.amount),
                                          isPaid: true,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 26),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 19),
                            child: Text(
                              'Lịch sử chi tiêu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (expenses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 19),
                              child: Text(
                                'Chưa có chi tiêu nào',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                children: expenses
                                    .map(
                                      (e) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: ExpenseHistoryItem(
                                          title: e.description ?? 'Chi tiêu',
                                          payer: e.payerName,
                                          splitCount: e.splits.length,
                                          totalAmount:
                                              _formatCurrency(e.amount),
                                          perPersonAmount: e.splits.isNotEmpty
                                              ? '${_formatCurrency(e.splits.first.amountOwed)}/người'
                                              : '',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Số dư từng người',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  if (balances.isEmpty)
                                    const Text(
                                      'Chưa có dữ liệu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    ...balances.asMap().entries.map((entry) {
                                      final isLast =
                                          entry.key == balances.length - 1;
                                      final balance = entry.value;
                                      return Column(
                                        children: [
                                          BalanceItem(
                                            name: balance.name,
                                            amount: balance.balance >= 0
                                                ? '+${_formatCurrency(balance.balance)}'
                                                : '-${_formatCurrency(balance.balance.abs())}',
                                            isPositive: balance.balance >= 0,
                                          ),
                                          if (!isLast)
                                            const SizedBox(height: 14),
                                        ],
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            TripBottomNavigation(currentIndex: 2),
          ],
        ),
      ),
      floatingActionButton: AddFloatingButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                tripId: widget.trip.id!,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
