import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ltb_app/screens/profile_detail_screen.dart';
import 'package:ltb_app/widgets/stat.dart';
import 'package:ltb_app/widgets/tag.dart';
import 'package:ltb_app/widgets/event_card.dart'; // Make sure the import path is correct

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateToProfileDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return Center(
              child: Text('Error: ${userSnapshot.error}'),
            );
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(
              child: Text('User not found or no data available'),
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final displayName = userData['displayName'] ?? 'No Name';
          final memberStatus = userData['memberStatus'] ?? '';
          final profileImage =
              userData['profileImage'] ?? 'https://via.placeholder.com/150';
          final dateOfBirth = userData['dateOfBirth'] != null
              ? (userData['dateOfBirth'] as Timestamp).toDate()
              : null;
          final dobText = dateOfBirth != null
              ? '${dateOfBirth.year}.${dateOfBirth.month.toString().padLeft(2, '0')}.${dateOfBirth.day.toString().padLeft(2, '0')}'
              : '';
          final gender = userData['gender'] ?? '';
          final jobTitle = userData['jobTitle'] ?? '';
          final jobIndustry = userData['jobIndustry'] ?? '';
          final mbtiType = userData['mbtiType'] ?? '';
          final interests =
              (userData['interests'] as List?)?.cast<String>() ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Profile Summary Container
              GestureDetector(
                onTap: () => _navigateToProfileDetail(context),
                child: Container(
                  color: const Color(0xff181818),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (memberStatus.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                memberStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$gender${gender.isNotEmpty && dobText.isNotEmpty ? ', ' : ''}$dobText\n${jobTitle.isNotEmpty ? jobTitle : ''}${jobTitle.isNotEmpty && jobIndustry.isNotEmpty ? ' for ' : ''}$jobIndustry',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      if (mbtiType.isNotEmpty || interests.isNotEmpty)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (mbtiType.isNotEmpty)
                              Tag(
                                  label: mbtiType,
                                  color: const Color(0x80800000)),
                            ...interests.map((interest) {
                              return Tag(
                                  label: interest,
                                  color: const Color(0x80008000));
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Statistics Row
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                color: const Color(0x00181818),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('participants', arrayContains: uid)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${eventSnapshot.error}'),
                      );
                    }

                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Stat(num: '--', label: 'Interested'),
                          Stat(num: '--', label: 'Joined'),
                          Stat(num: '--', label: 'Led / Hosted'),
                        ],
                      );
                    }

                    final allEvents = eventSnapshot.data?.docs ?? [];
                    final joinedCount = allEvents.length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Stat(
                            num: '0', label: 'Interested'), // Placeholder
                        Stat(num: '$joinedCount', label: 'Joined'),
                        const Stat(
                            num: '0', label: 'Led / Hosted'), // Placeholder
                      ],
                    );
                  },
                ),
              ),

              // Joined Events Section
              Expanded(
                child: Container(
                  color: const Color(0xff000000),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Joined Events',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('events')
                                .where('participants', arrayContains: uid)
                                .snapshots(),
                            builder: (context, eventSnapshot) {
                              if (eventSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${eventSnapshot.error}'),
                                );
                              }

                              if (eventSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              final eventDocs = eventSnapshot.data?.docs ?? [];
                              if (eventDocs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No events',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                child: Column(
                                  children: eventDocs.map((doc) {
                                    final event = Event.fromMap(
                                        doc.data() as Map<String, dynamic>,
                                        doc.id);
                                    return EventCard(
                                      event: event,
                                      onTap: () {
                                        // Navigate to event details if needed
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
