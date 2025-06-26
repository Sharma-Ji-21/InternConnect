import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intern_connect/company_screen.dart';
import 'package:intern_connect/student_screen.dart';
import 'package:lottie/lottie.dart';

import 'button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController emailInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController nameInputController = TextEditingController();
  late var obscureText = true;
  late var passIcon = Icons.remove_red_eye;
  String selectedRole = 'Student';
  List<String> roles = ['Student', 'Company'];

  @override
  void initState() {
    super.initState();
    emailInputController.addListener(() {
      setState(() {});
    });
    passwordInputController.addListener(() {
      setState(() {});
    });
    nameInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailInputController.removeListener(() {
      listener:
      (context);
    });
    passwordInputController.removeListener(() {
      listener:
      (context);
    });
    nameInputController.removeListener(() {
      listener:
      (context);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                    child: Container(
                        height: 250,
                        width: 250,
                        child: Lottie.asset('assets/animations/lottie4.json'))),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[500]),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Create your Account",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.black,
                        value: selectedRole,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        isExpanded: true,
                        items: roles.map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: nameInputController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Enter your name",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      suffixIcon: nameInputController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                nameInputController.clear();
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              )),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white, // Color when not focused
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: emailInputController,
                    decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "Enter your email",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.yellow, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        suffixIcon: emailInputController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  emailInputController.clear();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white, // Color when not focused
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: obscureText,
                    controller: passwordInputController,
                    decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "Enter your Password",
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.yellow,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        suffixIcon: passwordInputController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (obscureText) {
                                      passIcon = Icons.visibility_off;
                                    } else {
                                      passIcon = Icons.visibility_sharp;
                                    }
                                    obscureText = !obscureText;
                                  });
                                },
                                icon: Icon(
                                  passIcon,
                                  color: Colors.white,
                                )),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white, // Color when not focused
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: LoadingAnimatedButton(
                    onTap: () {
                      RegisterUser();
                    },
                    color: Colors.yellow,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: TextStyle(
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Sign In!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void RegisterUser() {
    var email = emailInputController.text.toString();
    var password = passwordInputController.text.toString();
    var name = nameInputController.text.toString();
    var role = selectedRole.toString();
    if (email.isEmpty || password.isEmpty || role.isEmpty || name.isEmpty) {
      Fluttertoast.showToast(
          msg: "Fields can\'t be empty", backgroundColor: Colors.red);
    } else {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        var user = value.user;
        var uid = user?.uid;
        addUserData(uid!);
      }).catchError((error) {
        Fluttertoast.showToast(
            msg: error.toString(),
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 2);
      });
      // Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      print(
          "User Registered with Email: $email, Password: $password, Role: $role");
    }
  }

  void addUserData(String uid) {
    Map<String, dynamic> data = {
      'email': emailInputController.text.toString(),
      'name': nameInputController.text.toString(),
      'role': selectedRole.toString(),
      'uid': uid,
      'password': passwordInputController.text.toString(),
      'createdAt': DateTime.now().toIso8601String()
    };
    if (selectedRole.toString() == 'Company') {
      FirebaseFirestore.instance
          .collection('companies')
          .doc(uid)
          .set(data)
          .then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => CompanyScreen(
                      email: emailInputController.text.toString(),
                    )));
        Fluttertoast.showToast(
            msg: "Successful Registered as Company",
            backgroundColor: Colors.green);
      }).catchError((onError) {
        Fluttertoast.showToast(
            msg: "Error: $onError", backgroundColor: Colors.red);
      });
    } else {
      FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .set(data)
          .then((value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => StudentScreen(
                      studentEmail: emailInputController.text.toString(),
                    )));
        Fluttertoast.showToast(
            msg: "Successful Registered as Student",
            backgroundColor: Colors.green);
      }).catchError((onError) {
        Fluttertoast.showToast(
            msg: "Error: $onError", backgroundColor: Colors.red);
      });
    }
  }
}
