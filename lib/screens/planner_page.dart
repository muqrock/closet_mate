// planner_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase_flutter; // Use alias
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user's UID

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  // Supabase client instance
  final supabase_flutter.SupabaseClient supabase =
      supabase_flutter.Supabase.instance.client;

  late final ValueNotifier<List<Map<String, dynamic>>>
      _selectedEvents; // Changed to Map<String, dynamic>
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events =
      {}; // Store full event data

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _loadEvents(); // Load events when the page initializes
  }

  // Helper to normalize DateTime to just year, month, day for map keys
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Please log in to view your planner.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch data from 'planner_events' table, filtered by user_firebase_uid
      final List<Map<String, dynamic>> data = await supabase
          .from('planner_events')
          .select('*')
          .eq('user_firebase_uid', currentUser.uid)
          .order('event_date', ascending: true); // Order by date

      final Map<DateTime, List<Map<String, dynamic>>> newEvents = {};
      for (final row in data) {
        // Parse the date string from Supabase and normalize it
        final DateTime eventDate =
            _normalizeDate(DateTime.parse(row['event_date'] as String));
        newEvents.update(
          eventDate,
          (existingList) => existingList..add(row),
          ifAbsent: () => [row],
        );
      }

      setState(() {
        _events = newEvents;
        // Update selected events for the current day
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
        _isLoading = false;
      });
    } on supabase_flutter.PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Error loading planner data: ${e.message}';
        _isLoading = false;
      });
      print('Supabase PostgrestException loading planner data: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
      print('An unexpected error loading planner data: $e');
    }
  }

  // Returns events for a given day (now returns full event maps)
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  Future<void> _addEvent(String outfitName) async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first.')),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add events.')),
      );
      return;
    }

    try {
      // Supabase DATE type expects 'YYYY-MM-DD'
      final String dateForSupabase =
          _selectedDay!.toIso8601String().split('T').first;

      await supabase.from('planner_events').insert({
        'user_firebase_uid': currentUser.uid,
        'event_date': dateForSupabase,
        'outfit_name': outfitName,
      });

      print('Event added to Supabase.');
      _loadEvents(); // Reload events to update UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit plan added!')),
      );
    } on supabase_flutter.PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding event: ${e.message}')),
      );
      print('Supabase PostgrestException adding event: ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      print('An unexpected error adding event: $e');
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await supabase.from('planner_events').delete().eq('id', eventId);
      print('Event deleted from Supabase: $eventId');
      _loadEvents(); // Reload events to update UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit plan deleted!')),
      );
    } on supabase_flutter.PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: ${e.message}')),
      );
      print('Supabase PostgrestException deleting event: ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      print('An unexpected error deleting event: $e');
    }
  }

  void _showAddEventDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Add Outfit Plan for ${_selectedDay != null ? '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}' : 'selected day'}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Outfit Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _addEvent(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String eventId, String outfitName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content:
            Text('Are you sure you want to delete "$outfitName" for this day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteEvent(eventId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // Ensure to normalize date for lookup
                _selectedEvents.value = _getEventsForDay(selectedDay);
              }
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            eventLoader: _getEventsForDay, // Use the new eventLoader
            calendarStyle: const CalendarStyle(
              // Customize appearance to show dots for events
              markersMaxCount: 3,
              // Style for events (dots)
              todayDecoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent, // Color of the event dots
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Hide the format button if not needed
              titleCentered: true,
              // 'leftToRightSystem' removed
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showAddEventDialog,
            child: const Text('Add Outfit Plan'),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadEvents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) => value.isEmpty
                            ? const Center(
                                child: Text('No outfit plans for this day.'))
                            : ListView.builder(
                                itemCount: value.length,
                                itemBuilder: (context, index) {
                                  final event = value[index];
                                  return ListTile(
                                    title: Text(event['outfit_name'] as String),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(
                                              event['id'] as String,
                                              event['outfit_name'] as String),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
        ],
      ),
    );
  }
}
