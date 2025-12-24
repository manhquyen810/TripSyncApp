import 'package:flutter/material.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../widgets/total_expense_card.dart';
import '../widgets/add_expense_button.dart';
import '../widgets/payment_request_item.dart';
import '../widgets/expense_history_item.dart';
import '../widgets/balance_item.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            TripHeader(
              title: 'Đà Lạt-Thành Phố Mộng Mơ',
              location: 'Đà Lạt, Lâm Đồng',
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 19),
                child: TotalExpenseCard(
                  totalAmount: '13.200.000 đ',
                  owedAmount: '7.140.000 đ',
                ),
              ),
              const SizedBox(height: 25),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 19),
                child: AddExpenseButton(),
              ),
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Đề hòa, cần thanh toán: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    const PaymentRequestItem(
                      fromName: 'Lan\nChi',
                      toName: 'Minh\nAnh',
                      amount: '4.160.000 đ',
                      isPaid: true,
                    ),
                    const SizedBox(height: 28),
                    const PaymentRequestItem(
                      fromName: 'Lan\nChi',
                      toName: 'Minh\nAnh',
                      amount: '4.160.000 đ',
                      isPaid: true,
                    ),
                    const SizedBox(height: 28),
                    const PaymentRequestItem(
                      fromName: 'Lan\nChi',
                      toName: 'Minh\nAnh',
                      amount: '4.160.000 đ',
                      isPaid: true,
                    ),
                    const SizedBox(height: 28),
                    const PaymentRequestItem(
                      fromName: 'Lan\nChi',
                      toName: 'Minh\nAnh',
                      amount: '4.160.000 đ',
                      isPaid: true,
                    ),
                    const SizedBox(height: 30),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Lịch sử chi tiêu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    
                    const ExpenseHistoryItem(
                      title: 'Vé máy bay Hà Nội → Đà Nẵng ',
                      payer: 'Minh Anh',
                      splitCount: 5,
                      totalAmount: '7.500.000 đ',
                      perPersonAmount: '1.500.000 đ/ người',
                    ),
                    const SizedBox(height: 23),
                    const ExpenseHistoryItem(
                      title: 'Vé máy bay Hà Nội → Đà Nẵng ',
                      payer: 'Minh Anh',
                      splitCount: 5,
                      totalAmount: '7.500.000 đ',
                      perPersonAmount: '1.500.000 đ/ người',
                    ),
                    const SizedBox(height: 23),
                    const ExpenseHistoryItem(
                      title: 'Vé máy bay Hà Nội → Đà Nẵng ',
                      payer: 'Minh Anh',
                      splitCount: 5,
                      totalAmount: '7.500.000 đ',
                      perPersonAmount: '1.500.000 đ/ người',
                    ),
                    const SizedBox(height: 23),
                    const ExpenseHistoryItem(
                      title: 'Vé máy bay Hà Nội → Đà Nẵng ',
                      payer: 'Minh Anh',
                      splitCount: 5,
                      totalAmount: '7.500.000 đ',
                      perPersonAmount: '1.500.000 đ/ người',
                    ),
                    const SizedBox(height: 30),
                    
                    Container(
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
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '+7.400.000 đ',
                            isPositive: true,
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '+7.400.000 đ',
                            isPositive: true,
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '-7.400.000 đ',
                            isPositive: false,
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '+7.400.000 đ',
                            isPositive: true,
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '-7.400.000 đ',
                            isPositive: false,
                          ),
                          const SizedBox(height: 32),
                          const BalanceItem(
                            name: 'Minh Anh',
                            amount: '+7.400.000 đ',
                            isPositive: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            
            TripBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              break;
            case 2:
              break;
            case 3:
              break;
          }
        },
      ),
          ],
        ),
      ),
      floatingActionButton: const AddFloatingButton(isExpenseScreen: true),
    );
  }
}
