
import 'dart:io';
import 'dart:typed_data';
import 'package:dgadmin/Admin/Teacher/Pendinghomewrk.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
 import 'package:path_provider/path_provider.dart';
  import 'package:flutter_pdfview/flutter_pdfview.dart';



class SubmittedAssignmentList extends StatelessWidget {
  final String? collegecode;
  final String? teacherid;
  final String? standard;
  final String? division;
  final String? subjectid;

  SubmittedAssignmentList({
    Key? key,
    this.collegecode,
    this.teacherid,
    this.standard,
    this.division,
    this.subjectid,
  }) : super(key: key);

 

Future<List<Homework>> fetchAssignments() async {
  final response = await http.get(Uri.parse(
      '$getsubmittedhomework?college_code=$collegecode&teacher_code=$teacherid&Standard=$standard&Division=$division&subject_id=$subjectid'));

  print('API Response: ${response.body}'); // Debugging line

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    print('Parsed Data: $data'); // Debugging line
    return data.map((item) => Homework.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load assignments');
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Homework>>(
      future: fetchAssignments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong !'));
 
         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No assignments found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return AssignmentCard(assignment: snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class Homework {
  final int submittedId;
  final String homeworkSubmittedId;
  final String homeworkPendingId;
  final String subjectId;
  final String studentId;
  final String studentName;
  final DateTime dateOfGivenSubmitted;
  final String submittedDescription;
  final DateTime dateOfToSubmit;
  final String pendingDescription;
  final String subjectName;
  final int approvalStatus;
  final String review;
  final String hpImage;
  final String hsImages;

  Homework({
    required this.submittedId,
    required this.homeworkSubmittedId,
    required this.homeworkPendingId,
    required this.subjectId,
    required this.studentId,
    required this.studentName,
    required this.dateOfGivenSubmitted,
    required this.submittedDescription,
    required this.dateOfToSubmit,
    required this.pendingDescription,
    required this.subjectName,
    required this.approvalStatus,
    required this.review,
    required this.hpImage,
    required this.hsImages,
  });

factory Homework.fromJson(Map<String, dynamic> json) {
  return Homework(
    submittedId: int.tryParse(json['submitted_id']?.toString() ?? '0') ?? 0,
    homeworkSubmittedId: json['homeworksubmitted_id'] ?? '',
    homeworkPendingId: json['homeworkpending_id'] ?? '',
    subjectId: json['subject_id'] ?? '',
    studentId: json['studentid'] ?? '',
    studentName: json['studentName'] ?? '',
    dateOfGivenSubmitted: DateTime.parse(json['date_of_given_submitted'] ?? ''),
    submittedDescription: json['submitted_description'] ?? '',
    dateOfToSubmit: DateTime.parse(json['date_of_to_submit'] ?? ''),
    pendingDescription: json['pending_description'] ?? '',
    subjectName: json['subject_name'] ?? '',
    approvalStatus: json['approval_status'] ?? 0,
    review: json['review'] ?? '',
    hpImage: json['hpimage'] ?? '',
    hsImages: json['submitted_pdf'] ?? '', // Use URL directly instead of base64
  );
}


  Map<String, dynamic> toJson() {
    return {
      'submitted_id': submittedId,
      'homeworksubmitted_id': homeworkSubmittedId,
      'homeworkpending_id': homeworkPendingId,
      'subject_id': subjectId,
      'studentid': studentId,
      'studentName': studentName,
      'date_of_given_submitted': dateOfGivenSubmitted.toIso8601String(),
      'submitted_description': submittedDescription,
      'date_of_to_submit': dateOfToSubmit.toIso8601String(),
      'pending_description': pendingDescription,
      'subject_name': subjectName,
      'approval_status': approvalStatus,
      'review': review,
      'hpimage': hpImage,
      'hsimages': hsImages,
    };
  }
}

class AssignmentCard extends StatelessWidget {
  final Homework assignment;

  AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
     margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
             color: const Color.fromARGB(65, 26, 152, 255),
              borderRadius: BorderRadius.circular(10),
            ),
           
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.subjectName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                          context, 'View', assignment.hpImage, 'Homework Image'),
                      _buildButton(context, 'View Answer',
                          assignment.hsImages, 'Answer Image'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Text(
              'Assignment ID: ${assignment.homeworkPendingId}',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Homework Date:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  DateFormat('yyyy-MM-dd').format(assignment.dateOfToSubmit),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submission Date:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
              SizedBox(width: 5),
              Text(
                DateFormat('yyyy-MM-dd')
                    .format(assignment.dateOfGivenSubmitted),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created by:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  assignment.studentName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
           padding: const EdgeInsets.only(left: 10,right: 10),
            child: Text(
              'Description',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 5),
          Padding(
             padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
            child: Text(
              assignment.submittedDescription,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
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
                  return Image.network(imageUrl, errorBuilder: (context, error, stackTrace) {
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




  Widget _buildButton(
      BuildContext context, String text, String data, String title) {
    return InkWell(
      onTap: () {
          _showFile(context, data);
        // if (_isPdf(data)) {
        //   _showPdfViewer(context, data, title);
        // } else {
        //   _showImageDialog(context, data);
        // }
      },
      child: Container(
        decoration: BoxDecoration(
          
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Text(
          text,
          style: TextStyle(
            color: Color.fromARGB(255, 0, 59, 155),
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  bool _isPdf(String base64Data) {
    // Decode the first few bytes of the base64 string to check the file signature
    try {
      Uint8List bytes = base64Decode(base64Data);
      // PDF files start with "%PDF"
      return bytes.length > 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
    } catch (e) {
      print('Error checking PDF signature: $e');
      return false;
    }
  }

  void _showImageDialog(BuildContext context, String base64Image) async {
    Uint8List? imageBytes = await _decodeBase64Image(base64Image);
    if (imageBytes != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(imageBytes),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image')),
      );
    }
  }

  Future<Uint8List?> _decodeBase64Image(String base64Image) async {
    try {
      return base64Decode(base64Image);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  void _showPdfViewer(
      BuildContext context, String base64Pdf, String title) async {
    Uint8List? pdfBytes = await _decodeBase64Image(base64Pdf);
    if (pdfBytes != null) {
      String dir = (await getApplicationDocumentsDirectory()).path;
      String path = '$dir/temporary.pdf';
      File file = File(path);
      await file.writeAsBytes(pdfBytes, flush: true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: path, title: title),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF')),
      );
    }
  }

}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  final String title;

  PDFViewerScreen({required this.pdfPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PDFView(
        filePath: pdfPath,
      ),
    );
  }
}