import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cow Master'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Number of Cattle'),
            _buildGrid([
              'All Cattle', 'Cows', 'Heifers', 'Bulls',
              'Weaners', 'Calves', 'Disposed', 'Deleted'
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Conditional Summary'),
            _buildGrid([
              'Sick', 'Pregnant', 'Milking', 'Dry',
              'Inseminated', 'Fresh', 'Open'
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Incomes / Expenses'),
            _buildFinanceRow(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Cattle'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGrid(List<String> labels) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.5,
      children: labels.map((label) => _buildStatCard(label)).toList(),
    );
  }

  Widget _buildStatCard(String label) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Text('0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Incomes')),
        Expanded(child: _buildStatCard('Expenses')),
      ],
    );
  }
}