import 'package:flutter/material.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../routes/app_routes.dart';
import '../../../trip/domain/entities/trip.dart';

class ExpenseScreen extends StatelessWidget {
  final Trip trip;

  const ExpenseScreen({super.key, required this.trip});

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
            // Header
            TripHeader(
              title: trip.title,
              location: trip.location,
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildTotalExpenseCard(),
                    const SizedBox(height: 25),
                    _buildAddExpenseButton(context),
                    const SizedBox(height: 30),
                    _buildSettlementSection(),
                    const SizedBox(height: 30),
                    _buildExpenseHistorySection(),
                    const SizedBox(height: 30),
                    _buildBalanceSection(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            TripBottomNavigation(
              currentIndex: 2, // Expense tab index
              onTap: (index) {
                if (index == 2) return;
                if (index == 0) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: AddFloatingButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addExpense);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTotalExpenseCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4CA5E0),
            Color(0xFF3B91A8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng chi tiêu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            '13.200.000 đ',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'Nhóm đang nợ bạn: 7.140.000 đ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19),
      child: Material(
        color: const Color(0xFFF3F4F6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addExpense);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF00C950).withOpacity(0.2),
          highlightColor: const Color(0xFF00C950).withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                '+ Thêm chi tiêu mới',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Đề hòa, cần thanh toán:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildSettlementItem('Lan Chi', 'Minh Anh', '4.160.000 đ', true),
          const SizedBox(height: 16),
          _buildSettlementItem('Lan Chi', 'Minh Anh', '4.160.000 đ', true),
          const SizedBox(height: 16),
          _buildSettlementItem('Lan Chi', 'Minh Anh', '4.160.000 đ', true),
          const SizedBox(height: 16),
          _buildSettlementItem('Lan Chi', 'Minh Anh', '4.160.000 đ', true),
        ],
      ),
    );
  }

  Widget _buildSettlementItem(
    String from,
    String to,
    String amount,
    bool isPaid,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // From user avatar
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            from,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 12),
          const Text('→', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          // To user avatar
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.pink.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            to,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 12),
          if (isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C950),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Đã trả',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Lịch sử chi tiêu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 23),
          _buildExpenseHistoryItem(),
          const SizedBox(height: 16),
          _buildExpenseHistoryItem(),
          const SizedBox(height: 16),
          _buildExpenseHistoryItem(),
          const SizedBox(height: 16),
          _buildExpenseHistoryItem(),
        ],
      ),
    );
  }

  Widget _buildExpenseHistoryItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.flight, size: 20),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vé máy bay Hà Nội → Đà Nẵng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Minh Anh đã trả',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Chia 5 người',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '7.500.000 đ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1.500.000 đ/ người',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
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
            ),
          ),
          const SizedBox(height: 32),
          _buildBalanceItem('Minh Anh', '+7.400.000 đ', true),
          const Divider(height: 32),
          _buildBalanceItem('Minh Anh', '+7.400.000 đ', true),
          const Divider(height: 32),
          _buildBalanceItem('Minh Anh', '-7.400.000 đ', false),
          const Divider(height: 32),
          _buildBalanceItem('Minh Anh', '+7.400.000 đ', true),
          const Divider(height: 32),
          _buildBalanceItem('Minh Anh', '-7.400.000 đ', false),
          const Divider(height: 32),
          _buildBalanceItem('Minh Anh', '+7.400.000 đ', true),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String name, String amount, bool isPositive) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          name,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            color: isPositive ? const Color(0xFF00C950) : const Color(0xFFDF1F32),
          ),
        ),
      ],
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
