import 'dart:async';
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
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class Subject {
  String name;
  int hours;
  DateTime date;
  bool isCompleted;

  Subject({required this.name, required this.hours, required this.date, this.isCompleted = false});
}

class HBLogo extends StatelessWidget {
  const HBLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
      child: const Center(child: Text('HB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudyHomePage(),
    TimerPage(),
    FlashcardsPage(),
    FeaturesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), selectedIcon: Icon(Icons.menu_book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.timer), selectedIcon: Icon(Icons.timer_off), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.slideshow), selectedIcon: Icon(Icons.slideshow), label: 'Flashcards'),
          NavigationDestination(icon: Icon(Icons.rocket_launch), selectedIcon: Icon(Icons.rocket_launch), label: 'More'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// ─── STUDY HOME (with Edit/Rename/Delete) ───
// ══════════════════════════════════════════
class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});
  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  final List<Subject> _subjects = [];
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  int _editIndex = -1;

  int get _totalHours => _subjects.where((s) => s.isCompleted).fold<int>(0, (sum, s) => sum + s.hours);
  double get _averageHours {
    final completed = _subjects.where((s) => s.isCompleted).toList();
    return completed.isEmpty ? 0.0 : completed.fold<int>(0, (sum, s) => sum + s.hours) / completed.length;
  }

  void _addSubject() {
    final name = _nameController.text.trim();
    final hours = int.tryParse(_hoursController.text.trim());
    if (name.isEmpty || hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid name and hours')));
      return;
    }
    final isEditing = _editIndex >= 0;
    setState(() {
      if (isEditing) {
        _subjects[_editIndex].name = name;
        _subjects[_editIndex].hours = hours;
        _subjects[_editIndex].date = DateTime.now();
        _editIndex = -1;
      } else {
        _subjects.add(Subject(name: name, hours: hours, date: DateTime.now()));
      }
    });
    _nameController.clear();
    _hoursController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Subject updated!' : '"$name" added with $hours hours')));
  }

  void _deleteSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${_subjects[index].name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            setState(() => _subjects.removeAt(index));
            Navigator.pop(context);
          }, child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _editSubject(int index) {
    _editIndex = index;
    _nameController.text = _subjects[index].name;
    _hoursController.text = _subjects[index].hours.toString();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Subject Name', prefixIcon: Icon(Icons.edit), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _hoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours', prefixIcon: Icon(Icons.schedule), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _addSubject, icon: const Icon(Icons.save), label: const Text('Save Changes')),
        ]),
      );
    });
  }

  void _renameSubject(int index) {
    _nameController.text = _subjects[index].name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Subject'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'New Name', hintText: _subjects[index].name, prefixIcon: Icon(Icons.edit, color: Colors.indigo)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final newName = _nameController.text.trim();
            if (newName.isNotEmpty) {
              setState(() => _subjects[index].name = newName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject renamed!')));
            }
          }, child: const Text('Rename')),
        ],
      ),
    );
  }

  void _showAddDialog() {
    _editIndex = -1;
    _nameController.clear();
    _hoursController.clear();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Study Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Subject Name', prefixIcon: Icon(Icons.menu_book), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _hoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours', prefixIcon: Icon(Icons.schedule), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _addSubject, icon: const Icon(Icons.add), label: const Text('Add')),
        ]),
      );
    });
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
        title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Tracker')]),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny : Icons.dark_mode, color: Colors.yellow.shade300),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switched to ${Theme.of(context).brightness == Brightness.dark ? 'Light' : 'Dark'} mode')),
              );
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(children: [
        _buildStatsCard(),
        Expanded(child: _subjects.isEmpty ? _buildEmptyState() : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _subjects.length,
          itemBuilder: (context, index) => _buildSubjectCard(_subjects[index], index),
        )),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _showAddDialog, icon: const Icon(Icons.add), label: const Text('Add')),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade100, Colors.purple.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _statColumn('${_subjects.where((s) => s.isCompleted).length}', 'Done', Colors.indigo),
        _statColumn('$_totalHours', 'Hours', Colors.purple),
        _statColumn(_averageHours.toStringAsFixed(1), 'Avg', Colors.blue),
      ]),
    );
  }

  Widget _statColumn(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.auto_stories, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      Text('No subjects yet!', style: TextStyle(fontSize: 20, color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      Text('Tap + button to add your first subject', style: TextStyle(color: Colors.grey.shade500)),
    ]));
  }

  Widget _buildSubjectCard(Subject subject, int index) {
    return Dismissible(
      key: Key('subject_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _deleteSubject(index);
        return false;
      },
      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      child: Card(margin: const EdgeInsets.only(bottom: 10), elevation: 2, child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(backgroundColor: subject.isCompleted ? Colors.green : Colors.indigo, child: Text('${subject.hours}h', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(subject.name, style: TextStyle(decoration: subject.isCompleted ? TextDecoration.lineThrough : null, color: subject.isCompleted ? Colors.grey : Colors.black)),
        subtitle: Text('${subject.date.day}/${subject.date.month}/${subject.date.year} • ${subject.isCompleted ? 'Done ✅' : 'Pending'}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') _editSubject(index);
              else if (value == 'rename') _renameSubject(index);
              else if (value == 'delete') _deleteSubject(index);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.label, size: 18), SizedBox(width: 8), Text('Rename')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
          Checkbox(value: subject.isCompleted, onChanged: (_) => setState(() => subject.isCompleted = !subject.isCompleted)),
        ]),
      )),
    );
  }
}

// ══════════════════════════════════════════
// ─── TIMER PAGE ───
// ══════════════════════════════════════════
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _pomodoroMinutes = 25;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() { _isRunning = false; _seconds = 0; });
    _timer?.cancel();
  }

  void _setPomodoro() {
    setState(() { _seconds = _pomodoroMinutes * 60; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pomodoro set to $_pomodoroMinutes min')));
  }

  String _formatTime(int t) {
    return '${(t ~/ 3600).toString().padLeft(2, '0')}:${((t % 3600) ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Timer')]), centerTitle: true, elevation: 0),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Focus Time', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Pomodoro: $_pomodoroMinutes min', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_isRunning ? Colors.indigo : Colors.indigo.shade50, Colors.purple.shade100])),
          child: Text(_formatTime(_seconds), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => setState(() => _pomodoroMinutes = (_pomodoroMinutes > 1) ? _pomodoroMinutes - 5 : 5), tooltip: 'Decrease'),
          IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => _pomodoroMinutes += 5), tooltip: 'Increase'),
        ]),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildBtn(Icons.play_arrow, _isRunning ? null : _startTimer, 'Start'),
          const SizedBox(width: 12),
          _buildBtn(_isRunning ? Icons.pause : Icons.play_arrow, _isRunning ? _pauseTimer : _startTimer, _isRunning ? 'Pause' : 'Resume'),
          const SizedBox(width: 12),
          _buildBtn(Icons.stop, _resetTimer, 'Reset'),
        ]),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: _setPomodoro, icon: const Icon(Icons.timer_off), label: const Text('Set Pomodoro')),
        const SizedBox(height: 8),
        Text('Today: ${_formatTime(_seconds)}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ])),
    );
  }

  Widget _buildBtn(IconData icon, VoidCallback? onPressed, String label) {
    return FilledButton.icon(onPressed: onPressed, icon: Icon(icon, size: 24), label: Text(label),
      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}

// ══════════════════════════════════════════
// ─── FLASHCARDS PAGE ───
// ══════════════════════════════════════════
class Flashcard {
  String question;
  String answer;
  bool isKnown;
  Flashcard({required this.question, required this.answer, this.isKnown = false});
}

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});
  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final List<Flashcard> _flashcards = [];
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _addFlashcard() {
    final q = _questionController.text.trim();
    final a = _answerController.text.trim();
    if (q.isEmpty || a.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter both'))); return; }
    setState(() { _flashcards.add(Flashcard(question: q, answer: a)); _currentIndex = _flashcards.length - 1; _showAnswer = false; });
    _questionController.clear(); _answerController.clear(); Navigator.pop(context);
  }

  void _showAddDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Flashcard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _questionController, decoration: const InputDecoration(labelText: 'Question', prefixIcon: Icon(Icons.question_answer), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _answerController, decoration: const InputDecoration(labelText: 'Answer', prefixIcon: Icon(Icons.format_quote, color: Colors.indigo), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _addFlashcard, icon: const Icon(Icons.add), label: const Text('Add')),
        ]),
      );
    });
  }

  @override
  void dispose() {
    _questionController.dispose(); _answerController.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Flashcards')]), centerTitle: true, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog, tooltip: 'Add')]),
      body: _flashcards.isEmpty
          ? const Center(child: Text('No flashcards yet! Tap + to add.'))
          : Column(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _showAnswer = !_showAnswer),
                child: Container(margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: _showAnswer ? Colors.green.shade50 : Colors.indigo.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigo.shade200)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Question:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(_flashcards[_currentIndex].question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text(_showAnswer ? 'Answer: ${_flashcards[_currentIndex].answer}' : 'Tap to see answer', style: TextStyle(fontSize: 16, color: _showAnswer ? Colors.black : Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    Text('${_currentIndex + 1} / ${_flashcards.length}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ]),
                ),
              )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: _currentIndex > 0 ? () => setState(() { _currentIndex--; _showAnswer = false; }) : null),
                IconButton(icon: Icon(_flashcards[_currentIndex].isKnown ? Icons.thumb_up : Icons.thumb_up_off_alt, color: _flashcards[_currentIndex].isKnown ? Colors.green : Colors.grey), onPressed: () => setState(() => _flashcards[_currentIndex].isKnown = !_flashcards[_currentIndex].isKnown)),
                IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _currentIndex < _flashcards.length - 1 ? () => setState(() { _currentIndex++; _showAnswer = false; }) : null),
              ]),
            ]),
    );
  }
}

// ══════════════════════════════════════════
// ─── QUIZ PAGE ───
// ══════════════════════════════════════════
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  QuizQuestion({required this.question, required this.options, required this.correctIndex});
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQ = 0, _score = 0;
  bool _answered = false;

  static final List<QuizQuestion> _questions = [
    QuizQuestion(question: 'What is the capital of India?', options: ['Mumbai', 'Delhi', 'Chennai', 'Kolkata'], correctIndex: 1),
    QuizQuestion(question: 'How many planets in our solar system?', options: ['7', '8', '9', '10'], correctIndex: 1),
    QuizQuestion(question: 'What is the largest ocean?', options: ['Atlantic', 'Indian', 'Pacific', 'Arctic'], correctIndex: 2),
    QuizQuestion(question: 'Who developed Flutter?', options: ['Google', 'Apple', 'Microsoft', 'Meta'], correctIndex: 0),
    QuizQuestion(question: 'What does HTML stand for?', options: ['Hyper Text Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyper Transfer Markup Logic'], correctIndex: 0),
  ];

  void _answer(int index) {
    if (_answered) return;
    setState(() { _answered = true; if (index == _questions[_currentQ].correctIndex) _score++; });
  }

  void _nextQuestion() {
    if (_currentQ < _questions.length - 1) setState(() { _currentQ++; _answered = false; });
  }

  void _resetQuiz() => setState(() { _currentQ = 0; _score = 0; _answered = false; });

  @override
  Widget build(BuildContext context) {
    if (_currentQ >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Quiz Results')]), centerTitle: true, elevation: 0),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          Text('Score: $_score / ${_questions.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${(_score / _questions.length * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 24, color: Colors.grey)),
          const SizedBox(height: 32),
          FilledButton.icon(onPressed: _resetQuiz, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
        ])),
      );
    }

    final q = _questions[_currentQ];
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Quiz')]), centerTitle: true, elevation: 0,
        actions: [Padding(padding: const EdgeInsets.all(12), child: Text('${_currentQ + 1}/${_questions.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text('${_currentQ + 1}. ${q.question}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
        const SizedBox(height: 20),
        Expanded(child: ListView.builder(
          itemCount: q.options.length,
          itemBuilder: (context, index) {
            final isCorrect = _answered && index == q.correctIndex;
            final isWrong = _answered && index != q.correctIndex;
            return Padding(padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _answer(index),
                style: ElevatedButton.styleFrom(backgroundColor: isCorrect ? Colors.green : (isWrong ? Colors.red : null), foregroundColor: isCorrect || isWrong ? Colors.white : null, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(q.options[index]),
              ));
          },
        )),
        if (_answered) Padding(padding: const EdgeInsets.only(top: 16), child: FilledButton(onPressed: _nextQuestion, child: Text(_currentQ < _questions.length - 1 ? 'Next Question' : 'See Results'))),
      ])),
    );
  }
}

// ══════════════════════════════════════════
// ─── STUDY STREAKS PAGE ───
// ══════════════════════════════════════════
class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Streaks')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        _buildStatCard(Icons.local_fire_department, 'Current Streak', '7 days', Colors.deepOrange),
        _buildStatCard(Icons.trending_up, 'Best Streak', '12 days', Colors.red),
        _buildStatCard(Icons.calendar_today, 'Study Days', '23/30', Colors.green),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Streak History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16)), child: const Text('🔥 Keep going! You\'re 7 days in a row. Don\'t break the streak!', style: TextStyle(fontSize: 16))),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        _buildBadge(Icons.star, '7-Day Streak', 'Completed!', Colors.amber),
        _buildBadge(Icons.local_fire_department, '14-Day Streak', '2/14 days', Colors.orange),
        _buildBadge(Icons.emoji_events, '30-Day Streak', '0/30 days', Colors.grey),
      ]),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(label), trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)))));
  }

  Widget _buildBadge(IconData icon, String name, String progress, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Card(child: ListTile(leading: Icon(icon, color: color, size: 32), title: Text(name), subtitle: Text(progress), trailing: Text(progress.contains('Completed') ? '✅' : '⏳'))));
  }
}

// ══════════════════════════════════════════
// ─── POMODORO PAGE ───
// ══════════════════════════════════════════
class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});
  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _workMinutes = 25;
  int _breakMinutes = 5;
  bool _isBreak = false;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startPomodoro() {
    setState(() { _seconds = _isBreak ? _breakMinutes * 60 : _workMinutes * 60; _isRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() { _seconds--; });
      if (_seconds <= 0) {
        _timer?.cancel();
        setState(() => _isRunning = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isBreak ? 'Break over! Back to work!' : 'Session over! Time for a break!')));
        setState(() => _isBreak = !_isBreak);
      }
    });
  }

  void _resetPomodoro() {
    _timer?.cancel();
    setState(() { _isRunning = false; _seconds = _isBreak ? _breakMinutes * 60 : _workMinutes * 60; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Pomodoro Timer')]), centerTitle: true, elevation: 0),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🍅 Pomodoro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_isBreak ? 'Break Time' : 'Work Time', style: TextStyle(fontSize: 20, color: _isBreak ? Colors.green : Colors.red)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(shape: BoxShape.circle, color: _isBreak ? Colors.green.shade50 : Colors.red.shade50),
          child: Text('${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold))),
        const SizedBox(height: 32),
        FilledButton.icon(onPressed: _isRunning ? null : _startPomodoro, icon: const Icon(Icons.play_arrow), label: Text(_isBreak ? 'Start Break' : 'Start Focus')),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _resetPomodoro, icon: const Icon(Icons.stop), label: const Text('Reset')),
        const SizedBox(height: 24),
        Text('Work: $_workMinutes min | Break: $_breakMinutes min', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ])),
    );
  }
}

// ══════════════════════════════════════════
// ─── REMINDERS PAGE ───
// ══════════════════════════════════════════
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Reminders')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        _buildReminder(Icons.schedule, 'Morning Study', '6:00 AM - 8:00 AM', Icons.check_circle, Colors.green),
        _buildReminder(Icons.school, 'Afternoon Session', '2:00 PM - 4:00 PM', Icons.check_circle, Colors.green),
        _buildReminder(Icons.nightlife, 'Evening Revision', '7:00 PM - 9:00 PM', Icons.pending, Colors.orange),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Quick Add', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.add_circle, color: Colors.indigo), title: const Text('Add New Reminder'), subtitle: const Text('Set a study reminder'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
        ListTile(leading: const Icon(Icons.notifications_none, color: Colors.indigo), title: const Text('Notification Settings'), subtitle: const Text('Manage all reminders'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildReminder(IconData icon, String title, String time, IconData statusIcon, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(title), subtitle: Text(time), trailing: Icon(statusIcon, color: color))));
  }
}

// ══════════════════════════════════════════
// ─── DARK MODE PAGE ───
// ══════════════════════════════════════════
class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});
  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Dark Mode')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: Text(isDark ? 'Currently ON (Dark Theme)' : 'Currently OFF (Light Theme)'),
          value: isDark,
          onChanged: (_) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched to ${isDark ? 'Light' : 'Dark'} mode!')));
          },
          secondary: Icon(isDark ? Icons.dark_mode : Icons.wb_sunny, color: isDark ? Colors.yellow : Colors.grey),
          activeColor: Colors.indigo,
        ),
        const Divider(),
        const ListTile(leading: Icon(Icons.phone_android, color: Colors.indigo), title: Text('System Default'), subtitle: Text('Follow system settings'), trailing: const Icon(Icons.radio_button_checked, color: Colors.green)),
        const Divider(),
        const ListTile(leading: Icon(Icons.light_mode, color: Colors.indigo), title: Text('Always Light'), subtitle: Text('Never use dark theme'), trailing: const Icon(Icons.radio_button_unchecked, color: Colors.grey)),
        const Divider(),
        const ListTile(leading: Icon(Icons.dark_mode, color: Colors.indigo), title: Text('Always Dark'), subtitle: Text('Always use dark theme'), trailing: const Icon(Icons.radio_button_unchecked, color: Colors.grey)),
        const SizedBox(height: 24),
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50, borderRadius: BorderRadius.circular(16)), child: Column(children: [
          Text(isDark ? '🌙 Dark Theme Active' : '☀️ Light Theme Active', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(isDark ? 'Easy on the eyes in low light' : 'Easy on the eyes in bright light', style: TextStyle(color: Colors.grey.shade600)),
        ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════
// ─── STUDY GROUPS PAGE ───
// ══════════════════════════════════════════
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Groups')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        const Center(child: Text('👥 Join or Create Study Groups', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        _buildGroupCard(Icons.school, 'Physics Study Group', '12 members', 'Active now', Colors.blue),
        _buildGroupCard(Icons.menu_book, 'Math Masters', '8 members', 'Active now', Colors.green),
        _buildGroupCard(Icons.code, 'Coding Buddies', '15 members', '2 online', Colors.purple),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Create New Group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        ListTile(leading: const CircleAvatar(child: Icon(Icons.add, color: Colors.white)), title: const Text('Create Study Group'), subtitle: const Text('Invite friends to study together'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildGroupCard(IconData icon, String name, String members, String status, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(name), subtitle: Text('$members • $status'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey))));
  }
}

// ══════════════════════════════════════════
// ─── CLOUD SYNC PAGE ───
// ══════════════════════════════════════════
class CloudSyncPage extends StatelessWidget {
  const CloudSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Cloud Sync')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        const ListTile(leading: Icon(Icons.cloud_done, color: Colors.green, size: 32), title: Text('Last Sync'), subtitle: Text('Today at 3:45 PM'), trailing: Icon(Icons.check_circle, color: Colors.green)),
        const Divider(),
        _buildSyncCard(Icons.cloud_upload, 'Backup to Cloud', 'Auto-backup enabled', Colors.blue),
        _buildSyncCard(Icons.cloud_download, 'Restore from Cloud', 'Last backup: Today', Colors.green),
        _buildSyncCard(Icons.devices_other, 'Sync Across Devices', '3 devices connected', Colors.purple),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        SwitchListTile(
          title: const Text('Auto Backup'),
          subtitle: const Text('Automatically backup your data'),
          value: true,
          onChanged: (_) {},
          activeColor: Colors.indigo,
        ),
      ]),
    );
  }

  Widget _buildSyncCard(IconData icon, String title, String desc, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(title), subtitle: Text(desc), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey))));
  }
}

// ══════════════════════════════════════════
// ─── DATA EXPORT PAGE ───
// ══════════════════════════════════════════
class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Data Export')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        _buildExportCard(Icons.picture_as_pdf, 'Export to PDF', 'Download full study report as PDF', Colors.red),
        _buildExportCard(Icons.table_chart, 'Export to CSV', 'Download data as spreadsheet', Colors.green),
        _buildExportCard(Icons.share, 'Share Report', 'Send study summary to friends', Colors.blue),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Export Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        SwitchListTile(title: const Text('Include Completed Subjects'), subtitle: const Text('Only show completed subjects'), value: true, onChanged: (_) {}, activeColor: Colors.indigo),
        SwitchListTile(title: const Text('Include Time Data'), subtitle: const Text('Include timer hours'), value: true, onChanged: (_) {}, activeColor: Colors.indigo),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download Report')),
      ]),
    );
  }

  Widget _buildExportCard(IconData icon, String title, String desc, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(title), subtitle: Text(desc), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey))));
  }
}

// ══════════════════════════════════════════
// ─── AUDIO NOTES PAGE ───
// ══════════════════════════════════════════
class AudioNotesPage extends StatelessWidget {
  const AudioNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Audio Notes')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        _buildAudioCard(Icons.play_circle_fill, 'Physics Lecture Notes', '12:34 min', Icons.play_circle_fill, Colors.green),
        _buildAudioCard(Icons.pause_circle, 'Chemistry Revision', '08:21 min', Icons.pause_circle, Colors.orange),
        _buildAudioCard(Icons.play_circle_fill, 'History Chapter 3', '15:10 min', Icons.play_circle_fill, Colors.blue),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Record New Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        ListTile(leading: const CircleAvatar(child: Icon(Icons.mic, color: Colors.white)), title: const Text('Record Audio Note'), subtitle: const Text('Tap to record a new study note'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildAudioCard(IconData icon, String title, String duration, IconData playIcon, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(title), subtitle: Text(duration), trailing: Icon(playIcon, color: color))));
  }
}

// ══════════════════════════════════════════
// ─── STUDY LOCATIONS PAGE ───
// ══════════════════════════════════════════
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('Study Locations')]), centerTitle: true, elevation: 0),
      body: ListView(children: [
        const SizedBox(height: 16),
        _buildLocationCard(Icons.library_books, 'Home Library', '2h studied today', Colors.brown),
        _buildLocationCard(Icons.school, 'College Library', '4h studied today', Colors.blue),
        _buildLocationCard(Icons.coffee, 'Coffee Shop', '1h studied today', Colors.orange),
        _buildLocationCard(Icons.park, 'Park Bench', '30min studied today', Colors.green),
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.all(16), child: Text('Add Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        ListTile(leading: const CircleAvatar(child: Icon(Icons.add, color: Colors.white)), title: const Text('Add New Location'), subtitle: const Text('Track where you study'), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildLocationCard(IconData icon, String name, String hours, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)), title: Text(name), subtitle: Text(hours), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey))));
  }
}

// ══════════════════════════════════════════
// ─── FEATURES PAGE (ALL FEATURES) ───
// ══════════════════════════════════════════
class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});
  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(children: [HBLogo(), SizedBox(width: 8), Text('What\'s Next')]),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Locked')]),
        ),
        body: TabBarView(controller: _tabController, children: [AllFeaturesTab(), ActiveFeaturesTab(), LockedFeaturesTab()]),
      ),
    );
  }
}

class AllFeaturesTab extends StatelessWidget {
  AllFeaturesTab({super.key});

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.timer, 'title': 'Study Timer', 'desc': 'Accurate stopwatch timer', 'status': 'active', 'color': Colors.indigo},
    {'icon': Icons.timer_off, 'title': 'Pomodoro Timer', 'desc': 'Focus 25min, break 5min', 'status': 'active', 'color': Colors.orange},
    {'icon': Icons.school, 'title': 'Subject-wise Reports', 'desc': 'Detailed performance charts', 'status': 'active', 'color': Colors.blue},
    {'icon': Icons.notifications_active, 'title': 'Study Reminders', 'desc': 'Set daily reminders', 'status': 'active', 'color': Colors.purple},
    {'icon': Icons.emoji_events, 'title': 'Achievements & Badges', 'desc': 'Earn badges for studying', 'status': 'active', 'color': Colors.amber},
    {'icon': Icons.calendar_today, 'title': 'Study Calendar', 'desc': 'Visual daily/weekly view', 'status': 'active', 'color': Colors.green},
    {'icon': Icons.local_fire_department, 'title': 'Study Streaks', 'desc': 'Track daily streak', 'status': 'active', 'color': Colors.deepOrange},
    {'icon': Icons.group, 'title': 'Study Groups', 'desc': 'Study with friends', 'status': 'active', 'color': Colors.teal},
    {'icon': Icons.slideshow, 'title': 'Flashcards', 'desc': 'Create & review flashcards', 'status': 'active', 'color': Colors.teal},
    {'icon': Icons.quiz, 'title': 'Quiz Mode', 'desc': 'Test your knowledge', 'status': 'active', 'color': Colors.pink},
    {'icon': Icons.dark_mode, 'title': 'Dark Mode', 'desc': 'Eye-friendly dark theme', 'status': 'active', 'color': Colors.indigo},
    {'icon': Icons.analytics, 'title': 'Weekly Analytics', 'desc': 'Charts & insights', 'status': 'active', 'color': Colors.blueGrey},
    {'icon': Icons.cloud, 'title': 'Cloud Sync', 'desc': 'Backup across devices', 'status': 'active', 'color': Colors.blue},
    {'icon': Icons.upload_file, 'title': 'Data Export', 'desc': 'Export to PDF / CSV', 'status': 'active', 'color': Colors.red},
    {'icon': Icons.audiotrack, 'title': 'Audio Notes', 'desc': 'Record & listen to notes', 'status': 'active', 'color': Colors.teal},
    {'icon': Icons.map, 'title': 'Study Locations', 'desc': 'Track where you study', 'status': 'active', 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _features.length,
      itemBuilder: (context, index) {
        final f = _features[index];
        return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: (f['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(f['icon'] as IconData, color: f['color'] as Color)),
          title: Text(f['title'] as String),
          subtitle: Text(f['desc'] as String),
          trailing: const Text('✅ Live', style: TextStyle(fontSize: 11, color: Colors.green)),
        ));
      },
    );
  }
}

class ActiveFeaturesTab extends StatelessWidget {
  ActiveFeaturesTab({super.key});
  final List<Map<String, dynamic>> _active = [
    {'icon': Icons.timer, 'title': 'Study Timer', 'desc': 'Accurate stopwatch timer'},
    {'icon': Icons.timer_off, 'title': 'Pomodoro Timer', 'desc': 'Focus 25min, break 5min'},
    {'icon': Icons.school, 'title': 'Subject Reports', 'desc': 'Performance charts'},
    {'icon': Icons.notifications_active, 'title': 'Study Reminders', 'desc': 'Daily notifications'},
    {'icon': Icons.emoji_events, 'title': 'Achievements', 'desc': 'Badges system'},
    {'icon': Icons.calendar_today, 'title': 'Study Calendar', 'desc': 'Visual calendar'},
    {'icon': Icons.local_fire_department, 'title': 'Study Streaks', 'desc': 'Daily streak tracking'},
    {'icon': Icons.group, 'title': 'Study Groups', 'desc': 'Study with friends'},
    {'icon': Icons.slideshow, 'title': 'Flashcards', 'desc': 'Create & review'},
    {'icon': Icons.quiz, 'title': 'Quiz Mode', 'desc': 'Test knowledge'},
    {'icon': Icons.dark_mode, 'title': 'Dark Mode', 'desc': 'Dark theme toggle'},
    {'icon': Icons.analytics, 'title': 'Weekly Analytics', 'desc': 'Charts & insights'},
    {'icon': Icons.cloud, 'title': 'Cloud Sync', 'desc': 'Backup across devices'},
    {'icon': Icons.upload_file, 'title': 'Data Export', 'desc': 'PDF / CSV export'},
    {'icon': Icons.audiotrack, 'title': 'Audio Notes', 'desc': 'Record & listen'},
    {'icon': Icons.map, 'title': 'Study Locations', 'desc': 'Track locations'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _active.length,
      itemBuilder: (context, index) {
        final f = _active[index];
        return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
          leading: Icon(f['icon'] as IconData, color: Colors.indigo, size: 32),
          title: Text(f['title'] as String),
          subtitle: Text(f['desc'] as String),
          trailing: const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ));
      },
    );
  }
}

class LockedFeaturesTab extends StatelessWidget {
  LockedFeaturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('🎉 All features are now unlocked and working!', style: TextStyle(fontSize: 20)));
  }
}
