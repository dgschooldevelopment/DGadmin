import 'dart:convert';

import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class DeletedTeacherList extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  DeletedTeacherList({
    required this.collegecode,
    required this.collegename,
    required this.collegeimage,
  });

  @override
  _DeletedTeacherListState createState() => _DeletedTeacherListState();
}

class _DeletedTeacherListState extends State<DeletedTeacherList> {
  List<TeacherItem> deletedTeachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeletedTeachers();
  }

  Future<void> fetchDeletedTeachers() async {
    final response = await http.get(Uri.parse(
        '$deletedteacher?college_code=${widget.collegecode}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        deletedTeachers =
            data.map((item) => TeacherItem.fromJson(item)).toList();
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Deleted Teachers")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Profile'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Teacher Name'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Email'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Deleted At'))),
                  ],
                ),
                for (var teacher in deletedTeachers)
                  TableRow(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(teacher.teacherProfile),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(teacher.tname),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(teacher.teacherEmail),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(teacher.deletedAt ?? "N/A"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
  final String? deletedAt; // Added deletedAt

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
    this.deletedAt, // Make it nullable
  });

  factory TeacherItem.fromJson(Map<String, dynamic> json) {
    return TeacherItem(
      teacherId: json['teacher_id'] ?? 0,
      teacherCode: json['teacher_code'] ?? '',
      tname: json['tname'] ?? '',
      tpassword: json['tpassword'] ?? '',
      mobileno: json['mobileno'] ?? '',
      teacherEmail: json['teacher_email'] ?? '',
      teacherProfile: json['teacher_profile'] ?? '',
      standard: json['standard'] ?? '',
      division: json['division'] ?? '',
      deletedAt: json['deleted_at'], // Include deletedAt field
    );
  }
}


