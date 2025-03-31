import 'dart:convert';

import 'package:dgadmin/Admin/Teacher/addteacher.dart';
import 'package:dgadmin/Admin/Teacher/dashboard.dart';
import 'package:dgadmin/Admin/Teacher/updateteacher.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherListView extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  TeacherListView(
      {required this.collegecode,
      required this.collegename,
      required this.collegeimage});

  @override
  _TeacherListViewState createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  List<TeacherItem> teachers = [];
  List<TeacherItem> filteredTeachers = [];
  List<TeacherItem> deletedTeachers = []; // List for deleted teachers
  bool isLoading = true;
  bool showDeletedTeachers = false; // Toggle state
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    searchController.addListener(() {
      filterTeachers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTeachers() async {
    final response = await http
        .get(Uri.parse('$teacherlist?college_code=${widget.collegecode}'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        teachers = data.map((item) => TeacherItem.fromJson(item)).toList();
        filteredTeachers = teachers;
        isLoading = false;
      });
    }
  }

  Future<void> fetchDeletedTeachers() async {
    final response = await http.get(Uri.parse(
        '$deletedteacher?college_code=${widget.collegecode}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        deletedTeachers =
            data.map((item) => TeacherItem.fromJson(item)).toList();
        filteredTeachers = teachers;
        isLoading = false;
      });
    }
  }

  void filterTeachers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (showDeletedTeachers) {
        filteredTeachers = deletedTeachers.where((teacher) {
          return teacher.tname.toLowerCase().contains(query) ||
              teacher.teacherCode.toLowerCase().contains(query);
        }).toList();
      } else {
        filteredTeachers = teachers.where((teacher) {
          return teacher.tname.toLowerCase().contains(query) ||
              teacher.teacherCode.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTeacher(
                        collegecode: widget.collegecode,
                        collegename: widget.collegename,
                        collegeimage: widget.collegeimage,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)
                )
                ),
                child: Text('Admit Teacher',style: TextStyle(fontSize: 16,color: Colors.black),),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDeletedTeachers = !showDeletedTeachers;
                    if (showDeletedTeachers) {
                      fetchDeletedTeachers();
                    } else {
                      fetchTeachers();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)
                )
                ),
                child: Text(showDeletedTeachers
                    ? 'Show Active Teachers'
                    : 'Deleted Teachers',style: TextStyle(color: Colors.black,fontSize: 16),),
              ),
              Container(
                width: screenWidth * 0.22,
                height: 42,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search teacher',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          showDeletedTeachers
              ? buildTeacherTable(deletedTeachers, false)
              : buildTeacherTable(filteredTeachers, true),
        ],
      ),
    );
  }

  Widget buildTeacherTable(List<TeacherItem> teacherList, bool isActive) {
    return Table(
      // border: TableBorder.all(color: Colors.grey),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(2),
      },
      children: [
        // Table Header Row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.circular(7)),
          children: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Profile',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),)
                    )),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Teacher Name',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0), child: Text('ID',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Password',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Class Teacher',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),))),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(isActive ? 'Edit' : 'Restore',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),))),
          ],
        ),

        // Teacher Data Rows
        for (var teacher in teacherList)
          TableRow(
            children: [
              GestureDetector(
                onTap: () {
                  if (isActive) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dashboard(
                          collegecode: widget.collegecode,
                          collegename: widget.collegename,
                          collegeimage: widget.collegeimage,
                          teachercode: teacher.teacherCode, teachername: teacher.tname, mobileno: teacher.mobileno, teacherprofile: teacher.teacherProfile,
                          
                        ),
                      ),
                    );
                  }
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(teacher.teacherProfile),
                    ),
                  ),
                ),
              ),
              for (var text in [
                teacher.tname,
                teacher.teacherCode,
                teacher.tpassword,
                '${teacher.standard}${teacher.division}'
              ])
                GestureDetector(
                  onTap: () {
                    if (isActive) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(
                            collegecode: widget.collegecode,
                            collegename: widget.collegename,
                            collegeimage: widget.collegeimage,
                            teachercode: teacher.teacherCode,
                            teachername: teacher.tname, mobileno: teacher.mobileno, teacherprofile: teacher.teacherProfile,
                          ),
                        ),
                      );
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text),
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isActive
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateTeacher(
                                      collegecode: widget.collegecode,
                                      collegename: widget.collegename,
                                      collegeimage: widget.collegeimage,
                                      teachercode: teacher.teacherCode,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 227, 255, 230),
                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(7),
                                )
                              ),
                              child: Text("Update",style: TextStyle(color: Colors.black,)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, teacher.teacherCode);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 254, 230, 229),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                 
                                )
                              ),
                              child: Text("Delete",style: TextStyle(color: Colors.black,)),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _showDRestoreConfirmationDialog(
                                context, teacher.teacherCode);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                            )
                          ),
                          child: Text("Restore",style: TextStyle(color: Colors.black,)),
                        ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> restoreTeacher(String teacherCode) async {
    final String url =
        "$recoverteacher?college_code=${widget.collegecode}";
    final Map<String, dynamic> requestBody = {"teacher_code": teacherCode};

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Response Data: $responseData");

        if (responseData['success'] == true) {
          print("recover successfully");
          setState(() {
            deletedTeachers
                .removeWhere((teacher) => teacher.teacherCode == teacherCode);
            // Ensure API returns teacher data, otherwise this line will cause errors
            // If the API does not return teacher details, you may need to refetch them
          });
        }
      } else {
        print("Failed to restore teacher: ${response.statusCode}");
      }
    } catch (e) {
      print("Error is  : $e");
    }
  }

  void _showDRestoreConfirmationDialog(
      BuildContext context, String teacherCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Restore"),
          content: Text("Are you sure you want to restore this teacher?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restoreTeacher(teacherCode);
              },
              child: Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String teacherCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this teacher?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteTeacher(teacherCode);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTeacher(String teacherCode) async {
    final String url =
        "$deleteteacher?college_code=${widget.collegecode}";
    final Map<String, dynamic> requestBody = {
      "college_code": widget.collegecode,
      "teacher_code": [teacherCode] // Pass dynamic teacher code
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData["message"]);
        // Remove the teacher from the list after deletion
        setState(() {
          teachers.removeWhere((teacher) => teacher.teacherCode == teacherCode);
          filteredTeachers
              .removeWhere((teacher) => teacher.teacherCode == teacherCode);
        });
      } else {
        print("Failed to delete teacher: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }



}

class TeacherItem {
  final int teacherId;
  final String teacherCode;
  final String tname;
  final String tpassword;
  final String mobileno;
  final String teacherEmail;
  final String teacherProfile;
  final String standard;
  final String division;

  TeacherItem({
    required this.teacherId,
    required this.teacherCode,
    required this.tname,
    required this.tpassword,
    required this.mobileno,
    required this.teacherEmail,
    required this.teacherProfile,
    required this.standard,
    required this.division,
  });

  factory TeacherItem.fromJson(Map<String, dynamic> json) {
    return TeacherItem(
      teacherId: json['teacher_id'] ?? '',
      teacherCode: json['teacher_code'] ?? '',
      tname: json['tname'] ?? '',
      tpassword: json['tpassword'] ?? '',
      mobileno: json['mobileno'] ?? '',
      teacherEmail: json['teacher_email'] ?? '',
      teacherProfile: json['teacher_profile'] ?? '',
      standard: json['standard'] ?? '',
      division: json['division'] ?? '',
    );
  }
}

