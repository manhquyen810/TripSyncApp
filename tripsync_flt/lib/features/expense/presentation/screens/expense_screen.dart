import 'package:flutter/material.dart';

import '../../../../routes/app_routes.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../trip/domain/entities/trip.dart';

import '../widgets/add_expense_button.dart';
import '../widgets/balance_item.dart';
import '../widgets/expense_history_item.dart';
import '../widgets/payment_request_item.dart';
import '../widgets/total_expense_card.dart';

class ExpenseScreen extends StatelessWidget {
  final Trip trip;

  const ExpenseScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            TripHeader(
              title: trip.title,
              location: trip.location,
              onSettingsPressed: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: TotalExpenseCard(
                        totalAmount: '13.200.000 đ',
                        owedAmount: '7.140.000 đ',
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: AddExpenseButton(),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          PaymentRequestItem(
                            fromName: 'Lan\nChi',
                            toName: 'Minh\nAnh',
                            amount: '4.160.000 đ',
                            isPaid: true,
                          ),
                          SizedBox(height: 16),
                          PaymentRequestItem(
                            fromName: 'Lan\nChi',
                            toName: 'Minh\nAnh',
                            amount: '4.160.000 đ',
                            isPaid: false,
                          ),
                        ],
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          ExpenseHistoryItem(
                            title: 'Vé máy bay Hà Nội → Đà Nẵng',
                            payer: 'Minh Anh',
                            splitCount: 5,
                            totalAmount: '7.500.000 đ',
                            perPersonAmount: '1.500.000 đ/ người',
                          ),
                          SizedBox(height: 12),
                          ExpenseHistoryItem(
                            title: 'Khách sạn',
                            payer: 'Lan Chi',
                            splitCount: 5,
                            totalAmount: '5.000.000 đ',
                            perPersonAmount: '1.000.000 đ/ người',
                          ),
                        ],
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số dư từng người',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 18),
                            BalanceItem(
                              name: 'Minh Anh',
                              amount: '+7.400.000 đ',
                              isPositive: true,
                            ),
                            SizedBox(height: 14),
                            BalanceItem(
                              name: 'Lan Chi',
                              amount: '-7.400.000 đ',
                              isPositive: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TripBottomNavigation(currentIndex: 2, trip: trip),
          ],
        ),
      ),
      floatingActionButton: AddFloatingButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addExpense, arguments: trip),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
