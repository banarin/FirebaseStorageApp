import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart%20';
import 'package:firebase_storage_app/services/firebase-services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imagePath;
  List<String> imageUrls = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllImage();
  }

  //recuperer tous les images dans firebase
  Future<void> getAllImage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child("images");

      // List all items (images) in the "images" directory
      final result = await ref.listAll();

      for (final imageRef in result.items) {
        final url = await imageRef.getDownloadURL();

        setState(() {
          imageUrls.add(url);
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Firebase Storage",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: imageUrls.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onLongPress: () {
                          _deleteImageShowDialog(imageUrls[index]);
                        },
                        child: imageContainer(imageUrls[index]));
                  },
                ),
              ),
        floatingActionButton: SpeedDial(
          gradientBoxShape: BoxShape.circle,
          icon: Icons.add,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.photo_library),
                onTap: () {
                  pickedImageFromGalery();
                }),
            SpeedDialChild(
                child: const Icon(Icons.photo_camera),
                onTap: () {
                  pickedImageFromCamera();
                }),
          ],
        ));
  }

  Future pickedImageFromGalery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    setState(() {
      imagePath = File(image.path);
    });
    _showDialog();
  }

  Future pickedImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    setState(() {
      imagePath = File(image.path);
    });
    _showDialog();
  }

  _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: 400,
              height: 400,
              padding: const EdgeInsets.all(10),
              child: Image.file(
                imagePath!,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  FirebaseServices().uplaodFile(imagePath!);
                  Navigator.pop(context);
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text(
                      "ENVOYER",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text(
                      "ANNULER",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  _deleteImageShowDialog(String image) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Container(
                width: 400,
                height: 400,
                padding: const EdgeInsets.all(10),
                child: Image.network(image)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          "ANNULER",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final deletRef =
                          FirebaseStorage.instance.ref().child(image);
                      await deletRef.delete();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          "SUPPRIMER",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Widget imageContainer(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
