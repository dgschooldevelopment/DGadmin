// import 'dart:typed_data';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:path_provider/path_provider.dart';

// class StudentIDCard extends StatefulWidget {
//   final String name;
//   final String email;
//   final String studentid;
//   final String standard;
//   final String division;
//   final String bloodGroup;
//   final String phonenumber;
//   final String dateofbirth;
//   final String profile;
//   final String collegeCode;
//   final String collegeName;
//   final String collegeimage;
//   final String collegesign;
//   final String collegestamp;

//   const StudentIDCard(
//       {super.key,
//       required this.name,
//       required this.email,
//       required this.studentid,
//       required this.standard,
//       required this.division,
//       required this.bloodGroup,
//       required this.phonenumber,
//       required this.dateofbirth,
//       required this.profile,
//       required this.collegeCode,
//       required this.collegeName,
//       required this.collegeimage,
//       required this.collegesign,
//       required this.collegestamp});

//   @override
//   _StudentIDCardState createState() => _StudentIDCardState();
// }

// class _StudentIDCardState extends State<StudentIDCard> {
//   final GlobalKey _frontKey = GlobalKey();
//   final GlobalKey _backKey = GlobalKey();

//   // final Map<String, String> studentData = {
//   //   "name": "John Doe",
//   //   "id": "123456",
//   //   "email": "johndoe@gmail.com",
//   //   "department": "Computer Science",
//   //   "dob": "01-01-2000",
//   //   "bloodGroup": "B+",
//   //   "phone": "+91 9876543210",
//   //   "photoUrl":
//   //       "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOuxrvcNMfGLh73uKP1QqYpKoCB0JLXiBMvA&s",
//   // };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Student ID Card")),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 RepaintBoundary(
//                   key: _frontKey,
//                   child: buildIdCardFront(),
//                 ),
//                 SizedBox(width: 20),
//                 RepaintBoundary(
//                   key: _backKey,
//                   child: buildIdCardBack(),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => captureAndSaveBothSides(),
//             child: Text("Save ID Card Front & Back"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildIdCardFront() {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Container(
//         width: 300,
//         height: 400,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 300,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 gradient: LinearGradient(
//                   colors: [Colors.black87, Colors.red],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   "Mahatma Gandhi Junior College,\nPravaranagar!!",
//                   style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             CircleAvatar(
//               radius: 46,
//               backgroundColor: Colors.redAccent,
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundImage: NetworkImage(widget.profile),
//               ),
//             ),
//             SizedBox(height: 10),
//             Text("${widget.name}",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
//             Text("${widget.email}",
//                 style: TextStyle(fontSize: 12, color: Colors.red)),
//             SizedBox(height: 15),
//             buildInfoRow("ID", widget.studentid),
//             buildInfoRow("class", widget.standard),
//             buildInfoRow("Division", widget.division),
//             buildInfoRow("DOB", widget.dateofbirth),
//             buildInfoRow("Blood Group", widget.bloodGroup),
//             buildInfoRow("Phone", widget.phonenumber),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildIdCardBack() {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Container(
//         width: 300,
//         height: 400,
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("ID: ${widget.studentid}",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text("DOB: ${widget.dateofbirth}", style: TextStyle(fontSize: 16)),
//             Text("Blood Group: ${widget.bloodGroup}",
//                 style: TextStyle(fontSize: 16)),
//             Text("Phone: ${widget.phonenumber}",
//                 style: TextStyle(fontSize: 16)),
//             SizedBox(height: 20),
//             Text(
//               "This ID card is the property of Mahatma Gandhi Junior College and should be returned if found.",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontStyle: FontStyle.italic,
//                   color: Colors.redAccent),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 50),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
//           Text(value, style: TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   /// **Capture and Save Both Front and Back ID Cards**
//   Future<void> captureAndSaveBothSides() async {
//     try {
//       // Capture front side
//       String frontPath =
//           await captureAndSaveImage(_frontKey, "Student_ID_Front.png");

//       // Capture back side
//       String backPath =
//           await captureAndSaveImage(_backKey, "Student_ID_Back.png");

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("ID Card Saved!\nFront: $frontPath\nBack: $backPath 🎉"),
//       ));
//     } catch (e) {
//       print("Error saving images: $e");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Failed to save ID Card."),
//       ));
//     }
//   }

//   /// **Capture Widget as an Image and Save to File**
//   Future<String> captureAndSaveImage(GlobalKey key, String fileName) async {
//     RenderRepaintBoundary boundary =
//         key.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();

//     // Get Downloads directory
//     final directory = await getDownloadsDirectory();
//     String filePath = '${directory!.path}/$fileName';

//     // Save image as a file
//     File file = File(filePath);
//     await file.writeAsBytes(pngBytes);
//     return filePath;
//   }
// }

import 'package:flutter/material.dart';

class StudentIDCard extends StatelessWidget {
   final String name;
  final String email;
  final String studentid;
  final String standard;
  final String division;
  final String bloodGroup;
  final String phonenumber;
  final String dateofbirth;
  final String profile;
  final String collegeCode;
  final String collegeName;
  final String collegeimage;
  final String collegesign;
  final String collegestamp;

  const StudentIDCard({
    super.key, required this.name, required this.email, required this.studentid, required this.standard, required this.division, required this.bloodGroup, required this.phonenumber, required this.dateofbirth, required this.profile, required this.collegeCode, required this.collegeName, required this.collegeimage, required this.collegesign, required this.collegestamp,
    
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("Student ID Card")),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Container(
            width: 350,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF142C73),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        collegeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "College Code: $collegeCode",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage(profile),
                  ),
                ),

                const SizedBox(height: 10),

                // Student Name & Class
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Std: $standard $division",
                  style: const TextStyle(fontSize: 16, color: Colors.teal),
                ),

                const SizedBox(height: 15),

                // Student Details
                buildInfoRow("ID NO", studentid),
                buildInfoRow("DOB", dateofbirth),
                buildInfoRow("Blood", bloodGroup),
                buildInfoRow("Phone", phonenumber),
                buildInfoRow("E-mail", email),

                const Spacer(),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Principle", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("School Stamp", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
