import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void showAssignSubjectDialog(BuildContext context, String collegecode) {
  String? selectedTeacher;
  List<Map<String, String?>> assignedSubjects = [];
  List<Map<String, String>> teachers = [];
  List<Map<String, String>> subjects = []; // Store subjects from API
  List<String> classes = [];
  List<String> divisions = [];

  // Fetch teachers from API
  Future<void> fetchTeachers(String collegecode) async {
    try {
      final response = await http.get(
        Uri.parse("$getAllTeacher?college_code=$collegecode"),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> teacherList = data['teachers'];

        teachers = teacherList.map((teacher) {
          return {
            "teacher_code": teacher["teacher_code"].toString(),
            "tname": teacher["tname"].toString(),
          };
        }).toList();
      } else {
        throw Exception("Failed to load teachers");
      }
    } catch (e) {
      print("Error fetching teachers: $e");
    }
  }

  // Fetch subjects from API
  Future<void> fetchSubjects(String collegecode) async {
    try {
      final response = await http.get(
        Uri.parse("$getAllSubjects?college_code=$collegecode"),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> subjectList = data['subjects'];

        subjects = subjectList.map((subject) {
          return {
            "subjectCode": subject["subjectCode"].toString(),
            "subject_name": subject["subject_name"].toString(),
            "std": subject["std"].toString(),
            "division": subject["division"].toString(),
          };
        }).toList();

        // Extract unique classes and divisions
        classes = subjects.map((s) => s['std']!).toSet().toList();
        divisions = subjects.map((s) => s['division']!).toSet().toList();
      } else {
        throw Exception("Failed to load subjects");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
    }
  }

  // Assign teacher to selected subjects API call
  Future<void> assignTeacherToSubject(String collegecode) async {
    if (selectedTeacher == null || assignedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please select a teacher and at least one subject assignment")),
      );
      return;
    }

    try {
      for (var entry in assignedSubjects) {
        if (entry["class"] == null ||
            entry["division"] == null ||
            entry["subject"] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Please fill in all subject details before assigning")),
          );
          return;
        }

        // Get subject code from selected subject
        // String? subjectCode = subjects.firstWhere(
        //     (s) => s["subject_name"] == entry["subject"],
        //     orElse: () => {})["subjectCode"];
        String? subjectCode = subjects.firstWhere(
  (s) => s["subject_name"] == entry["subject"] &&
         s["std"] == entry["class"] &&
         s["division"] == entry["division"],
  orElse: () => {}
)["subjectCode"];


        if (subjectCode == null) continue;

        // Get teacher code from selected teacher
        String? teacherCode = teachers.firstWhere(
            (t) => t["tname"] == selectedTeacher,
            orElse: () => {})["teacher_code"];

        if (teacherCode == null) continue;

        final response = await http.post(
          Uri.parse("$assignTeacherSubject?college_code=$collegecode"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"subject_code": subjectCode, "teacher_code": teacherCode}),
        );
        print(subjectCode);

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          print("Assigned Successfully: ${responseData['message']}");
        } else {
          print("Failed to assign teacher: ${response.body}");
        }
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher assigned successfully!")),
      );
    } catch (e) {
      print("Error assigning teacher: $e");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder(
            future: Future.wait(
                [fetchTeachers(collegecode), fetchSubjects(collegecode)]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Container(
                  width: 700,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Assign Subject to Teacher",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        context,
                        "Teacher:",
                        "Select a Teacher",
                        teachers.map((e) => e['tname']!).toList(),
                        selectedTeacher,
                        (String? value) {
                          setState(() {
                            selectedTeacher = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: assignedSubjects.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    context,
                                    "Class:",
                                    "Select a Class",
                                    classes,
                                    entry["class"],
                                    (String? value) {
                                      setState(() {
                                        entry["class"] = value;
                                        entry["division"] = null;
                                        entry["subject"] = null;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildDropdownField(
                                    context,
                                    "Division:",
                                    "Select a Division",
                                    divisions,
                                    entry["division"],
                                    (String? value) {
                                      setState(() {
                                        entry["division"] = value;
                                        entry["subject"] = null;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildDropdownField(
                                    context,
                                    "Subject:",
                                    "Select a Subject",
                                    subjects
                                        .where((s) =>
                                            s["std"] == entry["class"] &&
                                            s["division"] == entry["division"])
                                        .map((s) => s["subject_name"]!)
                                        .toList(),
                                    entry["subject"],
                                    (String? value) {
                                      setState(() {
                                        entry["subject"] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: Colors.blue, size: 30),
                          onPressed: () {
                            setState(() {
                              assignedSubjects.add({
                                "class": null,
                                "division": null,
                                "subject": null
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        // ElevatedButton(//-
                        //   onPressed: assignTeacherToSubject(collegecode),//-
                        //   child: const Text("Assign Teacher to Subject"),//-
                        // ),//-
                        // ],//-
                        ElevatedButton(
                          //+
                          onPressed: () =>
                              assignTeacherToSubject(collegecode), //+
                          child: const Text("Assign Teacher to Subject"), //+
                        ),
                      ] //+
                          ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildDropdownField(
  BuildContext context,
  String label,
  String hint,
  List<String> items,
  String? selectedValue,
  ValueChanged<String?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: selectedValue,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}
