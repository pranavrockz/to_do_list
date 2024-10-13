import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http; // For making HTTP requests

// Function to sign up a new user
Future<String> signup(String email, String password) async {
  try {
    // Validate email format
    if (!isValidEmail(email)) {
      return 'Error: Invalid email format.';
    }

    // Check if the email already exists
    if (await emailExists(email)) {
      return 'Error: The email $email is already registered.';
    }

    // Create a new user using Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String userId = userCredential.user?.uid ?? '';

    if (userId.isNotEmpty) {
      // Add user details to Firebase Database, excluding the password
      await FirebaseDatabase.instance.ref().child('users/$userId').set({
        'email': email,
        'created_at': DateTime.now().toString(),
      });
    }

    return 'Sign up successful: ${userCredential.user?.email}';
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase exceptions
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email provided is invalid.';
      default:
        return 'Error: ${e.message}';
    }
  } catch (e) {
    return 'An unexpected error occurred: $e';
  }
}

// Function to validate email format
bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

// Function to log in a user after resetting the password
Future<String> loginAfterReset(String email, String newPassword) async {
  try {
    // Sign in the user with the new password
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: newPassword,
    );

    String userId = userCredential.user?.uid ?? ''; // Get the user ID

    if (userId.isNotEmpty) {
      // Update the last password reset timestamp in Firebase Realtime Database
      await updatePasswordInDatabase(userId, newPassword);
    }

    // Successful login
    return 'Login successful: ${userCredential.user?.email}';
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth exceptions
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Error: ${e.message}';
    }
  } catch (e) {
    return 'Login failed: $e';
  }
}

// Function to update user password metadata in the Firebase Realtime Database
Future<String> updatePasswordInDatabase(String userId, String newPassword) async {
  final _database = FirebaseDatabase.instance.ref(); // Firebase Realtime Database reference
  try {
    // Update the last password reset timestamp instead of storing the password directly
    await _database.child('users/$userId').update({
      'last_password_reset': DateTime.now().toString(),  // Store the timestamp of the password reset
    });
    return 'Password reset timestamp updated successfully in the database.';
  } catch (e) {
    return 'Error updating the password metadata in the database: $e';
  }
}

// Function to send a password reset email
Future<String> sendResetPasswordEmail(String email) async {
  try {
    // Check if the email exists in Firebase before sending the reset email
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    if (signInMethods.isNotEmpty) {
      // If the email is registered, send a password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return 'Password reset email sent to $email';
    } else {
      // If the email is not registered, show error
      return 'Error: No user found for that email.';
    }
  } on FirebaseAuthException catch (e) {
    // Handle Firebase-specific errors
    if (e.code == 'invalid-email') {
      return 'Error: The email address is not valid.';
    } else {
      return 'Error: ${e.message}';
    }
  } catch (e) {
    // Handle other errors
    return 'An unexpected error occurred: $e';
  }
}

// Function to check if an email already exists in Firebase
Future<bool> emailExists(String email) async {
  try {
    // Try to fetch sign-in methods for the email to see if it already exists
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return signInMethods.isNotEmpty; // Return true if the email is registered
  } on FirebaseAuthException catch (e) {
    print('Firebase error occurred: ${e.message}');
    return false; // Assume the email doesn't exist on error
  } catch (e) {
    // If any error occurs, assume the email doesn't exist
    return false;
  }
}

// Function to validate email using ZeroBounce API
Future<bool> validateEmail(String email) async {
  const String apiKey = '823bf34ca65a4d23b93f2651bb44d022'; // Your ZeroBounce API key
  final Uri url = Uri.parse(
      'https://api.zerobounce.net/v2/validate?api_key=$apiKey&email=$email');

  try {
    // Send the GET request
    final response = await http.get(url);

    // Log the status code and response body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Validation Response: $data');

      // Check the status of the email validation
      if (data['status'] == 'valid') {
        return true; // Email is valid
      } else {
        print('Invalid email: ${data['status']}');
        return false; // Email is invalid
      }
    } else {
      print('Failed to validate email: ${response.body}');
      return false; // API call failed
    }
  } catch (e) {
    print('Error occurred while validating email: $e');
    return false; // Error occurred
  }
}

// Function to log in a user
Future<String> login(String email, String password) async {
  try {
    // Sign in the user using Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Successful login
    return 'Logged in successfully: ${userCredential.user?.email}';
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth exceptions
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Error: ${e.message}';
    }
  } catch (e) {
    // Handle any other exceptions (network issues, etc.)
    return 'Login failed: $e';
  }
}
