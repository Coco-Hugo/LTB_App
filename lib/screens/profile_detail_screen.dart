import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  // Profile fields
  String displayName = '';
  DateTime? dateOfBirth;
  String gender = '';
  String jobTitle = '';
  String jobIndustry = '';
  String mbtiType = '';
  String memberStatus = '';
  List<String> interests = [];
  String selfBio = '';
  String profileImage = '';
  List<String> interestedEvents = [];
  List<String> joinedEvents = [];
  List<String> ledEvents = [];

  // Controllers
  final _displayNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _jobIndustryController = TextEditingController();
  final _mbtiController = TextEditingController();
  final _selfBioController = TextEditingController();
  final _interestsController =
      TextEditingController(); // comma-separated interests

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      displayName = data['displayName'] ?? '';
      dateOfBirth = data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null;
      gender = data['gender'] ?? '';
      jobTitle = data['jobTitle'] ?? '';
      jobIndustry = data['jobIndustry'] ?? '';
      mbtiType = data['mbtiType'] ?? '';
      memberStatus = data['memberStatus'] ?? '';
      interests =
          data['interests'] != null ? List<String>.from(data['interests']) : [];
      selfBio = data['selfBio'] ?? '';
      profileImage = data['profileImage'] ?? '';
      interestedEvents = data['interestedEvents'] != null
          ? List<String>.from(data['interestedEvents'])
          : [];
      joinedEvents = data['joinedEvents'] != null
          ? List<String>.from(data['joinedEvents'])
          : [];
      ledEvents =
          data['ledEvents'] != null ? List<String>.from(data['ledEvents']) : [];

      // Update controllers
      _displayNameController.text = displayName;
      _jobTitleController.text = jobTitle;
      _jobIndustryController.text = jobIndustry;
      _mbtiController.text = mbtiType;
      _selfBioController.text = selfBio;
      _interestsController.text = interests.join(', ');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    if (!_isEditing) return;

    // Request permission
    PermissionStatus status;
    if (Platform.isAndroid && int.parse(Platform.version) >= 13) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access photos')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = widget.userId;
      final storageRef =
          FirebaseStorage.instance.ref().child('prof_pics/$uid.jpg');
      await storageRef.putFile(File(image.path));
      final downloadURL = await storageRef.getDownloadURL();

      setState(() {
        profileImage = downloadURL;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Parse interests from controller (comma-separated)
      final parsedInterests = _interestsController.text
          .split(',')
          .map((s) => s.trim())
          .where((element) => element.isNotEmpty)
          .toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'displayName': _displayNameController.text.trim(),
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'jobTitle': _jobTitleController.text.trim(),
        'jobIndustry': _jobIndustryController.text.trim(),
        'mbtiType': _mbtiController.text.trim(),
        'memberStatus': memberStatus,
        'interests': parsedInterests,
        'selfBio': _selfBioController.text.trim(),
        'profileImage': profileImage,
        // Keep events as they are (unchanged)
        'interestedEvents': interestedEvents,
        'joinedEvents': joinedEvents,
        'ledEvents': ledEvents,
      }, SetOptions(merge: true));

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Reload to reflect changes
    _loadUserData();
  }

  Future<void> _pickDateOfBirth() async {
    if (!_isEditing) return;
    final selected = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    if (selected != null) {
      setState(() {
        dateOfBirth = selected;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    if (_isEditing) {
      return TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xff212121),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );
    } else {
      final text =
          controller.text.isNotEmpty ? controller.text : "Not provided";
      return _buildInfoTile(label, text);
    }
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xff212121),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownField(String label, String value, List<String> items,
      {void Function(String?)? onChanged}) {
    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xff212121),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value.isNotEmpty ? value : null,
          hint: Text(label, style: const TextStyle(color: Colors.white70)),
          dropdownColor: const Color(0xff212121),
          iconEnabledColor: Colors.white70,
          isExpanded: true,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      );
    } else {
      return _buildInfoTile(label, value.isNotEmpty ? value : "Not provided");
    }
  }

  Widget _buildDateField(String label, DateTime? date) {
    String displayDate = "Not provided";
    if (date != null) {
      displayDate = "${date.day}/${date.month}/${date.year}";
    }

    if (_isEditing) {
      return InkWell(
        onTap: _pickDateOfBirth,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xff212121),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("$label: $displayDate",
              style: const TextStyle(color: Colors.white)),
        ),
      );
    } else {
      return _buildInfoTile(label, displayDate);
    }
  }

  Widget _buildEventsSection(String title, List<String> events) {
    if (events.isEmpty) {
      return _buildInfoTile(title, "No events");
    }

    // Just show events as a list of IDs
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xff212121),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title:",
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: events.map((e) {
              return Chip(
                label: Text(e, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.grey[800],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),
      appBar: AppBar(
        backgroundColor: const Color(0xff181818),
        title: const Text('Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  // Save changes
                  _saveProfile();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage.isEmpty
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Display Name", _displayNameController),
                  _buildDateField("Date of Birth", dateOfBirth),
                  _buildDropDownField(
                      "Gender", gender, ["Male", "Female", "Other"],
                      onChanged: (val) {
                    setState(() {
                      gender = val ?? '';
                    });
                  }),
                  _buildTextField("Job Title", _jobTitleController),
                  _buildTextField("Job Industry", _jobIndustryController),
                  _buildTextField("MBTI Type", _mbtiController),
                  _buildDropDownField("Member Status", memberStatus,
                      ["Admin", "Leader", "Regular"], onChanged: (val) {
                    setState(() {
                      memberStatus = val ?? '';
                    });
                  }),

                  if (_isEditing)
                    TextField(
                      controller: _interestsController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Interests (comma-separated)",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xff212121),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    _buildInfoTile("Interests",
                        interests.isNotEmpty ? interests.join(", ") : "None"),

                  if (_isEditing)
                    TextField(
                      controller: _selfBioController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Self Bio",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xff212121),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  else
                    _buildInfoTile(
                        "Self Bio", selfBio.isNotEmpty ? selfBio : "No Bio"),

                  const SizedBox(height: 20),
                  _buildEventsSection("Interested Events", interestedEvents),
                  _buildEventsSection("Joined Events", joinedEvents),
                  _buildEventsSection("Led/Hosted Events", ledEvents),
                ],
              ),
            ),
    );
  }
}
