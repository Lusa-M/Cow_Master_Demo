import 'package:flutter/material.dart';
import 'models/cattle.dart';
import 'models/cattle_store.dart';
import 'models/event_log.dart';
import 'models/notification.dart';
import 'reports_page.dart';

class CattlePageByCondition extends StatelessWidget {
  final String condition;

  const CattlePageByCondition({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return _CattlePageByConditionImpl(condition: condition);
  }
}

class _CattlePageByConditionImpl extends StatefulWidget {
  final String condition;

  const _CattlePageByConditionImpl({required this.condition});

  @override
  State<_CattlePageByConditionImpl> createState() => _CattlePageByConditionImplState();
}

class _CattlePageByConditionImplState extends State<_CattlePageByConditionImpl> {
  final CattleStore store = CattleStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('${widget.condition} Cattle', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<Cattle>>(
        valueListenable: store.cattleNotifier,
        builder: (context, list, _) {
          final filtered = store.filterByCondition(widget.condition);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.condition.toLowerCase()} cattle found.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final cattle = filtered[index];
              final latestEvent = store.getLatestEvent(cattle);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF22B89A),
                    child: const Icon(Icons.pets, color: Colors.white),
                  ),
                  title: Text(cattle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cattle.earTag),
                      if (latestEvent != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '(${latestEvent.eventType}) ${EventLog.eventTypeDisplayNames[latestEvent.eventType] ?? latestEvent.eventType}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleDetailPage(
                          cattle: cattle,
                          onUpdate: (updated) => store.update(cattle.id!, updated),
                          onDelete: () {
                            store.remove(cattle.id!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CattlePage extends StatefulWidget {
  final String? filterBreed;

  const CattlePage({super.key, this.filterBreed});

  @override
  State<CattlePage> createState() => _CattlePageState();
}

class _CattlePageState extends State<CattlePage> {
  final CattleStore store = CattleStore.instance;

  void _openAdd({String? initialBreed}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => AddCattleSheet(
        onSave: (c) => store.add(c),
        initialBreed: initialBreed,
      ),
    );
  }


  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cattle?'),
        content: const Text('Are you sure you want to delete this cattle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              store.remove(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        title: const Text('All Cattle', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<Cattle>>(
        valueListenable: store.cattleNotifier,
        builder: (context, list, _) {
          final filtered = widget.filterBreed == null ? list : list.where((c) => c.breed == widget.filterBreed).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    widget.filterBreed == null
                        ? 'No animals found. Add a new cattle using the + button.'
                        : 'No ${widget.filterBreed} found. Tap the + button to add one.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final cattle = filtered[index];
              final latestEvent = store.getLatestEvent(cattle);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF22B89A),
                    child: const Icon(Icons.pets, color: Colors.white),
                  ),
                  title: Text(cattle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cattle.earTag),
                      if (latestEvent != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '(${latestEvent.eventType}) ${EventLog.eventTypeDisplayNames[latestEvent.eventType] ?? latestEvent.eventType}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleDetailPage(
                          cattle: cattle,
                          onUpdate: (updated) => store.update(cattle.id!, updated),
                          onDelete: () => _confirmDelete(cattle.id!),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22B89A),
        onPressed: () => _openAdd(initialBreed: widget.filterBreed),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, 'Summary', false, () => Navigator.pop(context)),
            _buildNavBarItem(Icons.agriculture, 'Cattle', true, null),
            _buildNavBarItem(Icons.notifications, 'Notifications', false, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())); }),
            _buildNavBarItem(Icons.assignment, 'Reports', false, () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())); }),
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
          decoration: selected ? BoxDecoration(color: const Color(0xFFE9F2F1), borderRadius: BorderRadius.circular(16)) : null,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? const Color(0xFF22B89A) : Colors.black38),
              Text(label, style: TextStyle(color: selected ? const Color(0xFF22B89A) : Colors.black38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// Below: AddCattleSheet, EditCattleSheet and CattleDetailPage implementations

class AddCattleSheet extends StatefulWidget {
  final Function(Cattle) onSave;
  final String? initialBreed;

  const AddCattleSheet({super.key, required this.onSave, this.initialBreed});

  @override
  State<AddCattleSheet> createState() => _AddCattleSheetState();
}

class _AddCattleSheetState extends State<AddCattleSheet> {
  final _nameController = TextEditingController();
  final _earTagController = TextEditingController();
  final _damEarTagController = TextEditingController();
  final _sireNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = 'Female';
  DateTime _selectedDate = DateTime.now();
  String _selectedBreed = 'Cows';

  final List<String> _breeds = ['Cows', 'Heifers', 'Bulls', 'Weaner', 'Calf'];

  @override
  void initState() {
    super.initState();
    if (widget.initialBreed != null && _breeds.contains(widget.initialBreed)) {
      _selectedBreed = widget.initialBreed!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _earTagController.dispose();
    _damEarTagController.dispose();
    _sireNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerWithConfirm() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                      onPressed: () {
                        setState(() {
                          _selectedDate = temp;
                          final now = DateTime.now();
                          final months = (now.year - _selectedDate.year) * 12 + (now.month - _selectedDate.month);
                          if (months <= 6) {
                            _selectedBreed = 'Calf';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveCattle() {
    if (_nameController.text.isEmpty || _earTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    final cattle = Cattle(
      name: _nameController.text,
      earTag: _earTagController.text,
      gender: _selectedGender,
      birthDate: _selectedDate,
      breed: _selectedBreed,
      damEarTag: _damEarTagController.text,
      sireName: _sireNameController.text,
      notes: _notesController.text,
    );

    widget.onSave(cattle);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9F2F1),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))),
            const Text('Add Cattle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(onPressed: _saveCattle, child: const Text('Save', style: TextStyle(color: Color(0xFF22B89A), fontSize: 16))),
          ]),
          const SizedBox(height: 16),
          _buildTextField('Name', _nameController),
          const SizedBox(height: 12),
          _buildTextField('Ear Tag', _earTagController),
          const SizedBox(height: 16),
          const Text('Select Gender', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _buildGenderButton('Female')), const SizedBox(width: 12), Expanded(child: _buildGenderButton('Male'))]),
          const SizedBox(height: 16),
          GestureDetector(onTap: _showDatePickerWithConfirm, child: _buildDateField()),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBreed,
                items: _breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedBreed = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField('Dam Ear Tag', _damEarTagController),
          const SizedBox(height: 12),
          _buildTextField('Sire Name, Tag', _sireNameController),
          const SizedBox(height: 12),
          _buildTextField('Notes', _notesController, maxLines: 3),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF22B89A) : Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () => setState(() => _selectedGender = gender),
      child: Text(gender, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Birth Date:'),
          Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22B89A))),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ============ CATTLE DETAIL PAGE ============

class CattleDetailPage extends StatefulWidget {
  final Cattle cattle;
  final Function(Cattle) onUpdate;
  final Function() onDelete;

  const CattleDetailPage({super.key, required this.cattle, required this.onUpdate, required this.onDelete});

  @override
  State<CattleDetailPage> createState() => _CattleDetailPageState();
}

class _CattleDetailPageState extends State<CattleDetailPage> {
  late Cattle _cattle;
  final CattleStore store = CattleStore.instance;

  @override
  void initState() {
    super.initState();
    _cattle = widget.cattle;
  }

  void _showOptionsMenu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFB3E5E1), borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.edit, color: Colors.black), title: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(context); _showEditDialog(); }),
            ListTile(leading: const Icon(Icons.delete, color: Colors.black), title: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(context); _showDeleteConfirmation(); }),
          ]),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cattle?'),
        content: const Text('Are you sure you want to delete this cattle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); widget.onDelete(); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => EditCattleSheet(cattle: _cattle, onSave: (updated) { setState(() => _cattle = updated); widget.onUpdate(updated); Navigator.pop(context); }),
    );
  }

  void _openAddEventLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => AddEventLogSheet(
        cattle: _cattle,
        onSave: (updatedCattle) {
          setState(() => _cattle = updatedCattle);
          widget.onUpdate(updatedCattle);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openAddTaskNotification() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => AddTaskNotificationSheet(
        cattle: _cattle,
        onSave: (updatedCattle) {
          setState(() => _cattle = updatedCattle);
          widget.onUpdate(updatedCattle);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: CircleAvatar(backgroundColor: Colors.white, child: const Icon(Icons.pets, color: Color(0xFF22B89A))),
        centerTitle: true,
        elevation: 0,
        actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: IconButton(icon: const Icon(Icons.more_vert), onPressed: _showOptionsMenu))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 2)), height: 120, child: Center(child: Text('+Add Photo', style: TextStyle(color: Colors.blue[300], fontSize: 18)))),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Basic Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), FloatingActionButton(mini: true, backgroundColor: const Color(0xFF22B89A), onPressed: _showEditDialog, child: const Icon(Icons.edit))])),
            Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              _buildInfoRow('Ear tag', _cattle.earTag), _buildInfoRow('Name', _cattle.name), _buildInfoRow('Gender', _cattle.gender), _buildInfoRow('Breed', _cattle.breed), _buildInfoRow('Birth Date', '${_cattle.birthDate.day}/${_cattle.birthDate.month}/${_cattle.birthDate.year}'), _buildInfoRow('Age', _cattle.getAge()), _buildInfoRow('Dam ear tag', _cattle.damEarTag), _buildInfoRow('Sire name, tag', _cattle.sireName), _buildInfoRow('Notes', _cattle.notes)
            ]))
          ])),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _buildSelectionButton('Herd / Paddock', 'Select Group')), const SizedBox(width: 12), Expanded(child: _buildSelectionButton('Ration Name', 'Select Ration', isActive: true))]),
          const SizedBox(height: 16),
          // Event Logs
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Event Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), FloatingActionButton(mini: true, backgroundColor: const Color(0xFF22B89A), onPressed: _openAddEventLog, child: const Icon(Icons.add))])),
            if (_cattle.events.isEmpty)
              const Padding(padding: EdgeInsets.all(12), child: Text('Event list is empty, click the + button to add event logs.', style: TextStyle(color: Colors.black54)))
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _cattle.events.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _showEventDetailsDialog(event),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red, width: 2)),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(EventLog.eventTypeDisplayNames[event.eventType] ?? event.eventType, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                                  Text('${event.date.day}/${event.date.month}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              if (event.eventType == 'Pregnant') ...[
                                const SizedBox(height: 4),
                                Text(_cattle.getPregnancyDuration(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                              if (event.details != null && event.details!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(event.details!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                              if (event.durationDays != null) ...[
                                const SizedBox(height: 4),
                                Text('Duration: ${event.durationDays} days', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                              if (event.notes != null && event.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(event.notes!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
          ])),
          const SizedBox(height: 16),
          // Notifications
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), FloatingActionButton(mini: true, backgroundColor: const Color(0xFF22B89A), onPressed: _openAddTaskNotification, child: const Icon(Icons.add))])),
            if (_cattle.notifications.isEmpty)
              const Padding(padding: EdgeInsets.all(12), child: Text('No notifications. Click + to add task.', style: TextStyle(color: Colors.black54)))
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _cattle.notifications.map((notification) {
                    final isOverdue = notification.dueDate.isBefore(DateTime.now()) && !notification.completed;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _showNotificationDetailDialog(notification),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange), width: 2)),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange)))),
                                  Text('${notification.dueDate.day}/${notification.dueDate.month}', style: TextStyle(color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange), fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              if (notification.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(notification.notes, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
          ])),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value, style: const TextStyle(color: Color(0xFF22B89A), fontWeight: FontWeight.bold))]));
  }

  void _showEventDetailsDialog(EventLog event) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFE9F2F1), borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      EventLog.eventTypeDisplayNames[event.eventType] ?? event.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
                    ),
                    GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24)),
                  ],
                ),
                const Divider(height: 20),
                _buildEventDetailRow('Date', '${event.date.day}/${event.date.month}/${event.date.year}'),
                const SizedBox(height: 12),
                if (event.eventType == 'Pregnant') ...[
                  _buildEventDetailRow('Pregnancy Duration', _cattle.getPregnancyDuration()),
                  const SizedBox(height: 12),
                ],
                if (event.details != null && event.details!.isNotEmpty) ...[
                  _buildEventDetailRow(_getDetailLabelForEventType(event.eventType), event.details!),
                  const SizedBox(height: 12),
                ],
                if (event.durationDays != null) ...[
                  _buildEventDetailRow('Treatment Duration', '${event.durationDays} days'),
                  const SizedBox(height: 12),
                ],
                if (event.notes != null && event.notes!.isNotEmpty) ...[
                  _buildEventDetailRow('Notes', event.notes!),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  String _getDetailLabelForEventType(String eventType) {
    const Map<String, String> labels = {
      'Illness/Treatment': 'Diagnosed as',
      'Weaned': 'Notes',
      'Weighed': 'Weight',
      'Vaccinated': 'Vaccine',
      'Antiparasitic Treatment': 'Treatment type',
      'Pregnant': 'Notes',
      'Milking': 'Notes',
      'Dry': 'Notes',
    };
    return labels[eventType] ?? 'Details';
  }

  void _showNotificationDetailDialog(TaskNotification notification) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFE9F2F1), borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF22B89A))),
                    GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24)),
                  ],
                ),
                const Divider(height: 20),
                _buildNotifDetailRow('Due Date', '${notification.dueDate.day}/${notification.dueDate.month}/${notification.dueDate.year}'),
                const SizedBox(height: 12),
                if (notification.notes.isNotEmpty) ...[
                  _buildNotifDetailRow('Notes', notification.notes),
                  const SizedBox(height: 12),
                ],
                _buildNotifDetailRow('Status', notification.completed ? 'Completed' : 'Pending'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSelectionButton(String title, String placeholder, {bool isActive = false}) {
    return Container(decoration: BoxDecoration(color: isActive ? const Color(0xFFB3E5E1) : Colors.grey[300], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(title.contains('Herd') ? Icons.home : Icons.restaurant, color: Colors.black54), const SizedBox(height: 4), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 4), Text(placeholder, style: TextStyle(color: Colors.black54, fontSize: 12))]));
  }
}

// ============ ADD EVENT LOG SHEET ============

class AddEventLogSheet extends StatefulWidget {
  final Cattle cattle;
  final Function(Cattle) onSave;

  const AddEventLogSheet({super.key, required this.cattle, required this.onSave});

  @override
  State<AddEventLogSheet> createState() => _AddEventLogSheetState();
}

class _AddEventLogSheetState extends State<AddEventLogSheet> {
  late String _selectedEventType;
  late DateTime _selectedDate;
  late TextEditingController _detailsController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  late List<String> _eventTypes;

  @override
  void initState() {
    super.initState();
    // Build event types dynamically. Pregnant is only shown for female cattle.
    _eventTypes = [
      'Illness/Treatment',
      'Weaned',
      'Weighed',
      'Vaccinated',
      'Antiparasitic Treatment',
      if (widget.cattle.gender == 'Female') 'Pregnant',
      'Milking',
      'Dry',
    ];
    _selectedEventType = _eventTypes.first;
    _selectedDate = DateTime.now();
    _detailsController = TextEditingController();
    _durationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getQuestionForEventType(String eventType) {
    const Map<String, String> questions = {
      'Illness/Treatment': 'Diagnosed as',
      'Weaned': 'Notes',
      'Weighed': 'Weight',
      'Vaccinated': 'Vaccine',
      'Antiparasitic Treatment': 'Treatment type',
      'Pregnant': 'Notes',
      'Milking': 'Notes',
      'Dry': 'Notes',
    };
    return questions[eventType] ?? 'Details';
  }

  Future<void> _showDatePickerWithConfirm() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                      onPressed: () {
                        setState(() => _selectedDate = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveEvent() {
    final event = EventLog(
      date: _selectedDate,
      eventType: _selectedEventType,
      details: _detailsController.text.isNotEmpty ? _detailsController.text : null,
      durationDays: _durationController.text.isNotEmpty ? int.tryParse(_durationController.text) : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final updatedCattle = Cattle(
      id: widget.cattle.id,
      name: widget.cattle.name,
      earTag: widget.cattle.earTag,
      gender: widget.cattle.gender,
      birthDate: widget.cattle.birthDate,
      breed: widget.cattle.breed,
      damEarTag: widget.cattle.damEarTag,
      sireName: widget.cattle.sireName,
      notes: widget.cattle.notes,
      events: [...widget.cattle.events, event],
    );

    widget.onSave(updatedCattle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9F2F1),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))),
            const Text('Add Event Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(onPressed: _saveEvent, child: const Text('Save', style: TextStyle(color: Color(0xFF22B89A), fontSize: 16))),
          ]),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEventType,
                items: _eventTypes.map((t) => DropdownMenuItem(value: t, child: Row(children: [const Icon(Icons.medical_services, size: 18), const SizedBox(width: 8), Text(t)]))).toList(),
                onChanged: (v) => setState(() { if (v != null) _selectedEventType = v; }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showDatePickerWithConfirm,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Event Date'),
                  Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22B89A))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(_getQuestionForEventType(_selectedEventType), _detailsController),
          const SizedBox(height: 12),
          if (_selectedEventType == 'Illness/Treatment')
            Column(children: [
              _buildTextField('Treatment Duration (days)', _durationController),
              const SizedBox(height: 12),
            ]),
          _buildTextField('Medicine / treatment notes', _notesController, maxLines: 3),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ============ EDIT CATTLE SHEET ============

class EditCattleSheet extends StatefulWidget {
  final Cattle cattle;
  final Function(Cattle) onSave;

  const EditCattleSheet({super.key, required this.cattle, required this.onSave});

  @override
  State<EditCattleSheet> createState() => _EditCattleSheetState();
}

class _EditCattleSheetState extends State<EditCattleSheet> {
  late TextEditingController _nameController;
  late TextEditingController _earTagController;
  late TextEditingController _damEarTagController;
  late TextEditingController _sireNameController;
  late TextEditingController _notesController;

  late String _selectedGender;
  late DateTime _selectedDate;
  late String _selectedBreed;
  final List<String> _breeds = ['Cows', 'Heifers', 'Bulls', 'Weaner', 'Calf'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cattle.name);
    _earTagController = TextEditingController(text: widget.cattle.earTag);
    _damEarTagController = TextEditingController(text: widget.cattle.damEarTag);
    _sireNameController = TextEditingController(text: widget.cattle.sireName);
    _notesController = TextEditingController(text: widget.cattle.notes);
    _selectedGender = widget.cattle.gender;
    _selectedDate = widget.cattle.birthDate;
    _selectedBreed = widget.cattle.breed.isNotEmpty && _breeds.contains(widget.cattle.breed) ? widget.cattle.breed : 'Cows';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _earTagController.dispose();
    _damEarTagController.dispose();
    _sireNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerWithConfirm() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                      onPressed: () {
                        setState(() {
                          _selectedDate = temp;
                          final now = DateTime.now();
                          final months = (now.year - _selectedDate.year) * 12 + (now.month - _selectedDate.month);
                          if (months <= 6) {
                            _selectedBreed = 'Calf';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveCattle() {
    final updatedCattle = Cattle(
      id: widget.cattle.id,
      name: _nameController.text,
      earTag: _earTagController.text,
      gender: _selectedGender,
      birthDate: _selectedDate,
      breed: _selectedBreed,
      damEarTag: _damEarTagController.text,
      sireName: _sireNameController.text,
      notes: _notesController.text,
      events: widget.cattle.events,
    );

    widget.onSave(updatedCattle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9F2F1),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))), const Text('Edit Cattle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), TextButton(onPressed: _saveCattle, child: const Text('Save', style: TextStyle(color: Color(0xFF22B89A), fontSize: 16)))]),
          const SizedBox(height: 16),
          _buildTextField('Name', _nameController),
          const SizedBox(height: 12),
          _buildTextField('Ear Tag', _earTagController),
          const SizedBox(height: 16),
          const Text('Select Gender', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _buildGenderButton('Female')), const SizedBox(width: 12), Expanded(child: _buildGenderButton('Male'))]),
          const SizedBox(height: 16),
          GestureDetector(onTap: _showDatePickerWithConfirm, child: _buildDateField()),
          const SizedBox(height: 12),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)), padding: const EdgeInsets.symmetric(horizontal: 12), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedBreed, items: _breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(), onChanged: (v) => setState(() { if (v != null) _selectedBreed = v; })))),
          const SizedBox(height: 12),
          _buildTextField('Dam Ear Tag', _damEarTagController),
          const SizedBox(height: 12),
          _buildTextField('Sire Name, Tag', _sireNameController),
          const SizedBox(height: 12),
          _buildTextField('Notes', _notesController, maxLines: 3),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isSelected ? const Color(0xFF22B89A) : Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () => setState(() => _selectedGender = gender), child: Text(gender, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)));
  }

  Widget _buildDateField() {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Birth Date:'), Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22B89A))),]));
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ============ ADD TASK NOTIFICATION SHEET (for cattle detail) ============

class AddTaskNotificationSheet extends StatefulWidget {
  final Cattle cattle;
  final Function(Cattle) onSave;

  const AddTaskNotificationSheet({super.key, required this.cattle, required this.onSave});

  @override
  State<AddTaskNotificationSheet> createState() => _AddTaskNotificationSheetState();
}

class _AddTaskNotificationSheetState extends State<AddTaskNotificationSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerWithConfirm() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                      onPressed: () {
                        setState(() => _selectedDate = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveNotification() {
    if (_titleController.text.isEmpty) return;

    final notification = TaskNotification(
      cattleEarTag: widget.cattle.earTag,
      title: _titleController.text,
      notes: _notesController.text,
      dueDate: _selectedDate,
    );

    final updatedCattle = Cattle(
      id: widget.cattle.id,
      name: widget.cattle.name,
      earTag: widget.cattle.earTag,
      gender: widget.cattle.gender,
      birthDate: widget.cattle.birthDate,
      breed: widget.cattle.breed,
      damEarTag: widget.cattle.damEarTag,
      sireName: widget.cattle.sireName,
      notes: widget.cattle.notes,
      events: widget.cattle.events,
      notifications: [...widget.cattle.notifications, notification],
    );

    widget.onSave(updatedCattle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9F2F1),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))),
                const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: _saveNotification, child: const Text('Save', style: TextStyle(color: Color(0xFF22B89A), fontSize: 16))),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Title', _titleController),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showDatePickerWithConfirm,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Due Date'),
                    Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22B89A))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField('Notes', _notesController, maxLines: 3),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ============ NOTIFICATIONS PAGE ============

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// ============ EVENTS PAGE ============

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final CattleStore store = CattleStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Events Log'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<Cattle>>(
        valueListenable: store.cattleNotifier,
        builder: (context, _, __) {
          final events = store.getAllEvents();

          if (events.isEmpty) {
            return Center(
              child: Text(
                'No events logged yet.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: events.map((event) {
                final cattle = store.all.firstWhere((c) => c.events.contains(event));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                EventLog.eventTypeDisplayNames[event.eventType] ?? event.eventType,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                              ),
                            ),
                            Text(
                              '${event.date.day}/${event.date.month}/${event.date.year}',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${cattle.name} (${cattle.earTag})', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        if (event.details != null && event.details!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(event.details!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                        if (event.durationDays != null) ...[
                          const SizedBox(height: 4),
                          Text('Duration: ${event.durationDays} days', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  final CattleStore store = CattleStore.instance;

  void _openAddNotification() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) => AddNotificationSheet(
        onSave: (notification) {
          final cattle = store.all.firstWhere((c) => c.earTag == notification.cattleEarTag);
          final updatedCattle = Cattle(
            id: cattle.id,
            name: cattle.name,
            earTag: cattle.earTag,
            gender: cattle.gender,
            birthDate: cattle.birthDate,
            breed: cattle.breed,
            damEarTag: cattle.damEarTag,
            sireName: cattle.sireName,
            notes: cattle.notes,
            events: cattle.events,
            notifications: [...cattle.notifications, notification],
          );
          store.update(cattle.id!, updatedCattle);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22B89A),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Notifications / Tasks'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(icon: const Icon(Icons.add), onPressed: _openAddNotification),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Cattle>>(
        valueListenable: store.cattleNotifier,
        builder: (context, _, __) {
          final notifications = store.getAllNotifications();
          notifications.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          if (notifications.isEmpty) {
            return Center(child: Text('No notifications. Tap + to add one.', style: TextStyle(color: Colors.black54, fontSize: 16)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: notifications.map((notification) {
                final cattle = store.all.firstWhere((c) => c.earTag == notification.cattleEarTag);
                final isOverdue = notification.dueDate.isBefore(DateTime.now()) && !notification.completed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _showNotificationDetailsDialog(notification, cattle),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange), width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange)))),
                              Text('${notification.dueDate.day}/${notification.dueDate.month}', style: TextStyle(color: isOverdue ? Colors.red : (notification.completed ? Colors.green : Colors.orange), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${cattle.name} (${cattle.earTag})', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          if (notification.notes.isNotEmpty) ...[const SizedBox(height: 4), Text(notification.notes, style: const TextStyle(color: Colors.black54, fontSize: 12))],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showNotificationDetailsDialog(TaskNotification notification, Cattle cattle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFE9F2F1), borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF22B89A))), GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24))]),
                const Divider(height: 20),
                _buildNotificationDetailRow('Due Date', '${notification.dueDate.day}/${notification.dueDate.month}/${notification.dueDate.year}'),
                const SizedBox(height: 12),
                _buildNotificationDetailRow('Cattle', '${cattle.name} (${cattle.earTag})'),
                const SizedBox(height: 12),
                if (notification.notes.isNotEmpty) ...[_buildNotificationDetailRow('Notes', notification.notes), const SizedBox(height: 12)],
                _buildNotificationDetailRow('Status', notification.completed ? 'Completed' : 'Pending'),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)), onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDetailRow(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))]);
  }
}

// ============ ADD NOTIFICATION SHEET ============

class AddNotificationSheet extends StatefulWidget {
  final Function(TaskNotification) onSave;
  const AddNotificationSheet({super.key, required this.onSave});
  @override
  State<AddNotificationSheet> createState() => _AddNotificationSheetState();
}

class _AddNotificationSheetState extends State<AddNotificationSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedCattleEarTag;
  final CattleStore store = CattleStore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedCattleEarTag = store.all.isNotEmpty ? store.all.first.earTag : 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerWithConfirm() async {
    DateTime temp = _selectedDate;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22B89A)),
                      onPressed: () {
                        setState(() => _selectedDate = temp);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveNotification() {
    if (_titleController.text.isEmpty || _selectedCattleEarTag.isEmpty || store.all.isEmpty) return;
    final notification = TaskNotification(cattleEarTag: _selectedCattleEarTag, title: _titleController.text, notes: _notesController.text, dueDate: _selectedDate);
    widget.onSave(notification);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFE9F2F1), child: SingleChildScrollView(padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))), const Text('Add Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), TextButton(onPressed: _saveNotification, child: const Text('Save', style: TextStyle(color: Color(0xFF22B89A), fontSize: 16)))]), const SizedBox(height: 16), Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)), padding: const EdgeInsets.symmetric(horizontal: 12), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedCattleEarTag, items: store.all.map((c) => DropdownMenuItem(value: c.earTag, child: Text('${c.name} (${c.earTag})'))).toList(), onChanged: (v) => setState(() { if (v != null) _selectedCattleEarTag = v; })))), const SizedBox(height: 12), _buildTextField('Title', _titleController), const SizedBox(height: 12), GestureDetector(onTap: _showDatePickerWithConfirm, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey, width: 0.5)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Due Date'), Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22B89A)))]))), const SizedBox(height: 12), _buildTextField('Notes', _notesController, maxLines: 3), const SizedBox(height: 24)])));
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 0.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
