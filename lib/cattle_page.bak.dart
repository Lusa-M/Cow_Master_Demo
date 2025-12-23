import 'package:flutter/material.dart';
import 'models/cattle.dart';
import 'models/cattle_store.dart';

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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF22B89A),
                    child: const Icon(Icons.pets, color: Colors.white),
                  ),
                  title: Text(cattle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(cattle.earTag),
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
            _buildNavBarItem(Icons.pets, 'Cattle', true, null),
            _buildNavBarItem(Icons.notifications, 'Notifications', false, null),
            _buildNavBarItem(Icons.assignment, 'Reports', false, null),
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
            ListTile(leading: const Icon(Icons.event, color: Colors.black), title: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.logout, color: Colors.black), title: const Text('Dispose From Dairy', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => Navigator.pop(context)),
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
              _buildInfoRow('Ear tag', _cattle.earTag),
              _buildInfoRow('Name', _cattle.name),
              _buildInfoRow('Gender', _cattle.gender),
              _buildInfoRow('Breed', _cattle.breed),
              _buildInfoRow('Birth Date', '${_cattle.birthDate.day}/${_cattle.birthDate.month}/${_cattle.birthDate.year}'),
              _buildInfoRow('Age', _cattle.getAge()),
              _buildInfoRow('Dam ear tag', _cattle.damEarTag),
              _buildInfoRow('Sire name, tag', _cattle.sireName),
              _buildInfoRow('Notes', _cattle.notes),
            ])),
          ])),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _buildSelectionButton('Herd / Paddock', 'Select Group')), const SizedBox(width: 12), Expanded(child: _buildSelectionButton('Ration Name', 'Select Ration', isActive: true))]),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Event Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), FloatingActionButton(mini: true, backgroundColor: const Color(0xFF22B89A), onPressed: () {}, child: const Icon(Icons.add))])),
            const Padding(padding: EdgeInsets.all(12), child: Text('Event list is empty, click the + button to add event logs such as insemitation, dry, calving etc.', style: TextStyle(color: Colors.black54)))
          ])),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Notifications (60 days)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), FloatingActionButton(mini: true, backgroundColor: const Color(0xFF22B89A), onPressed: () {}, child: const Icon(Icons.add))])),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(decoration: BoxDecoration(color: const Color(0xFF546E7A), borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: const Text('28-31 Jan 26', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              const Text('Weaning Time', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("It's time for the planned weaning.", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              Row(children: [Checkbox(value: false, onChanged: (val) {}), const Text('Show completed notifications')])
            ]))
          ])),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(decoration: const BoxDecoration(color: Color(0xFF9E9E9E), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), padding: const EdgeInsets.all(12), child: const Text('Weight Records', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const Padding(padding: EdgeInsets.all(12), child: Text('Not enough weight records.', style: TextStyle(color: Colors.black54)))
          ])),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF22B89A), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String title, String placeholder, {bool isActive = false}) {
    return Container(
      decoration: BoxDecoration(color: isActive ? const Color(0xFFB3E5E1) : Colors.grey[300], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(title.contains('Herd') ? Icons.home : Icons.restaurant, color: Colors.black54),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(placeholder, style: TextStyle(color: Colors.black54, fontSize: 12)),
      ]),
    );
  }
}

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
