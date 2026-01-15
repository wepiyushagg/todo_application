import 'dart:convert';
import 'package:flutter/material.dart';
import 'event_logger_service.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> with WidgetsBindingObserver {
  final EventLoggerService _loggerService = EventLoggerService();
  late Future<List<Map<String, dynamic>>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshEvents();
    }
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _loggerService.getLocalEvents();
    });
  }

  void _clearEvents() async {
    await _loggerService.clearAllEvents();
    _refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearEvents,
            tooltip: 'Clear All Events',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final metadata = event['metadata'] != null
                    ? jsonDecode(event['metadata'])
                    : null;
                return ListTile(
                  title: Text(event['eventName']),
                  subtitle: Text('From: ${event['fromScreen']} To: ${event['toScreen']}'),
                  trailing: Text(event['timestamp'] ?? ''),
                  onTap: () {
                    if (metadata != null) {
                      final prettyJson = const JsonEncoder.withIndent('  ').convert(metadata);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Metadata'),
                          content: SingleChildScrollView(child: Text(prettyJson)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
