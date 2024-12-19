import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime dateTime;
  final String location;
  final double fee;
  final int maxParticipants;
  final String category;
  final String createdBy;
  final List<String> participants;

  Event({
    this.id = '',
    required this.title,
    required this.description,
    this.imageUrls = const [],
    required this.dateTime,
    required this.location,
    required this.fee,
    required this.maxParticipants,
    required this.category,
    required this.createdBy,
    this.participants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'dateTime': dateTime,
      'location': location,
      'fee': fee,
      'maxParticipants': maxParticipants,
      'category': category,
      'createdBy': createdBy,
      'participants': participants,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrls:
          map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : [],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      fee: (map['fee'] ?? 0).toDouble(),
      maxParticipants: map['maxParticipants'] ?? 0,
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const double titleSize = 18;
    const double subtitleSize = 14;
    const double iconSize = 16;
    const double avatarRadius = 10;
    const double statSize = 14;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: const Color(0xff212121),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 12,
            bottom: 15,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Column(
                children: [
                  const SizedBox(height: 3),
                  if (event.imageUrls.isNotEmpty)
                    // Display multiple images horizontally
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: event.imageUrls.map((url) {
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    // No images, show placeholder
                    Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.pin_drop,
                          size: iconSize,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(
                              letterSpacing: 0,
                              color: Colors.white70,
                              fontSize: subtitleSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: iconSize,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(event.dateTime),
                          style: const TextStyle(
                            letterSpacing: 0,
                            color: Colors.white70,
                            fontSize: subtitleSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Participant avatars
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where(FieldPath.documentId,
                                  whereIn: event.participants.take(3).toList())
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(width: 50);
                            }

                            return Row(
                              children: snapshot.data!.docs
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final userData =
                                    entry.value.data() as Map<String, dynamic>;
                                return Transform.translate(
                                  offset: Offset(
                                      entry.key * -1 * avatarRadius / 2, 0),
                                  child: CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundImage: NetworkImage(
                                        userData['profileImage'] ??
                                            'https://placeholder.com/user'),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xff0011ff),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${event.participants.length} / ${event.maxParticipants} Joined',
                            style: const TextStyle(
                              fontSize: statSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // Example of how to use it in a list view
// class EventListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('events').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return ListView(
//           children: snapshot.data!.docs.map((doc) {
//             final event = Event.fromMap(
//               doc.data() as Map<String, dynamic>,
//               doc.id,
//             );
//             return EventCard(
//               event: event,
//               onTap: () {
//                 // Handle event tap
//                 Navigator.pushNamed(context, '/event-details', arguments: event);
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }