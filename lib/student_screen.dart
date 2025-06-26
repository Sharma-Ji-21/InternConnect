import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intern_connect/login_screen.dart';

class StudentScreen extends StatefulWidget {
  final studentEmail;
  const StudentScreen({super.key, required this.studentEmail});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<dynamic> allApplications = [];
  List<dynamic> myApplications = [];
  int currentPageIndex = 0;
  String? companyName;
  bool isApplying = false;
  var companyId = 0;
  String companyEmail = '';
  String? studentName;
  bool isRefreshing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

  void loadInitialData() {
    fetchMyApplications();
    fetchAllJobs();
    fetchStudentName();
  }

  void fetchAllJobs() {
    FirebaseFirestore.instance
        .collection('jobs')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<dynamic> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data().toString());
      });
      setState(() {
        allApplications = tempApplications;
        print(allApplications);
      });
    }).catchError((error) {
      print("Failed to fetch data: $error");
    });
  }

  void fetchStudentName() {
    FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: widget.studentEmail)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          studentName = querySnapshot.docs.first.get('name') as String;
        });
      }
    }).catchError((error) {
      print("Failed to fetch student name: $error");
    });
  }

  Future<void> refreshScreen() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      setState(() {
        allApplications.clear();
        myApplications.clear();
      });

      await Future.wait([
        _fetchAllJobsAsync(),
        _fetchMyApplicationsAsync(),
        _fetchStudentNameAsync(),
      ]);

      Fluttertoast.showToast(
        msg: "Data refreshed successfully!",
        textColor: Colors.black,
        backgroundColor: Colors.yellow,
        timeInSecForIosWeb: 1,
      );
    } catch (error) {
      print("Error refreshing data: $error");
      Fluttertoast.showToast(
        msg: "Failed to refresh data",
        textColor: Colors.white,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 2,
      );
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future<void> _fetchAllJobsAsync() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('jobs').get();

      List<dynamic> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data().toString());
      });

      setState(() {
        allApplications = tempApplications;
        print(allApplications);
      });
    } catch (error) {
      print("Failed to fetch jobs: $error");
      throw error;
    }
  }

  Future<void> _fetchMyApplicationsAsync() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('studentEmail', isEqualTo: widget.studentEmail)
          .get();

      List<Map<String, dynamic>> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data() as Map<String, dynamic>);
      });

      setState(() {
        myApplications = tempApplications;
        print("----");
        print(myApplications);
      });
      print("Fetched ${myApplications.length} Applications");
    } catch (error) {
      print("Failed to fetch Applications: $error");
      throw error;
    }
  }

  Future<void> _fetchStudentNameAsync() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: widget.studentEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          studentName = querySnapshot.docs.first.get('name') as String;
        });
      }
    } catch (error) {
      print("Failed to fetch student name: $error");
      throw error;
    }
  }

  Map<String, String> parseApplicationString(String str) {
    str = str.substring(1, str.length - 1);

    Map<String, String> result = {};
    str.split(',').forEach((element) {
      var pair = element.trim().split(':');
      if (pair.length == 2) {
        String key = pair[0].trim();
        String value = pair[1].trim();
        result[key] = value;
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "$studentName",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 28,
                  ),
            onPressed: isRefreshing ? null : refreshScreen,
            tooltip: 'Refresh',
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
                size: 28,
              ))
        ],
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: Colors.yellow,
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.white),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.pageview_rounded,
                color: Colors.black,
              ),
              icon: Icon(Icons.pageview_outlined),
              label: 'All Applications',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.perm_contact_cal,
                color: Colors.black,
              ),
              icon: Icon(Icons.perm_contact_cal_outlined),
              label: 'My Applications',
            ),
          ],
        ),
      ),
      body: <Widget>[
        Stack(
          children: [
            isApplying
                ? Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                parseApplicationString(
                                            allApplications[companyId])[
                                        'companyName'] ??
                                    '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 25.0, left: 20, right: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "Job Profile: ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          parseApplicationString(
                                                  allApplications[
                                                      companyId])['profile'] ??
                                              '',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 33,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0, left: 20, right: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "Location: ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          parseApplicationString(
                                                  allApplications[
                                                      companyId])['location'] ??
                                              '',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 33,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0, left: 20, right: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "Salary: ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "₹${parseApplicationString(allApplications[companyId])['salary']}" ??
                                              '',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 33,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0, left: 20, right: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "Description: ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          parseApplicationString(
                                                      allApplications[
                                                          companyId])[
                                                  'description'] ??
                                              '',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 20, right: 20),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isApplying = false;
                                      });
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      companyEmail = parseApplicationString(
                                                  allApplications[companyId])[
                                              'email'] ??
                                          '';
                                      String jobProfile =
                                          parseApplicationString(
                                                  allApplications[
                                                      companyId])['profile'] ??
                                              '';

                                      bool alreadyApplied =
                                          await doesApplicationExist(
                                              widget.studentEmail, jobProfile);

                                      if (alreadyApplied) {
                                        setState(() {
                                          isApplying = false;
                                        });
                                        Fluttertoast.showToast(
                                          msg:
                                              "You have already applied for this job!",
                                          textColor: Colors.white,
                                          backgroundColor: Colors.red,
                                          timeInSecForIosWeb: 2,
                                        );
                                      } else {
                                        storingInFireBase(
                                            companyEmail,
                                            parseApplicationString(
                                                        allApplications[
                                                            companyId])[
                                                    'companyName'] ??
                                                '');
                                        Fluttertoast.showToast(
                                          msg:
                                              "Application Submitted Successfully!",
                                          textColor: Colors.black,
                                          backgroundColor: Colors.yellow,
                                          timeInSecForIosWeb: 2,
                                        );
                                        setState(() {
                                          isApplying = false;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Apply Now",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : allApplications.isEmpty
                    ? Center(
                        child: Text(
                          isRefreshing
                              ? "Refreshing..."
                              : "Loading Applications...",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      )
                    : Stack(
                        children: [
                          GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 1.2),
                            itemCount: allApplications.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      isApplying = !isApplying;
                                      companyId = index;
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white24,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4.0),
                                            child: Text(
                                              parseApplicationString(
                                                          allApplications[
                                                              index])[
                                                      'companyName'] ??
                                                  '',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            parseApplicationString(
                                                        allApplications[index])[
                                                    'profile'] ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            parseApplicationString(
                                                        allApplications[index])[
                                                    'location'] ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "₹${parseApplicationString(allApplications[index])['salary']}" ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
          ],
        ),
        myApplications.isEmpty
            ? Center(
                child: Text(
                  isRefreshing ? "Refreshing ..." : "Loading Applications...",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              )
            : ListView.builder(
                itemCount: myApplications.length,
                itemBuilder: (context, index) {
                  Color color = Colors.white;
                  if (myApplications[index]['status'] == 'Accept') {
                    color = Colors.green;
                  } else if (myApplications[index]['status'] == 'Reject') {
                    color = Colors.red;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 10,
                              child: Text(
                                myApplications[index]['companyName']
                                        ?.toString() ??
                                    '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              top: 34,
                              left: 10,
                              child: Text(
                                myApplications[index]['companyProfile']
                                        ?.toString() ??
                                    '',
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 20,
                              child: Text(
                                myApplications[index]['companyEmail']
                                        ?.toString() ??
                                    '',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 18,
                              right: 25,
                              child: Text(
                                myApplications[index]['status']?.toString() ??
                                    '',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
      ][currentPageIndex],
    );
  }

  Future<bool> doesApplicationExist(
      String studentEmail, String jobProfile) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('studentEmail', isEqualTo: studentEmail)
          .where('companyProfile', isEqualTo: jobProfile)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking application existence: $e");
      return false;
    }
  }

  void storingInFireBase(String companyEmail, String companyName) {
    FirebaseFirestore.instance.collection('applications').add({
      'studentName': studentName,
      'studentEmail': widget.studentEmail,
      'companyEmail': companyEmail,
      'companyName': companyName,
      'companyProfile':
          parseApplicationString(allApplications[companyId])['profile'] ?? '',
      'status': 'Pending'
    }).then((value) {
      print("Application stored successfully");
      fetchMyApplications();
    }).catchError((error) {
      print("Failed to store application: $error");
    });
  }

  void fetchMyApplications() {
    FirebaseFirestore.instance
        .collection('applications')
        .where('studentEmail', isEqualTo: widget.studentEmail)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data() as Map<String, dynamic>);
      });
      setState(() {
        myApplications = tempApplications;
        print("----");
        print(myApplications);
      });
      print("Fetched ${myApplications.length} Applications");
    }).catchError((error) {
      print("Failed to fetch Applications: $error");
    });
  }
}
