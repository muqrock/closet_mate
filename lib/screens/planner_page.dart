import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late Database _db;
  late final ValueNotifier<List<String>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};
  List<String> _allOutfits = []; // 🆕 Store all outfit names

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'closetmate.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS planner(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            outfitName TEXT
          )
        ''');
      },
    );
    await _loadEvents();
    await _loadOutfits(); // 🆕 Load outfits
  }

  Future<void> _loadEvents() async {
    final rows = await _db.query('planner');
    final Map<DateTime, List<String>> newEvents = {};
    for (final row in rows) {
      final date = DateTime.parse(row['date'] as String);
      newEvents[DateTime(date.year, date.month, date.day)] = [
        ...(newEvents[DateTime(date.year, date.month, date.day)] ?? []),
        row['outfitName'] as String,
      ];
    }
    setState(() {
      _events = newEvents;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  Future<void> _loadOutfits() async {
    final rows = await _db.query('outfits');
    final outfits = rows.map((row) => row['name'] as String).toList();
    setState(() => _allOutfits = outfits);
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _addEvent(String outfitName) async {
    final dateStr = _selectedDay!.toIso8601String();
    await _db.insert('planner', {'date': dateStr, 'outfitName': outfitName});
    await _loadEvents();
  }

  void _showAddEventDialog() {
    String? selectedOutfit;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Outfit Plan'),
          content: _allOutfits.isEmpty
              ? const Text('No outfits available.')
              : DropdownButtonFormField<String>(
                  value: selectedOutfit,
                  items: _allOutfits
                      .map((name) =>
                          DropdownMenuItem(value: name, child: Text(name)))
                      .toList(),
                  onChanged: (value) {
                    selectedOutfit = value;
                  },
                  decoration: const InputDecoration(labelText: 'Select Outfit'),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedOutfit != null) {
                  await _addEvent(selectedOutfit!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectedEvents.value = _getEventsForDay(selectedDay);
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _allOutfits.isEmpty ? null : _showAddEventDialog,
            child: const Text('Add Outfit Plan'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(value[index]),
                  leading: const Icon(Icons.checkroom),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
