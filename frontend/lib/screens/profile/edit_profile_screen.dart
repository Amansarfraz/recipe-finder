import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

const List<String> kDietaryOptions = [
  'Vegetarian',
  'Vegan',
  'Gluten-Free',
  'Dairy-Free',
  'Keto',
  'Halal',
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late Set<String> selectedDiets;
  final ImagePicker _picker = ImagePicker();

  Uint8List? newPhotoBytes;
  String? newPhotoDataUri;
  String? existingPhotoUrl;
  bool isPickingPhoto = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    nameCtrl = TextEditingController(text: user?.name ?? '');
    selectedDiets = {...(user?.dietaryPrefs ?? [])};
    existingPhotoUrl = user?.profilePhoto;
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    setState(() => isPickingPhoto = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        imageQuality: 70,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ?? 'image/jpeg';
      setState(() {
        newPhotoBytes = bytes;
        newPhotoDataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not select photo: $e', isError: true);
    } finally {
      if (mounted) setState(() => isPickingPhoto = false);
    }
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Name cannot be empty', isError: true);
      return;
    }

    setState(() => isSaving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      name: name,
      profilePhoto: newPhotoDataUri,
      dietaryPrefs: selectedDiets.toList(),
    );
    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      _showSnack('Profile updated!');
      Navigator.pop(context);
    } else {
      _showSnack('Could not update profile: ${auth.error}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: isPickingPhoto ? null : _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: newPhotoBytes != null
                          ? MemoryImage(newPhotoBytes!)
                          : (existingPhotoUrl != null &&
                                  existingPhotoUrl!.isNotEmpty
                              ? NetworkImage(existingPhotoUrl!) as ImageProvider
                              : null),
                      child: (newPhotoBytes == null &&
                              (existingPhotoUrl == null ||
                                  existingPhotoUrl!.isEmpty))
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: isPickingPhoto
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Full Name',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Enter your name')),
            const SizedBox(height: 24),
            const Text('Dietary Preferences',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Select any that apply',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kDietaryOptions.map((diet) {
                final selected = selectedDiets.contains(diet);
                return FilterChip(
                  label: Text(diet),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textDark),
                  backgroundColor: Colors.white,
                  onSelected: (val) => setState(() {
                    if (val) {
                      selectedDiets.add(diet);
                    } else {
                      selectedDiets.remove(diet);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
