import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenSate();
  }
}

class _AuthScreenSate extends State<AuthScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLogging = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _userName = '';
  File? _userImage;
  var _isAuthenticating = false;

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    print('User isValid: $isValid');

    if (!isValid || !_isLogging && _userImage == null) {
      return;
    }

    _formKey.currentState!.save();
    print('User Email: $_email');
    print('User password: $_password');
    print('User _isLogging: $_isLogging');
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogging) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
        print('User credential: $userCredential');
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);

        /// Upload user image
        final storage = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storage.putFile(_userImage!);
        final imageUrl = await storage.getDownloadURL();
        print('User credential: $userCredential');
        print('User imageUrl: $imageUrl');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'user_name': _userName,
          'email': _email,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      /// on keyword is used for specific exception may come
      if (error.code == 'email-already-in-use') {
        print('User credential: email-already-in-use');
      }
      if (error.code == 'invalid-email') {
        print('User credential: invalid-email');
      }
      if (error.code == 'weak-password') {
        print('User credential: weak-password');
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed.'),
          duration: const Duration(
            milliseconds: 2,
          ),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogging)
                            UserImagePicker(
                              onSelectedImage: (image) {
                                _userImage = image;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Email'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.next,
                            focusNode: _emailFocus,
                            onFieldSubmitted: (value) {
                              _fieldFocusChange(context, _emailFocus,
                                  _isLogging ? _passwordFocus : _userNameFocus);
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter valid email.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue!;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (!_isLogging)
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              focusNode: _userNameFocus,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(
                                    context, _userNameFocus, _passwordFocus);
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter valid user name at least 4 characters.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _userName = newValue!;
                              },
                              decoration: const InputDecoration(
                                labelText: 'User name',
                              ),
                              enableSuggestions: false,
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            focusNode: _passwordFocus,
                            onFieldSubmitted: (value) {
                              _passwordFocus.unfocus();
                            },
                            decoration: const InputDecoration(
                              label: Text('Password'),
                              suffixIcon: Icon(Icons.visibility_off),
                            ),
                            keyboardType: TextInputType.text,

                            /// Hide the password
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogging ? 'SignIn' : 'SignUp'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                setState(() {
                                  _isLogging = !_isLogging;
                                });
                              },
                              child: Text(_isLogging
                                  ? 'Create an account'
                                  : "I already have an account"),
                            )
                        ],
                      ),
                    ),
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
