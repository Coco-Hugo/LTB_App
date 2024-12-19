import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:ltb_app/widgets/event_card.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  final _locationController = TextEditingController();
  final _feeController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  String _selectedCategory = '';

  // Changed from a single File to a List<File>
  final List<File> _imageFiles = [];

  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      // Request permission first
      PermissionStatus status;
      if (Platform.isAndroid && int.parse(Platform.version) >= 13) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200, // Optional: limit image size
        );

        if (image != null) {
          setState(() {
            _imageFiles.add(File(image.path));
          });
        } else {
          print('No image selected');
        }
      } else {
        print('Permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied to access photos')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];

    for (File imageFile in _imageFiles) {
      try {
        final String fileName =
            'events/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(imageFile);
        final url = await storageRef.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return downloadUrls;
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if the date and time are selected
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time for the event')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload images if selected
      final List<String> imageUrls = await _uploadImages();

      // Create event object
      // Make sure your Event model supports a list of image URLs
      final event = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrls: imageUrls, // updated field for multiple images
        dateTime: _selectedDateTime!,
        location: _locationController.text,
        fee: double.parse(_feeController.text),
        maxParticipants: int.parse(_maxParticipantsController.text),
        category: _selectedCategory,
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        participants: [FirebaseAuth.instance.currentUser!.uid],
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('events').add(event.toMap());

      // Navigate to home screen
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating event: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Images'),
        SizedBox(height: 8),
        // Display selected images in a scrollable row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // "Add Image" button (tappable container)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff212121),
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.add_photo_alternate,
                        color: Colors.white, size: 40),
                  ),
                ),
              ),
              // Display thumbnails of selected images
              ..._imageFiles.map((file) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff181818),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false)
          },
        ),
      ),
      backgroundColor: const Color(0xff181818),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildSectionTitle('Title'),
              _buildTextFormField(
                controller: _titleController,
                hint: 'Enter event title',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              // Description Field
              _buildSectionTitle('Description'),
              _buildTextFormField(
                controller: _descriptionController,
                hint: 'Describe your event',
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Description is required' : null,
              ),

              const SizedBox(height: 16),

              // Multiple Images
              _buildImageSection(),

              const SizedBox(height: 16),

              // DateTime Picker
              _buildSectionTitle('Event Date & Time'),
              ListTile(
                tileColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  _selectedDateTime != null
                      ? _selectedDateTime.toString()
                      : 'Tap to select date & time',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),

              const SizedBox(height: 16),

              // Location Field
              _buildSectionTitle('Location'),
              _buildTextFormField(
                controller: _locationController,
                hint: 'Enter event location',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Location is required' : null,
              ),

              const SizedBox(height: 16),

              // Fee Field
              _buildSectionTitle('Fee'),
              _buildTextFormField(
                controller: _feeController,
                hint: 'Enter event fee',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Fee is required';
                  if (double.tryParse(value!) == null) return 'Invalid fee';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Max Participants
              _buildSectionTitle('Max Participants'),
              _buildTextFormField(
                controller: _maxParticipantsController,
                hint: 'Enter max participants',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Max participants is required';
                  }
                  if (int.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Chips
              _buildSectionTitle('Category'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildCategoryChip('Discussion', Icons.mic),
                  _buildCategoryChip('Movie Night', Icons.movie),
                  _buildCategoryChip('Picnic', Icons.shopping_basket),
                  _buildCategoryChip('Socializing', Icons.people),
                ],
              ),

              const SizedBox(height: 32),

              // Create Event Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xff000080),
                  ),
                  onPressed: _isLoading ? null : _createEvent,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Event',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return FilterChip(
      selected: _selectedCategory == label,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.0),
          const SizedBox(width: 4.0),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.grey[800],
      selectedColor: const Color(0xff000080),
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = selected ? label : '';
        });
      },
    );
  }
}
