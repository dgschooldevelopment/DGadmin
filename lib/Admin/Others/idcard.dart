import 'package:dgadmin/Admin/Others/cardid.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_school/baseurl.dart';

class StudentListForIDCard extends StatefulWidget {
  final String collegecode;
  final VoidCallback onBack; // Callback for back button

  const StudentListForIDCard(
      {super.key, required this.collegecode, required this.onBack});

  @override
  State<StudentListForIDCard> createState() => _StudentListForIDCardState();
}

class _StudentListForIDCardState extends State<StudentListForIDCard> {
  String? selectedClass;
  String? selectedDivision;

  List<String> classes = [];
  Map<String, List<String>> classDivisionsMap = {};

  List<Map<String, String>> students = [];

  @override
  void initState() {
    super.initState();
    fetchClassesAndDivisions();
  }

  Future<void> fetchClassesAndDivisions() async {
    final String url = '$fetchclasses?college_code=${widget.collegecode}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        Set<String> classSet = {};
        Map<String, List<String>> tempClassDivisionsMap = {};

        for (var item in data) {
          String className = ' ${item['standard']}';
          String divisionName = ' ${item['division']}';

          classSet.add(className);
          if (!tempClassDivisionsMap.containsKey(className)) {
            tempClassDivisionsMap[className] = [];
          }
          tempClassDivisionsMap[className]!.add(divisionName);
        }

        // Save to Shared Preferences
        saveClassesAndDivisions(classSet.toList(), tempClassDivisionsMap);

        setState(() {
          classes = classSet.toList();
          classDivisionsMap = tempClassDivisionsMap;
          initializeSelection();
        });
      } else {
        loadClassesAndDivisionsFromPrefs(); // Load saved data on failure
      }
    } catch (e) {
      print(e);
      loadClassesAndDivisionsFromPrefs(); // Load saved data on error
    }
  }

  Future<void> saveClassesAndDivisions(
      List<String> classList, Map<String, List<String>> divisionsMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('classes', classList);
    for (String className in divisionsMap.keys) {
      await prefs.setStringList(className, divisionsMap[className]!);
    }
  }

  Future<void> loadClassesAndDivisionsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedClasses = prefs.getStringList('classes');
    Map<String, List<String>> tempClassDivisionsMap = {};

    if (savedClasses != null) {
      for (String className in savedClasses) {
        List<String>? savedDivisions = prefs.getStringList(className);
        if (savedDivisions != null) {
          tempClassDivisionsMap[className] = savedDivisions;
        }
      }

      setState(() {
        classes = savedClasses;
        classDivisionsMap = tempClassDivisionsMap;
        initializeSelection();
      });
    }
  }

  void initializeSelection() {
    // Set initial values for selectedClass and selectedDivision
    if (classes.isNotEmpty) {
      selectedClass = classes.first;
      if (classDivisionsMap[selectedClass!]!.isNotEmpty) {
        selectedDivision = classDivisionsMap[selectedClass!]!.first;
        fetchStudents(
            selectedClass!.split(' ')[1], selectedDivision!.split(' ')[1]);
      }
    }
  }

  Future<void> fetchStudents(String standard, String division) async {
    final String url =
        '$classlist?college_code=${widget.collegecode}&stand=$standard&division=$division';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<Map<String, String>> tempStudents =
            data.map<Map<String, String>>((item) {
          return {
            'name': item['Name'] ?? 'No Name',
            'rollNumber': item['roll_no'] ?? 'No Roll Number',
            'profile_img': item['profile_img'] ?? '',
            'id': item['studentid'] ?? '',
            'standard': item['standard'] ?? '0',
            'division': item['division'] ?? '0',
            'stud_dob': item['stud_dob'] ?? '0',
            'bloodGroup': item['bloodGroup'] ?? '0',
            'mobile':item['mobile'] ?? '0',
            'email':item['email']??'0',
            'college_code':item['college_code'] ?? '0',
            'college_stamp':item['college_stamp']?? '0',
            'college_image' : item['college_image'] ?? '0',
            'college_name':item['college_name']?? '0',
            'college_sign' : item['college_sign'] ?? '0',
          };
        }).toList();

        setState(() {
          students = tempStudents;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  List<String> get divisions {
    if (selectedClass == null) {
      return classDivisionsMap.values.expand((divisions) => divisions).toList();
    } else {
      return classDivisionsMap[selectedClass!] ?? [];
    }
  }

  void onClassSelected(String? newValue) {
    setState(() {
      selectedClass = newValue;
      selectedDivision = null;
      students = []; // Clear the students list when class is changed
      if (selectedClass != null && divisions.isNotEmpty) {
        selectedDivision = divisions.first;
        fetchStudents(
            selectedClass!.split(' ')[1], selectedDivision!.split(' ')[1]);
      }
    });
  }

  void onDivisionSelected(String? newValue) {
    setState(() {
      selectedDivision = newValue;
      if (selectedClass != null && selectedDivision != null) {
        // Extract the class standard from the selected class string
        final String standard = selectedClass!.split(' ')[1];
        final String division = selectedDivision!.split(' ')[1];
        fetchStudents(standard, division);
      }
    });
  }

  String getStudentCountText() {
    final classText = selectedClass ?? 'N/A';
    final divisionText = selectedDivision ?? 'N/A';
    return '${students.length} Students & $classText $divisionText';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedClass,
                      onChanged: onClassSelected,
                      items: classes.map<DropdownMenuItem<String>>((className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 50.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Division',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDivision,
                      onChanged: onDivisionSelected,
                      items: divisions
                          .map<DropdownMenuItem<String>>((divisionName) {
                        return DropdownMenuItem<String>(
                          value: divisionName,
                          child: Text(divisionName),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              getStudentCountText(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentIDCard(
                                    name: student['name'] ?? 'No Name',
                                    email: student['email'] ?? 'No Email',
                                    studentid: student['id'] ?? '',
                                    standard: selectedClass!,
                                    division: selectedDivision!,
                                    bloodGroup: student['bloodGroup'] ?? '',
                                    phonenumber: student['phonenumber'] ?? '',
                                    dateofbirth: student['dateofbirth'] ?? '',
                                    profile: student['profile_img'] ?? '',
                                    collegeCode: student['college_code'] ?? '',
                                    collegeName: student['college_name'] ?? '',
                                    collegeimage: student['college_image'] ?? '',
                                    collegesign: student['collegesign'] ?? '',
                                    collegestamp: student['collegestamp'] ?? '',
                                  )));

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ReportScreen(
                      //       studName: student['name'] ?? 'No Name',
                      //       studRollNo: student['rollNumber'] ?? 'No Roll Number',
                      //       studStd: selectedClass!,
                      //       studDiv: selectedDivision!,
                      //       collegeCode: widget.collegecode,
                      //       studId: student['id'] ?? '',
                      //       photo: student['profile_img'] ?? '',
                      //     ),
                      //   ),
                      // );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (student['profile_img'] != null &&
                                student['profile_img']!.isNotEmpty)
                            ? NetworkImage(student['profile_img']!)
                            : AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      ),
                      title: Text(student['name'] ?? 'No Name'),
                      trailing: Text(student['rollNumber'] ?? 'No Roll Number'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
