import 'dart:convert';
import 'package:dgadmin/Admin/Student/addstudent.dart';
import 'package:dgadmin/Admin/Student/updatestudent.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentList extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  const StudentList(
      {super.key,
      required this.collegecode,
      required this.collegename,
      required this.collegeimage});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late String apiUrlClasses;
  late String apiUrlStudents;

  List<String> standards = [];
  List<String> divisions = [];
  String? selectedStandard;
  String? selectedDivision;
  bool showDeletedStudents = false; // Toggle state
  List<DeletedStudent> deletedStudents = [];

  Map<String, List<String>> divisionMap = {};
  List<StudentItem> students = [];
  List<StudentItem> filteredStudents = []; // For filtered results

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize URLs with dynamic college code
    apiUrlClasses = "$allclasses?college_code=${widget.collegecode}";
    apiUrlStudents = "$classlist?college_code=${widget.collegecode}";
    print("Akshada");

    fetchClasses();
  }

  Future<void> fetchClasses() async {
    print("Akshada1");
    try {
      final response = await http.get(Uri.parse(apiUrlClasses));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        Set<String> uniqueStandards = {};

        for (var item in data) {
          String standard = item['standard'];
          String division = item['division'];

          uniqueStandards.add(standard);
          if (divisionMap.containsKey(standard)) {
            divisionMap[standard]?.add(division);
          } else {
            divisionMap[standard] = [division];
          }
        }

        setState(() {
          standards = uniqueStandards.toList();
          if (standards.isNotEmpty) {
            selectedStandard = standards.first;
            divisions = divisionMap[selectedStandard!]!;
            selectedDivision = divisions.first;
            fetchStudents();
          }
        });
      } else {
        throw Exception('Failed to fetch classes');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchStudents() async {
    if (selectedStandard != null && selectedDivision != null) {
      String apiUrl =
          "$apiUrlStudents&stand=$selectedStandard&division=$selectedDivision";
      print(apiUrl);
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          print(response.body);
          final data = json.decode(response.body) as List<dynamic>;
          setState(() {
            students = data
                .map((student) => StudentItem(
                      studentId: student['studentid'],
                      rollNo: student['roll_no'],
                      name: student['Name'],
                      division: student['division'],
                      profileImage: student['profile_img'] ?? '',
                      Password: student['password'],
                    ))
                .toList();

            filteredStudents = students; // Initialize filtered list
          });
        } else {
          throw Exception('Failed to fetch students');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> fetchDeletedStudents() async {
    final url = Uri.parse(
        '$allDeletedStudent?college_code=${widget.collegecode}&std=$selectedStandard&division=$selectedDivision');

    try {
      final response = await http.get(url);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> data = responseData['data'];
          setState(() {
            deletedStudents = data
                .map((student) => DeletedStudent.fromJson(student))
                .toList();
          });
        } else {
          throw Exception("API response unsuccessful");
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = students; // Show all students if query is empty
      } else {
        filteredStudents = students
            .where((student) =>
                student.name.toLowerCase().contains(query.toLowerCase()) ||
                student.studentId.toLowerCase().contains(query.toLowerCase()) ||
                student.rollNo.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
                      builder: (context) => AddStudent(
                        collegecode: widget.collegecode,
                        collegename: widget.collegename,
                        collegeimage: widget.collegeimage,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  )
                ),
                child: Text('Admit Student',style: TextStyle(color: Colors.black),),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDeletedStudents = !showDeletedStudents;
                    if (showDeletedStudents) {
                      fetchDeletedStudents();
                    } else {
                      fetchStudents();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  )
                ),
                child: Text(showDeletedStudents
                    ? 'Show Active Students'
                    : 'Deleted Students',style: TextStyle(color: Colors.black),),
              ),
              Container(
                width: screenWidth * 0.2, // Adjusted width for the search bar
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: searchStudents, // Call search function on input
                  decoration: InputDecoration(
                    hintText: 'Search student',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(color: Colors.black),
          SizedBox(height: 8),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text('Select Class: ',style: TextStyle(fontSize: 16),),
                    SizedBox(width: 8),
                    Container(
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: selectedStandard,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStandard = newValue;

                              // Ensure we have valid divisions before setting selectedDivision
                              if (selectedStandard != null &&
                                  divisionMap.containsKey(selectedStandard)) {
                                divisions =
                                    divisionMap[selectedStandard!] ?? [];
                                selectedDivision = divisions.isNotEmpty
                                    ? divisions.first
                                    : null;
                              } else {
                                divisions = [];
                                selectedDivision = null;
                              }

                              // Fetch data based on the toggle state
                              if (selectedDivision != null) {
                                if (showDeletedStudents) {
                                  fetchDeletedStudents();
                                } else {
                                  fetchStudents();
                                }
                              }
                            });
                          },
                          items: standards
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          underline: SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Row(
                  children: [
                    Text('Division: ',style: TextStyle(fontSize: 16),),
                    SizedBox(width: 8),
                    Container(
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: selectedDivision,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDivision = newValue;

                              // Fetch data based on the toggle state
                              if (selectedDivision != null) {
                                if (showDeletedStudents) {
                                  fetchDeletedStudents();
                                } else {
                                  fetchStudents();
                                }
                              }
                            });
                          },
                          items: divisions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          underline: SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          showDeletedStudents
              ? buildDeletedStudentsTable()
              : buildActiveStudentsTable(),
        ],
      ),
    );
  }

  Widget buildActiveStudentsTable() {
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
        TableRow(
          decoration: BoxDecoration(color: const Color.fromARGB(255, 220, 218, 218),borderRadius: BorderRadius.circular(7)),
          children: [
            tableCell("Profile",),
            tableCell("Student Name"),
            tableCell("ID"),
            tableCell("Roll No"),
            tableCell("Password"),
            tableCell("Edit"),
          ],
        ),
        for (var student in filteredStudents)
          TableRow(
            children: [
              studentAvatar(student.profileImage),
              tableCell(student.name),
              tableCell(student.studentId),
              tableCell(student.rollNo),
              tableCell(student.Password),
              actionButtons(student.studentId),
            ],
          ),
      ],
    );
  }

  Widget buildDeletedStudentsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            tableCell("Profile"),
            tableCell("Name"),
            tableCell("ID"),
            tableCell("Email"),
            tableCell("Password"),
            tableCell("Restore"),
          ],
        ),
        for (var student in deletedStudents)
          TableRow(
            children: [
              studentAvatar(student.profileImg ?? ''),
              tableCell(student.name),
              tableCell(student.studentCode),
              tableCell(student.email),
              tableCell(student.password),
              restoreButton(student.studentCode),
            ],
          ),
      ],
    );
  }

  Widget tableCell(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }

  Widget studentAvatar(String imageUrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget actionButtons(String studentId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Updatestudent(
                      // builder: (context) => StudentDash(
                      collegecode: widget.collegecode,
                      collegename: widget.collegename,
                      collegeimage: widget.collegeimage, studentid:studentId
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
               
                )
              ),
              child: Text("Update",style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context, studentId);
              },
              child: Text("Delete",style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }

  Widget restoreButton(String studentId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            _showDRestoreConfirmationDialog(context, studentId);
          },
          // restoreStudent(studentId);
          // },
          child: Text("Restore"),
        ),
      ),
    );
  }

  void _showDRestoreConfirmationDialog(
      BuildContext context, String studentcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Restore"),
          content: Text("Are you sure you want to restore this student?"),
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
                restoreTeacher(studentcode);
              },
              child: Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  Future<void> restoreTeacher(String studentcode) async {
    final String url =
        "$recoverStudent?college_code=${widget.collegecode}";
    final Map<String, dynamic> requestBody = {"studentid": studentcode};

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
            deletedStudents
                .removeWhere((student) => student.studentCode == studentcode);
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

  void _showDeleteConfirmationDialog(BuildContext context, String studentcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this student?"),
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
                deletestudent(studentcode);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletestudent(String studentcode) async {
    final String url =
        "$deleteStudent?college_code=${widget.collegecode}";
    final Map<String, dynamic> requestBody = {
      // "college_code": widget.collegecode,
      "studentid": [studentcode] // Pass dynamic teacher code
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
          students.removeWhere((students) => students.studentId == studentcode);
          filteredStudents
              .removeWhere((students) => students.studentId == studentcode);
        });
      } else {
        print("Failed to delete teacher: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}

class StudentItem {
  final String studentId;
  final String rollNo;
  final String name;
  final String division;
  final String profileImage;
  final String Password;

  StudentItem({
    required this.studentId,
    required this.rollNo,
    required this.name,
    required this.division,
    required this.profileImage,
    required this.Password,
  });
}

class DeletedStudent {
  final int studentId;
  final String studentCode;
  final String name;
  final String email;
  final String mobile;
  final String rollNo;
  final String std;
  final String division;
  final String? profileImg;
  final String? deletedAt;
  final String password;

  DeletedStudent({
    required this.studentId,
    required this.studentCode,
    required this.name,
    required this.email,
    required this.mobile,
    required this.rollNo,
    required this.std,
    required this.division,
    this.profileImg,
    this.deletedAt,
    required this.password,
    // Ensure API returns teacher data, otherwise this line will cause errors
  });

  factory DeletedStudent.fromJson(Map<String, dynamic> json) {
    return DeletedStudent(
      studentId: json['student_id'],
      studentCode: json['studentid'],
      name: json['Name'],
      email: json['email'],
      mobile: json['mobile'],
      rollNo: json['roll_no'],
      std: json['std'],
      division: json['division'],
      profileImg: json['profile_img'],
      deletedAt: json['deleted_at'],
      password: json['password'],
    );
  }
}
