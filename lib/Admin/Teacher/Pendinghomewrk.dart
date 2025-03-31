import 'dart:convert';
import 'dart:io';

import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ViewAssignmentList extends StatelessWidget {
  final String? collegecode;
  final String? teacherid;
  final String? standard;
  final String? division;
  final String? subjectid;

  ViewAssignmentList({
    Key? key,
    this.collegecode,
    this.teacherid,
    this.standard,
    this.division,
    this.subjectid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check for null values and handle accordingly
    if (collegecode == null ||
        teacherid == null ||
        standard == null ||
        division == null ||
        subjectid == null) {
      return Center(child: Text('Something went wrong !.'));
    }

    return FutureBuilder<List<HomeworkView>>(
      future: fetchHomework(
          collegecode!, teacherid!, standard!, division!, subjectid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No homework available'));
        } else {
          List<HomeworkView> homeworkList = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: homeworkList
                  .map((homework) => _buildHomeworkCard(context, homework))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkView homework) {
    return Container(
      height: 250,
      width: 450,
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          // border: Border.all(
          //   // color: Colors.grey,
          //   width: 1,
          // ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withOpacity(0.5), // Shadow color with transparency
              spreadRadius: 2, // How much the shadow spreads
              blurRadius: 9, // Softness of the shadow
              offset: Offset(3, 3), // X and Y offset (right, down)
            ),
          ]),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 86,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 135, 193, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                )),
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homework.subjectName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(
                      'View',
                      () => _showFile(context, homework.image),
                    ),
                    // Uncomment this if you want to add a Download button later
                    // _buildButton('Download'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Assignment: ${homework.hid}',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Homework Date:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                // SizedBox(width: 130),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    homework.dateOfGiven.split('T')[0],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  'Created on:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
              // SizedBox(width: 160),
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Text(
                  homework.dateOfCreation.split('T')[0],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Description:',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              homework.description,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          ),
          // SizedBox(height: 10,)
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 30,
        width: 70,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: const Color.fromARGB(255, 144, 51, 177),
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFile(BuildContext context, String fileUrl) {
    bool isPdf = fileUrl.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewScreen(fileUrl: fileUrl),
        ),
      );
    } else {
      _showImagePopup(context, fileUrl);
    }
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: precacheImage(NetworkImage(imageUrl), context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Image.network(imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Failed to load image"),
                      );
                    });
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<List<HomeworkView>> fetchHomework(String collegecode, String teacherid,
    String standard, String division, String subjectid) async {
  final url =
      '$viewhomework?college_code=$collegecode&teacher_code=$teacherid&Standard=$standard&Division=$division&subject_id=$subjectid';
  print('Fetching data from: $url');

  try {
    final response = await http.get(Uri.parse(url));
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print('Received data:');
      print(jsonResponse);
      return jsonResponse
          .map((homework) => HomeworkView.fromJson(homework))
          .toList();
    } else {
      print(
          'Failed to load homework. Error ${response.statusCode}: ${response.reasonPhrase}');
      return []; // Return an empty list instead of throwing an error
    }
  } catch (e) {
    print('Exception during API call: $e');
    return []; // Return an empty list on exception
  }
}

class HomeworkView {
  final int hid;
  final String homeworkpId;
  final String subjectId;
  final String dateOfGiven;
  final String description;
  final String subjectName;
  final String standard;
  final String division;
  final String dateOfCreation;
  final String image;

  HomeworkView({
    required this.hid,
    required this.homeworkpId,
    required this.subjectId,
    required this.dateOfGiven,
    required this.description,
    required this.subjectName,
    required this.standard,
    required this.division,
    required this.dateOfCreation,
    required this.image,
  });

  factory HomeworkView.fromJson(Map<String, dynamic> json) {
    return HomeworkView(
      hid: json['hid'],
      homeworkpId: json['homeworkp_id'],
      subjectId: json['subject_id'],
      dateOfGiven: json['date_of_given'],
      description: json['description'],
      subjectName: json['subject_name'],
      standard: json['standard'],
      division: json['Division'],
      dateOfCreation: json['date_of_creation'],
      image: json['image'],
    );
  }
}

class PdfViewScreen extends StatefulWidget {
  final String fileUrl;

  PdfViewScreen({required this.fileUrl});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      var response = await http.get(Uri.parse(widget.fileUrl));
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localFilePath = file.path;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localFilePath!,
              enableSwipe: true,
              // swipeHorizontal: true,

              autoSpacing: false,
              pageFling: false,
            ),
    );
  }
}
