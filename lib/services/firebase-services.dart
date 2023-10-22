import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart%20';

class FirebaseServices {
  FirebaseStorage storage = FirebaseStorage.instance;

  // uploader image dans firebase
  Future uplaodFile(File imagePath) async {
    final destination = "images/${DateTime.now()}.jpg";

    try {
      final ref = storage.ref(destination);

      await ref.putFile(imagePath);
    } catch (e) {
      print(e);
    }
  }


}
