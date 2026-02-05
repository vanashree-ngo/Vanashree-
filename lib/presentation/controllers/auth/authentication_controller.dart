import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/generic/ApiResponse.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // final firebase_storage.FirebaseStorage _storage =
  //     firebase_storage.FirebaseStorage.instance;

  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    return image; // Let the UI handle Get.back()
  }

  Future<XFile?> pickImageFromCamera() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    return image;
  }

  Future<String> uploadImage(String userId, XFile? pickedFile) async {
    if (pickedFile == null) {
      print('No image picked.');
      return '';
    }

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('ProfileImage/$userId');

      // For Android/iOS

      File file = File(pickedFile.path);
      await ref.putFile(
        file,
        firebase_storage.SettableMetadata(contentType: 'image/jpeg'),
      );

      // Common to both: get the download URL
      String downloadURL = await ref.getDownloadURL();
      print(' Image uploaded: $downloadURL');
      return downloadURL;
    } catch (e) {
      print(' Error uploading image: $e');
      return '';
    }
  }

  Future<String?> getFCMToken() async {
    // Request permission to receive notifications
    await _firebaseMessaging.requestPermission();
    // Get FCM token
    return await _firebaseMessaging.getToken();
  }

  bool signUpValidator(String email, String password, String confirmPassword) {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      // showCommonSnackBar("Error", "Please enter all the Fields");
      return false;
    }
    if (password.length < 6) {
      //showCommonSnackBar("Error", "Password should be more than 6 digits");
      return false;
    }
    if (password != confirmPassword) {
      // showCommonSnackBar(
      //   "Error",
      //   "Password and confirm Password should be same",
      // );
      return false;
    }
    return true;
  }

  bool signInValidator(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      // showCommonSnackBar("Error", "Please enter all the Fields");
      return false;
    }
    if (password.length < 6) {
      // showCommonSnackBar("Error", "Password should be more than 6 digits");
      return false;
    }

    return true;
  }

  Future<ApiResponse> signUpWithEmail(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (signUpValidator(email, password, confirmPassword)) {
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          return ApiResponse(
            status: true,
            message: "Sign up Success",
            data: {'uid': userCredential.user?.uid ?? ""},
          );
        } else {
          //showCommonSnackBar("Error", "Sign-up failed: ");
          return ApiResponse(status: false, message: "Sign up Error");
        }
      } on FirebaseAuthException catch (e) {
        // showCommonSnackBar("Error", "${e.message} ");
        return ApiResponse(
          status: false,
          message: e.message ?? "Sign up Failed",
        );
      }
    } else {
      return ApiResponse(status: false, message: "condition not satisfied");
    }
  }

  // Future<ApiResponse> signInWithEmail(String email, String password) async {
  //   if (signInValidator(email, password)) {
  //     try {
  //       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       if (userCredential.user != null) {
  //         // ApiResponse response = await ApiRepository().getUserByUid(
  //         //   userCredential.user?.uid ?? "",
  //         // );
  //         // return ApiResponse(status: true, message: "SignUp Successful");
  //
  //         if (response.status) {
  //           // update Locally
  //
  //           await saveProfileDataLocally(response.data as UserData);
  //           await addAccountToList(response.data as UserData);
  //
  //           return ApiResponse(
  //             status: true,
  //             message: "Sign in Success",
  //             data: {
  //               'user': response.data,
  //               'signin_success': true,
  //               'uid': userCredential.user?.uid ?? "",
  //             },
  //           );
  //         } else {
  //           return ApiResponse(
  //             status: true,
  //             message: "Internal error",
  //             data: {
  //               'uid': userCredential.user?.uid ?? "",
  //               'signin_success': false,
  //             },
  //           );
  //         }
  //       } else {
  //         showCommonSnackBar("Error", "Sign-In failed: ");
  //         return ApiResponse(status: false, message: "Sign In Error");
  //       }
  //     } on FirebaseAuthException catch (e) {
  //       showCommonSnackBar("Error", "Sign-In failed: ");
  //       return ApiResponse(
  //         status: false,
  //         message: e.message ?? "Sign-In failed",
  //       );
  //     }
  //   } else {
  //     return ApiResponse(status: false, message: "condition not satisfied");
  //   }
  // }

  // Future<ApiResponse> continueWithGooglePressed() async {
  //   try {
  //     final googleSignIn = GoogleSignIn();
  //
  //     final googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       return ApiResponse(status: false, message: "Google User Not selected");
  //     }
  //
  //     final googleAuth = await googleUser.authentication;
  //
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     UserCredential userCredential = await _auth.signInWithCredential(
  //       credential,
  //     );
  //     print("user credential of the google preseed==>${userCredential}");
  //     if (userCredential.user != null) {
  //       // return ApiResponse(status: true, message: "Success");
  //       // Notify LandingPageController to show the next dialog
  //       // Notify
  //
  //       ApiResponse response = await ApiRepository().getUserByUid(
  //         userCredential.user?.uid ?? "",
  //       );
  //       if (response.status) {
  //         //update locally
  //         await saveProfileDataLocally(response.data as UserData);
  //         await addAccountToList(response.data as UserData);
  //         return ApiResponse(
  //           status: true,
  //           message: "Google Sign in Success",
  //           data: {
  //             'user': response.data,
  //             'signin_success': true,
  //             'uid': userCredential.user?.uid ?? "",
  //             'email': userCredential.user?.email ?? '',
  //           },
  //         );
  //       } else {
  //         return ApiResponse(
  //           status: true,
  //           message: "GoogleSign Up",
  //           data: {
  //             'uid': userCredential.user?.uid ?? "",
  //             'email': userCredential.user?.email ?? '',
  //             'signin_success': false,
  //           },
  //         );
  //       }
  //     } else {
  //       showCommonSnackBar("Error", "Google Sign-In failed: ");
  //       return ApiResponse(status: false, message: "Google Sign In Error");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     print(e.toString());
  //     showCommonSnackBar("Error", "Google Sign-In failed: ${e.message}");
  //     return ApiResponse(status: false, message: "Google Sign In Error $e");
  //   }
  // }

  // Future<ApiResponse> signInWithFacebook() async {
  //   try {
  //     // Trigger the sign-in flow
  //     final LoginResult loginResult = await FacebookAuth.instance.login();
  //
  //     // Check if login is successful
  //     if (loginResult.status == LoginStatus.success) {
  //       final AccessToken accessToken = loginResult.accessToken!;
  //
  //       // Create a credential for Firebase
  //       final OAuthCredential facebookAuthCredential =
  //           FacebookAuthProvider.credential(accessToken.token);
  //
  //       // Sign in with Firebase using the Facebook credential
  //       UserCredential userCredential = await FirebaseAuth.instance
  //           .signInWithCredential(facebookAuthCredential);
  //
  //       if (userCredential.user != null) {
  //         ApiResponse response = await ApiRepository().getUserByUid(
  //           userCredential.user?.uid ?? "",
  //         );
  //         if (response.status) {
  //           await saveProfileDataLocally(response.data as UserData);
  //           await addAccountToList(response.data as UserData);
  //
  //           return ApiResponse(
  //             status: true,
  //             message: "Facebook Sign-In Successful",
  //             data: {
  //               'user': response.data,
  //               'signin_success': true,
  //               'uid': userCredential.user?.uid ?? "",
  //               'email': userCredential.user?.email ?? "",
  //             },
  //           );
  //         } else {
  //           return ApiResponse(
  //             status: true,
  //             message: "Facebook Sign-In Successful",
  //             data: {
  //               'user': userCredential.user,
  //               'signin_success': false,
  //               'uid': userCredential.user?.uid ?? "",
  //               'email': userCredential.user?.email ?? "",
  //             },
  //           );
  //         }
  //       } else {
  //         showCommonSnackBar("Error", "Facebook Sign-In failed");
  //         return ApiResponse(status: false, message: "Facebook Sign-In failed");
  //       }
  //     } else {
  //       showCommonSnackBar(
  //         "Error",
  //         loginResult.message ?? "Facebook login canceled",
  //       );
  //       return ApiResponse(status: false, message: "Facebook login canceled");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     showCommonSnackBar("Error", "Facebook Sign-In failed: ${e.message}");
  //     return ApiResponse(
  //       status: false,
  //       message: e.message ?? "Facebook Sign-In failed",
  //     );
  //   } catch (e) {
  //     print("FaceBook error --> $e");
  //     showCommonSnackBar("Error", "Something went wrong");
  //     return ApiResponse(status: false, message: "Unexpected error: $e");
  //   }
  // }
}
