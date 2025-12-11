import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isUploading = false;

  // --- ФУНКЦІЯ ЗМІНИ ФОТО ---
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final fileName = '${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('user_avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from('user_avatars')
          .getPublicUrl(fileName);

      await user!.updatePhotoURL(publicUrl);
      await user!.reload();
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Фото оновлено!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _editName() async {
    final TextEditingController nameController = TextEditingController(text: user?.displayName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Змінити ім'я"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Ваше ім'я"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Скасувати"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await user!.updateDisplayName(nameController.text.trim());
                  await user!.reload();
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                }
              }
            },
            child: const Text("Зберегти"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Не авторизовано")));
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? 'Гість';

    return Scaffold(
      appBar: AppBar(title: const Text('Мій профіль')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, size: 60) : null,
                ),
                if (_isUploading) const Positioned.fill(child: CircularProgressIndicator()),
                Positioned(
                  bottom: 0, right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue, radius: 20,
                    child: IconButton(icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white), onPressed: _uploadImage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: _editName,
                  tooltip: "Змінити ім'я",
                ),
              ],
            ),
            
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}