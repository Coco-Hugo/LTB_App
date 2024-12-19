import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ltb_app/widgets/event_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xff181818),
      appBar: AppBar(
        backgroundColor: const Color(0xff181818),
        title: const Text('Upcoming Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('dateTime', isGreaterThan: now) // Only upcoming events
            .orderBy('dateTime', descending: false) // Earliest events first
            .snapshots(),
        builder: (context, snapshot) {
          // Error handling
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If no events found
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming events found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Build a list of EventCards
          final eventDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              final doc = eventDocs[index];
              final event =
                  Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);

              return EventCard(
                event: event,
                onTap: () {
                  // Handle event tap (e.g., navigate to event details)
                  Navigator.pushNamed(context, '/event-details',
                      arguments: event);
                },
              );
            },
          );
        },
      ),
    );
  }
}
