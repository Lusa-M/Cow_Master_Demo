import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'cattle_page.dart';
import 'models/cattle_store.dart';
import 'finance_page.dart';
import 'reports_page.dart';

class CowMasterHomePage extends StatefulWidget {
  const CowMasterHomePage({super.key});

  @override
  State<CowMasterHomePage> createState() => _CowMasterHomePageState();
}

class _CowMasterHomePageState extends State<CowMasterHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        elevation: 0,
        title: const Text('Cow Master', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF22B89A)),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNumberOfSection(),
              const SizedBox(height: 12),
              _buildConditionalSummarySection(),
              const SizedBox(height: 12),
              _buildIncomeExpenseSection(),
              const SizedBox(height: 12),
              _buildMilkSection(),
              const SizedBox(height: 12),
              _buildEventsSection(),
              const SizedBox(height: 12),
              _buildRationsStockSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNumberOfSection() {
    final store = CattleStore.instance;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Number of', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ValueListenableBuilder<List>(
              valueListenable: store.cattleNotifier,
              builder: (context, _, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnimalType('Cows', Icons.agriculture, Colors.redAccent, store.countByBreed('Cows')),
                    _buildAnimalType('Heifers', Icons.female, Colors.purple, store.countByBreed('Heifers')),
                    _buildAnimalType('Bulls', Icons.male, Colors.teal, store.countByBreed('Bulls')),
                    _buildAnimalType('Weaner', Icons.grass, Colors.lightBlue, store.countByBreed('Weaner')),
                    _buildAnimalType('Calf', Icons.child_care, Colors.pinkAccent, store.countByBreed('Calf')),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniCard('Disposed', Icons.logout, Colors.brown),
                _buildMiniCard('Deleted', Icons.delete, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalType(String label, IconData icon, Color color, int count) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigate to cattle page filtered by this breed
          Navigator.push(context, MaterialPageRoute(builder: (context) => CattlePage(filterBreed: label)));
        },
        child: Card(
          color: color.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCard(String label, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCardWithCount(String label, IconData icon, Color color, int count) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionalSummarySection() {
    final store = CattleStore.instance;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Conditional Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ValueListenableBuilder<List>(
              valueListenable: store.cattleNotifier,
              builder: (context, _, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildConditionCard('Sick', Icons.medical_services, Colors.redAccent, store.countByCondition('Sick')),
                    _buildConditionCard('Pregnant', Icons.pregnant_woman, Colors.purple, store.countByCondition('Pregnant')),
                    _buildConditionCard('Milking', Icons.opacity, Colors.teal, store.countByCondition('Milking')),
                    _buildConditionCard('Dry', Icons.block, Colors.lightBlue, store.countByCondition('Dry')),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniCard('Inseminated', Icons.key, Colors.brown),
                _buildMiniCard('Fresh', Icons.local_drink, Colors.black54),
                _buildMiniCard('Open', Icons.not_interested, Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard(String label, IconData icon, Color color, int count) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigate to cattle page filtered by this condition
          Navigator.push(context, MaterialPageRoute(builder: (context) => CattlePageByCondition(condition: label)));
        },
        child: Card(
          color: color.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Incomes / Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIncomeExpenseCard('Incomes', Icons.attach_money, Colors.green),
                _buildIncomeExpenseCard('Expenses', Icons.money_off, Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniCard('Receivables', Icons.arrow_forward, Colors.orange),
                _buildMiniCard('Debts', Icons.arrow_back, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard(String label, IconData icon, Color color) {
    final store = CattleStore.instance;
    return Expanded(
      child: ValueListenableBuilder<List<
          dynamic>>(
        valueListenable: store.financeNotifier,
        builder: (context, _, __) {
          final incomeTotal = store.totalIncome();
          final expenseTotal = store.totalExpense();
          final display = label == 'Incomes' ? incomeTotal : expenseTotal;
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FinancePage(initialType: label == 'Incomes' ? 'income' : 'expense')));
            },
            child: Card(
              color: color.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    // show R label instead of dollar icon
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('R', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 6),
                    Text(display.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(label == 'Incomes' ? 'Receivables: 0.0' : 'Debts: 0.0', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilkSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Milk (lt)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMilkCard('Annual DIM', Icons.warning, Colors.red),
                _buildMilkCard('Total Milk', Icons.local_drink, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkCard(String label, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final store = CattleStore.instance;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Events / Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ValueListenableBuilder<List>(
                  valueListenable: store.cattleNotifier,
                  builder: (context, _, __) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage())),
                      child: _buildMiniCardWithCount('Latest Events', Icons.calendar_today, Colors.black54, store.countEvents()),
                    );
                  },
                ),
                ValueListenableBuilder<List>(
                  valueListenable: store.cattleNotifier,
                  builder: (context, _, __) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
                      child: _buildMiniCardWithCount('Weekly Tasks', Icons.notifications, Colors.black38, store.countNotifications()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRationsStockSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Rations / Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniCard('Rations', Icons.restaurant, Colors.black54),
                _buildMiniCard('Stock', Icons.layers, Colors.black38),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, 'Summary', true, null),
            _buildNavBarItem(Icons.agriculture, 'Cattle', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CattlePage()));
            }),
            _buildNavBarItem(Icons.notifications, 'Notifications', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }),
            _buildNavBarItem(Icons.assignment, 'Reports', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()));
            }),
          ],
        ),
      ),
    );
  }

    Widget _buildNavBarItem(IconData icon, String label, bool selected, VoidCallback? onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: selected
                ? BoxDecoration(
                    color: const Color(0xFFE9F2F1),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? Color(0xFF22B89A) : Colors.black38),
                Text(label, style: TextStyle(color: selected ? Color(0xFF22B89A) : Colors.black38)),
              ],
            ),
          ),
        ),
      );
    }
  }