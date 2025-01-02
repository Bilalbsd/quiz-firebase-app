import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _uploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final avatarRef = storageRef.child('avatars/${image.name}');
      await avatarRef.putFile(File(image.path));
      // Logique pour mettre à jour l'URL de l'avatar dans Firestore
    }
  }

  Future<void> _uploadSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final storageRef = FirebaseStorage.instance.ref();
      final soundRef = storageRef.child('sounds/${result.files.single.name}');
      await soundRef.putFile(file);
      // Logique pour mettre à jour l'URL du son dans Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor:
            Colors.deepPurple, // Personnalisation de la couleur de l'AppBar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0), // Padding autour du contenu
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _uploadAvatar,
                icon: const Icon(Icons.camera_alt,
                    color: Colors.white), // Icône de caméra
                label: const Text(
                  'Ajouter un Avatar',
                  style: TextStyle(color: Colors.white), // Texte en blanc
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple, // Couleur de fond du bouton
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Padding autour du texte
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bords arrondis
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espacement entre les boutons
              ElevatedButton.icon(
                onPressed: _uploadSound,
                icon: const Icon(Icons.music_note,
                    color: Colors.white), // Icône de musique
                label: const Text(
                  'Ajouter un Son',
                  style: TextStyle(color: Colors.white), // Texte en blanc
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple, // Couleur de fond du bouton
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Padding autour du texte
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bords arrondis
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
