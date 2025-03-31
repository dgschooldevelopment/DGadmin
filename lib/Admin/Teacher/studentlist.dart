
import 'package:dgadmin/Admin/Teacher/studentwiseattendance.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentListForAttendance extends StatefulWidget {
  final String standard;
  final String division;
  final String collegeCode;
    final VoidCallback onBack; // Accept the callback function

  const StudentListForAttendance({super.key, required this.standard, required this.division, required this.collegeCode, required this.onBack});

  @override
  State<StudentListForAttendance> createState() => _StudentListForAttendanceState();
}

// class _StudentListForAttendanceState extends State<StudentListForAttendance> {
//   List<Student> students = [];
//   List<Student> filteredStudents = [];
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
  

//   @override
//   void initState() {
//     super.initState();
//     fetchStudents();
//     _searchController.addListener(_filterStudents);
//   }

//   Future<void> fetchStudents() async {
//     final url = 'http://195.35.45.44:3001/students?college_code=${widget.collegeCode}&stand=${widget.standard}&division=${widget.division}';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         print('Data fetched from API: $data'); // Log the fetched data
//         setState(() {
//           students = data.map((json) => Student.fromJson(json)).toList();
//           filteredStudents = students;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load students');
//       }
//     } catch (e) {
//       print('Error fetching students: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _filterStudents() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       filteredStudents = students.where((student) => student.name.toLowerCase().contains(query)).toList();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double padding = screenWidth * 0.2;
//     return Scaffold(
//       body: Padding(
//       padding: EdgeInsets.symmetric(horizontal: padding),
//         child: Column(
//           children: [
//             SizedBox(height: 60),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.arrow_back),
//                     onPressed: widget.onBack, 
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20.0),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           labelText: 'Search By Name',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.search),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 '${filteredStudents.length} Students in class ${widget.standard}${widget.division}',
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//             ),
//             Container(
//               color: Colors.grey[200],
//               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   Text('Roll Numbers', style: TextStyle(fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
            // Expanded(
            //   child: isLoading
            //       ? Center(child: CircularProgressIndicator())
            //       : ListView.builder(
            //           itemCount: filteredStudents.length,
            //           itemBuilder: (context, index) {
            //             final student = filteredStudents[index];
            //             return GestureDetector(
            //               onTap: () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
                                
            //                     builder: (context) => StudentWiseAttendance(
            //                       studId: student.studentId,
            //                       collegecode: widget.collegeCode,
            //                     ),
            //                   ),
            //                 );
            //               },
            //               child: Container(
            //                 color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
            //                 child: ListTile(
            //                   leading: CircleAvatar(
            //                     backgroundImage: (student.profileImg.isNotEmpty)
            //                         ? NetworkImage(student.profileImg)
            //                         : AssetImage('assets/default_avatar.png') as ImageProvider,
            //                   ),
            //                   title: Text(student.name),
            //                   trailing: Padding(
            //                     padding: const EdgeInsets.only(right: 40.0),
            //                     child: Text(student.rollNumber),
            //                   ),
            //                 ),
            //               ),
            //             );
            //           },
            //         ),
            // ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class _StudentListForAttendanceState extends State<StudentListForAttendance> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Student? selectedStudent; // Track selected student

  @override
  void initState() {
    super.initState();
    fetchStudents();
    _searchController.addListener(_filterStudents);
  }

  void _selectStudent(Student student) {
    setState(() {
      selectedStudent = student; // Set selected student
    });
  }

  void _goBackToList() {
    setState(() {
      selectedStudent = null; // Reset selection
    });
  }




  Future<void> fetchStudents() async {
    final url = '$classlist?college_code=${widget.collegeCode}&stand=${widget.standard}&division=${widget.division}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Data fetched from API: $data'); // Log the fetched data
        setState(() {
          students = data.map((json) => Student.fromJson(json)).toList();
          filteredStudents = students;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) => student.name.toLowerCase().contains(query)).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (selectedStudent != null) {
      // Show StudentWiseAttendance when a student is selected
      return StudentWiseAttendance(
        studId: selectedStudent!.studentId,
        collegecode: widget.collegeCode, onBack: _goBackToList,
      );
    }

    // Otherwise, show the student list
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
        child: Column(
          children: [
            SizedBox(height: 60),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search By Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${filteredStudents.length} Students in class ${widget.standard}${widget.division}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),

   Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return GestureDetector(
                       
                                                  onTap: () => _selectStudent(student), // Select student on tap

                          
                          child: Container(
                            color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (student.profileImg.isNotEmpty)
                                    ? NetworkImage(student.profileImg)
                                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                              ),
                              title: Text(student.name),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 40.0),
                                child: Text(student.rollNumber),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Expanded(
            //   child: isLoading
            //       ? Center(child: CircularProgressIndicator())
            //       : ListView.builder(
            //           itemCount: filteredStudents.length,
            //           itemBuilder: (context, index) {
            //             final student = filteredStudents[index];
            //             return GestureDetector(
            //               onTap: () => _selectStudent(student), // Select student on tap
            //               child: ListTile(
            //                 leading: CircleAvatar(
            //                   backgroundImage: (student.profileImg.isNotEmpty)
            //                       ? NetworkImage(student.profileImg)
            //                       : AssetImage('assets/default_avatar.png') as ImageProvider,
            //                 ),
            //                 title: Text(student.name),
            //                 trailing: Padding(
            //                   padding: const EdgeInsets.only(right: 40.0),
            //                   child: Text(student.rollNumber),
            //                 ),
            //               ),
            //             );
            //           },
            //         ),
            // ),
         
          ],
        ),
      ),
    );
  }
}


class Student {
  final String studentId;
  final String rollNumber;
  final String std;
  final String name;
  final String division;
  final String profileImg;

  Student({
    required this.studentId,
    required this.rollNumber,
    required this.std,
    required this.name,
    required this.division,
    required this.profileImg,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentid'],
      rollNumber: json['roll_no'],
      std: json['std'],
      name: json['Name'],
      division: json['division'],
      profileImg: json['profile_img'] ?? '',
    );
  }
}
