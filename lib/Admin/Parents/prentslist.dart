import 'package:dgadmin/Admin/Parents/addparent.dart';
import 'package:dgadmin/Admin/Parents/updateparent.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class parentlist extends StatefulWidget {
    final String collegecode;
    final String collegename;
     final String collegeimage;
  const parentlist({super.key, required this.collegecode, required this.collegename, required this.collegeimage});
  

  @override
  State<parentlist> createState() => _parentlistState();
}

class _parentlistState extends State<parentlist> {
  late String apiUrlClasses;
  late String apiUrlStudents;

  List<String> standards = [];
  List<String> divisions = [];
  String? selectedStandard;
  String? selectedDivision;

  Map<String, List<String>> divisionMap = {};
  List<ParentsItem> students = [];
  List<ParentsItem> filteredStudents = []; // For filtered results

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize URLs with dynamic college code
    apiUrlClasses = "$allclasses?college_code=${widget.collegecode}";
    apiUrlStudents = "$parentslist?college_code=${widget.collegecode}";

    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(Uri.parse(apiUrlClasses));
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
        "$apiUrlStudents&standard=$selectedStandard&division=$selectedDivision";
    print("API URL: $apiUrl");
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");

        // Ensure the response is a JSON array
        final decodedData = json.decode(response.body);

        if (decodedData is List) {
          final data = decodedData as List<dynamic>;
          setState(() {
            students = data
                .map((student) => ParentsItem(
                      parentId: student['parent_id'],
                      password: student['password'],
                      name: student['parentname'],
                      profileImage: student['profilephoto'],
                    ))
                .toList();
            filteredStudents = students; // Initialize filtered list
          });
        } else {
          print("Unexpected response format: $decodedData");
          throw Exception("Expected a JSON array but received something else.");
        }
      } else {
        throw Exception('Failed to fetch parents. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}


  // Future<void> fetchStudents() async {
  //   if (selectedStandard != null && selectedDivision != null) {
  //     String apiUrl =
  //         "$apiUrlStudents&standard=$selectedStandard&division=$selectedDivision";
  //         print("apiUrl: " + apiUrl);
          
  //     try {
  //       final response = await http.get(Uri.parse(apiUrl));
  //       if (response.statusCode == 200) {
  //         print("response statuscode:   ${response.statusCode}");
  //                   print("response body:   ${response.statusCode}");

  //         final data = json.decode(response.body) as List<dynamic>;
  //         setState(() {
  //           students = data
  //               .map((student) => ParentsItem(
  //                     parentId: student['parent_id'],
  //                     password: student['password'],
  //                     name: student['parentname'],
  //                     // division: student['division'],
  //                     profileImage: student['profilephoto'],
  //                   ))
  //               .toList();

  //           filteredStudents = students; // Initialize filtered list
  //         });
  //       } else {
  //         throw Exception('Failed to fetch Parents');
  //       }
  //     } catch (e) {
  //       print('Error: $e');
  //     }
  //   }
  // }


  void searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStudents = students; // Show all students if query is empty
      } else {
        filteredStudents = students
            .where((student) =>
                student.name.toLowerCase().contains(query.toLowerCase()) ||
                student.parentId.toLowerCase().contains(query.toLowerCase()))
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
                      builder: (context) => AddParents(
                        collegecode: widget.collegecode, collegename: widget.collegename, collegeimage: widget.collegeimage,
                      ),
                    ),
                  );
                  // Navigation logic here
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                   
                  )
                ),
                child: Text('Admit Parent',style: TextStyle(fontSize: 16,color: Colors.black),),
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
                    Text('Select Class: '),
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
                              selectedDivision = null;
                              divisions = divisionMap[selectedStandard!]!;
                              if (divisions.isNotEmpty) {
                                selectedDivision = divisions.first;
                              }
                              fetchStudents();
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
                SizedBox(width: 20,),
                Row(
                  children: [
                    Text('Division: '),
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
                              fetchStudents();
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
          Table(
            // border: TableBorder.all(color: Colors.grey),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                 
                color: const Color.fromARGB(255, 208, 207, 207,),
                borderRadius: BorderRadius.circular(7)
                
                ),
                children: [
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Profile',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Parents Name',style: TextStyle(fontWeight: FontWeight.bold),))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('ID',style: TextStyle(fontWeight: FontWeight.bold),))),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Password',style: TextStyle(fontWeight: FontWeight.bold),))),
                           Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Action',style: TextStyle(fontWeight: FontWeight.bold),))),
                ],
              ),
              for (var student in filteredStudents) // Use filteredStudents
                TableRow(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:CircleAvatar(
  radius: 18,
  backgroundImage: NetworkImage(student.profileImage),
),
 
                        
                        
                        // CircleAvatar(
                        //   radius: 18,
                        //   backgroundImage:
                        //       MemoryImage(base64Decode(student.profileImage)),
                        // ),
                      ),
                    ),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(student.name))),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(student.parentId))),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(student.password))),
                            Center(
                              child: Padding(padding: const EdgeInsets.all(8.0),
                              child:   ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateParent(
                      // builder: (context) => StudentDash(
                       collegecode: widget.collegecode,
                       collegename: widget.collegename,
                     collegeimage: widget.collegeimage, parentId: student.parentId
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
                            )), 
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ParentsItem {
  final String parentId;
  final String password;
  final String name;
  // final String division;
  final String profileImage;

  ParentsItem({
    required this.parentId,
    required this.password,
    required this.name,
    // required this.division,
    required this.profileImage,
  });
}
