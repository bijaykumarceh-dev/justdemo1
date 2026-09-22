import 'package:flutter/material.dart';

void main() {
  runApp(const StudyTrackerApp());
}

class StudyTrackerApp extends StatelessWidget {
  const StudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StudyHomePage(),
    );
  }
}

class Subject {
  final String name;
  final int hours;
  final DateTime date;
  bool isCompleted;

  Subject({
    required this.name,
    required this.hours,
    required this.date,
    this.isCompleted = false,
  });
}

class HBLogo extends StatelessWidget {
  const HBLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'HB',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  final List<Subject> _subjects = [];
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();

  int get _totalHours =>
      _subjects.where((s) => s.isCompleted).fold<int>(0, (sum, s) => sum + s.hours);

  double get _averageHours => _subjects.isEmpty
      ? 0.0
      : _subjects.where((s) => s.isCompleted).fold<int>(0, (sum, s) => sum + s.hours) /
          _subjects.where((s) => s.isCompleted).length;

  void _addSubject() {
    final name = _nameController.text.trim();
    final hours = int.tryParse(_hoursController.text.trim());

    if (name.isEmpty || hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid subject name and hours')),
      );
      return;
    }

    setState(() {
      _subjects.add(Subject(
        name: name,
        hours: hours,
        date: DateTime.now(),
      ));
    });

    _nameController.clear();
    _hoursController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$name" added with $hours hours')),
    );
  }

  void _toggleComplete(int index) {
    setState(() {
      _subjects[index].isCompleted = !_subjects[index].isCompleted;
    });
  }

  void _deleteSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Study Subject',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  prefixIcon: Icon(Icons.menu_book),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            HBLogo(),
            SizedBox(width: 8),
            Text('Study Tracker'),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: _subjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return _buildSubjectCard(subject, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade100, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn('${_subjects.where((s) => s.isCompleted).length}', 'Completed', Colors.indigo),
          _statColumn('$_totalHours', 'Hours', Colors.purple),
          _statColumn(_averageHours.toStringAsFixed(1), 'Avg Hrs', Colors.blue),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No subjects yet!',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Tap + button to add your first subject',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: subject.isCompleted ? Colors.green : Colors.indigo,
          child: Text('${subject.hours}h',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(subject.name,
            style: TextStyle(
                decoration: subject.isCompleted ? TextDecoration.lineThrough : null,
                color: subject.isCompleted ? Colors.grey : Colors.black)),
        subtitle: Text('${_formatDate(subject.date)} • ${subject.isCompleted ? 'Done ✅' : 'Pending'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: subject.isCompleted,
              onChanged: (_) => _toggleComplete(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade300),
              onPressed: () => _deleteSubject(index),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
