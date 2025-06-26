import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intern_connect/login_screen.dart';

class CompanyScreen extends StatefulWidget {
  final email;

  const CompanyScreen({super.key, required this.email});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  int currentPageIndex = 0;
  List<Map<String, dynamic>> Applications = [];
  bool addItem = false;
  bool isLoading = false;
  TextEditingController jobProfileController = TextEditingController();
  TextEditingController jobDescriptionController = TextEditingController();
  TextEditingController jobLocationController = TextEditingController();
  TextEditingController jobSalaryController = TextEditingController();
  String? companyName;
  var jobStatus = 'Pending';
  List<Map<String, dynamic>> Entries = [];
  List<String> status = ['Accept', 'Pending', 'Reject'];

  @override
  void initState() {
    jobProfileController.addListener(() {
      setState(() {});
    });
    jobDescriptionController.addListener(() {
      setState(() {});
    });
    jobLocationController.addListener(() {
      setState(() {});
    });
    jobSalaryController.addListener(() {
      setState(() {});
    });
    fetchCompanyName();
    fetchAppplications();
    fetchEntries();
    super.initState();
  }

  void reloadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _fetchCompanyNameAsync(),
        _fetchApplicationsAsync(),
        _fetchEntriesAsync(),
      ]);

      Fluttertoast.showToast(
        msg: "Data refreshed successfully!",
        backgroundColor: Colors.yellow,
        timeInSecForIosWeb: 2,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to refresh data",
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 2,
      );
      print("Error reloading data: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCompanyNameAsync() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          companyName = querySnapshot.docs.first.get('name') as String;
        });
      }
    } catch (error) {
      print("Failed to fetch company name: $error");
      throw error;
    }
  }

  Future<void> _fetchApplicationsAsync() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('email', isEqualTo: widget.email)
          .get();

      List<Map<String, dynamic>> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data() as Map<String, dynamic>);
      });

      setState(() {
        Applications = tempApplications;
      });
    } catch (error) {
      print("Failed to fetch applications: $error");
      throw error;
    }
  }

  Future<void> _fetchEntriesAsync() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('companyEmail', isEqualTo: widget.email)
          .get();

      List<Map<String, dynamic>> tempEntries = [];
      querySnapshot.docs.forEach((doc) {
        tempEntries.add(doc.data() as Map<String, dynamic>);
      });

      setState(() {
        Entries = tempEntries;
      });
      print("Fetched ${Entries.length} entries");
    } catch (error) {
      print("Failed to fetch entries: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$companyName",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: isLoading ? null : reloadData,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 28,
                  ),
            tooltip: 'Refresh Data',
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
                Icons.people,
                color: Colors.black,
              ),
              icon: Icon(Icons.people_outline),
              label: 'All Entries',
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
            Entries.isEmpty
                ? Center(
                    child: Text(
                      "Loading Entries...",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        itemCount: Entries.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 10.0),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 10,
                                      child: Text(
                                        Entries[index]['studentName']
                                                ?.toString() ??
                                            '',
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Positioned(
                                      top: 30,
                                      left: 10,
                                      child: Text(
                                        Entries[index]['companyProfile']
                                                ?.toString() ??
                                            '',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 20,
                                      child: Text(
                                        Entries[index]['studentEmail']
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
                                      top: 40,
                                      right: 20,
                                      child: Container(
                                        width: width * 0.3,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.black,
                                            value: Entries[index]['status']
                                                    ?.toString() ??
                                                'Pending',
                                            icon: Icon(Icons.arrow_drop_down,
                                                color: Colors.white),
                                            isExpanded: true,
                                            items: status.map((String status) {
                                              return DropdownMenuItem<String>(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  Entries[index]["status"] =
                                                      newValue;
                                                });
                                                // Update status in Firestore
                                                updateApplicationStatus(
                                                    index, newValue);
                                              }
                                            },
                                          ),
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
                    ],
                  )
          ],
        ),
        Stack(
          children: [
            addItem
                ? Center(
                    child: Container(
                      height: height * 0.5,
                      width: width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white12,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  controller: jobProfileController,
                                  decoration: InputDecoration(
                                      labelText: "Job Profile",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: "Position Outline",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.yellow, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.work,
                                        color: Colors.white,
                                      ),
                                      suffixIcon: jobProfileController
                                              .text.isEmpty
                                          ? null
                                          : IconButton(
                                              onPressed: () {
                                                jobProfileController.clear();
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              )),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  controller: jobLocationController,
                                  decoration: InputDecoration(
                                      labelText: "Work Location",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: "Workplace",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.yellow, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.white,
                                      ),
                                      suffixIcon: jobLocationController
                                              .text.isEmpty
                                          ? null
                                          : IconButton(
                                              onPressed: () {
                                                jobLocationController.clear();
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              )),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  controller: jobSalaryController,
                                  decoration: InputDecoration(
                                      labelText: "Job Salary",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: "Pay Scale",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.yellow, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.currency_rupee,
                                        color: Colors.white,
                                      ),
                                      suffixIcon:
                                          jobSalaryController.text.isEmpty
                                              ? null
                                              : IconButton(
                                                  onPressed: () {
                                                    jobSalaryController.clear();
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  )),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  controller: jobDescriptionController,
                                  decoration: InputDecoration(
                                      labelText: "Job Description",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: "Role Overview",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.yellow, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.description_rounded,
                                        color: Colors.white,
                                      ),
                                      suffixIcon:
                                          jobDescriptionController.text.isEmpty
                                              ? null
                                              : IconButton(
                                                  onPressed: () {
                                                    jobDescriptionController
                                                        .clear();
                                                  },
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  )),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 18.0, left: 18.0, right: 18.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (jobProfileController.text.isEmpty ||
                                        jobLocationController.text.isEmpty ||
                                        jobDescriptionController.text.isEmpty ||
                                        jobSalaryController.text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "No field can be Empty",
                                          backgroundColor: Colors.red,
                                          timeInSecForIosWeb: 2);
                                      return;
                                    }
                                    Map<String, dynamic> newJob = {
                                      "profile":
                                          jobProfileController.text.toString(),
                                      "location":
                                          jobLocationController.text.toString(),
                                      "description": jobDescriptionController
                                          .text
                                          .toString(),
                                      "salary":
                                          jobSalaryController.text.toString(),
                                    };
                                    Applications.add(newJob);
                                    sendDataToFirebase();
                                    setState(() {
                                      addItem = !addItem;
                                      jobProfileController.clear();
                                      jobLocationController.clear();
                                      jobDescriptionController.clear();
                                      jobSalaryController.clear();
                                    });
                                  },
                                  child: Container(
                                    width: width,
                                    height: height * 0.07,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.yellow,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add Job Application",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      addItem = !addItem;
                                      jobProfileController.clear();
                                      jobLocationController.clear();
                                      jobDescriptionController.clear();
                                      jobSalaryController.clear();
                                    });
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Applications.isEmpty
                    ? Center(
                        child: Text(
                          "My Applications",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                      )
                    : Stack(
                        children: [
                          GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 1.2),
                            itemCount: Applications.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          Applications[index]['profile']
                                                  ?.toString() ??
                                              '',
                                          style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          Applications[index]['location']
                                                  ?.toString() ??
                                              '',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "₹${Applications[index]['salary']?.toString() ?? ''}",
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
                              );
                            },
                          ),
                        ],
                      ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      addItem = !addItem;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.yellow,
                    ),
                    height: 50,
                    width: 100,
                    child: Center(
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ][currentPageIndex],
    );
  }

  void fetchCompanyName() {
    FirebaseFirestore.instance
        .collection('companies')
        .where('email', isEqualTo: widget.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          companyName = querySnapshot.docs.first.get('name') as String;
        });
      }
    }).catchError((error) {
      print("Failed to fetch company name: $error");
    });
  }

  void fetchAppplications() {
    FirebaseFirestore.instance
        .collection('jobs')
        .where('email', isEqualTo: widget.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> tempApplications = [];
      querySnapshot.docs.forEach((doc) {
        tempApplications.add(doc.data() as Map<String, dynamic>);
      });
      setState(() {
        Applications = tempApplications;
      });
    }).catchError((error) {
      print("Failed to fetch data: $error");
    });
  }

  void updateApplicationStatus(int index, String status) {
    String studentEmail = Entries[index]['studentEmail']?.toString() ?? '';
    String companyEmail = Entries[index]['companyEmail']?.toString() ?? '';
    String companyProfile = Entries[index]['companyProfile']?.toString() ?? '';

    if (studentEmail.isEmpty || companyEmail.isEmpty) {
      print("Error: Missing email information");
      return;
    }

    FirebaseFirestore.instance
        .collection('applications')
        .where('studentEmail', isEqualTo: studentEmail)
        .where('companyEmail', isEqualTo: companyEmail)
        .where('companyProfile', isEqualTo: companyProfile)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({
          'status': status,
        }).then((_) {
          print("Status updated successfully to: $status");
          Fluttertoast.showToast(
              msg: "Status updated to $status",
              backgroundColor: Colors.green,
              timeInSecForIosWeb: 2);
        }).catchError((error) {
          print("Error updating status: $error");
          Fluttertoast.showToast(
              msg: "Failed to update status",
              backgroundColor: Colors.red,
              timeInSecForIosWeb: 2);
        });
      }
    }).catchError((error) {
      print("Error finding document: $error");
    });
  }

  void fetchEntries() {
    FirebaseFirestore.instance
        .collection('applications')
        .where('companyEmail', isEqualTo: widget.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> tempEntries = [];
      querySnapshot.docs.forEach((doc) {
        tempEntries.add(doc.data() as Map<String, dynamic>);
      });
      setState(() {
        Entries = tempEntries;
      });
      print("Fetched ${Entries.length} entries");
    }).catchError((error) {
      print("Failed to fetch entries: $error");
    });
  }

  void sendDataToFirebase() {
    FirebaseFirestore.instance.collection('jobs').add({
      'email': widget.email,
      'profile': jobProfileController.text,
      'location': jobLocationController.text,
      'description': jobDescriptionController.text,
      'salary': jobSalaryController.text,
      'companyName': companyName ?? 'Unknown Company',
    }).then((value) {
      print("Data added successfully");
      Fluttertoast.showToast(
          msg: "Job posted successfully!",
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 2);
    }).catchError((error) {
      print("Failed to add data: $error");
      Fluttertoast.showToast(
          msg: "Failed to post job",
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 2);
    });
  }
}
