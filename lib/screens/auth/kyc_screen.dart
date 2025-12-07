import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idNumberCtrl = TextEditingController();
  String idType = 'identity_card';
  File? frontImage;
  File? backImage;
  File? selfieImage;

  bool uploading = false;
  double progress = 0.0;

  final picker = ImagePicker();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<File?> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> uploadAndSave() async {
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    if (frontImage == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide required images')),
      );
      return;
    }

    setState(() {
      uploading = true;
      progress = 0.0;
    });

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      // Upload front
      final frontRef = storage.ref().child('kyc/$uid/front.jpg');
      final frontUpload = await frontRef.putFile(frontImage!);
      final frontUrl = await frontRef.getDownloadURL();

      // Upload back (optional)
      String? backUrl;
      if (backImage != null) {
        final backRef = storage.ref().child('kyc/$uid/back.jpg');
        await backRef.putFile(backImage!);
        backUrl = await backRef.getDownloadURL();
      }

      // Upload selfie
      final selfieRef = storage.ref().child('kyc/$uid/selfie.jpg');
      await selfieRef.putFile(selfieImage!);
      final selfieUrl = await selfieRef.getDownloadURL();

      // Save to Firestore
      final userDoc = firestore.collection('users').doc(uid);
      await userDoc.set({
        'kycStatus': 'pending',
        'kyc': {
          'idType': idType,
          'idNumber': idNumberCtrl.text.trim(),
          'frontImageUrl': frontUrl,
          'backImageUrl': backUrl,
          'selfieImageUrl': selfieUrl,
          'submittedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        uploading = false;
        progress = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submitted — awaiting review')),
      );

      // Navigate to dashboard or a "KYC Pending" screen
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() {
        uploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Widget imagePickerTile(String title, File? file, VoidCallback onPick) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 130,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                file == null
                    ? Center(child: Text('Tap to add'))
                    : Image.file(file, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    idNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            uploading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Uploading...'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress),
                  ],
                )
                : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload ID documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: idType,
                          items: const [
                            DropdownMenuItem(
                              value: 'identity_card',
                              child: Text('Identity Card'),
                            ),
                            DropdownMenuItem(
                              value: 'passport',
                              child: Text('Passport'),
                            ),
                            DropdownMenuItem(
                              value: 'driver_license',
                              child: Text('Driver License'),
                            ),
                          ],
                          onChanged:
                              (v) => setState(() => idType = v ?? idType),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID Type',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: idNumberCtrl,
                          decoration: const InputDecoration(
                            labelText: 'ID Number',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Enter ID number'
                                      : null,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            imagePickerTile(
                              'Front of ID',
                              frontImage,
                              () async {
                                final file = await pickImage(
                                  ImageSource.camera,
                                );
                                if (file != null)
                                  setState(() => frontImage = file);
                              },
                            ),
                            imagePickerTile('Back of ID', backImage, () async {
                              final file = await pickImage(ImageSource.camera);
                              if (file != null)
                                setState(() => backImage = file);
                            }),
                            imagePickerTile('Selfie', selfieImage, () async {
                              final file = await pickImage(ImageSource.camera);
                              if (file != null)
                                setState(() => selfieImage = file);
                            }),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              uploadAndSave();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('Submit for Verification'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Note: Your images are encrypted in transit and stored securely. Review may take up to 24-72 hours.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
