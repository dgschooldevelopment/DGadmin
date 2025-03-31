// import 'package:dgadmin/Admin/Teacher/Pendinghomewrk.dart';
// import 'package:dgadmin/base.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class TeacherHomework extends StatefulWidget {
//   final String teacherid;
//   final String collegecode;
//   const TeacherHomework({super.key, required this.teacherid, required this.collegecode});

//   @override
//   State<TeacherHomework> createState() => _TeacherHomeworkState();
  
// }
// enum uploadhomework {  view, submitted }

// class _TeacherHomeworkState extends State<TeacherHomework> {





//   // late Color createdButtonColor;
//   // late Color pendingButtonColor;
//   late Color submitButtonColor;
//   late Color viewButtonColor;
//    uploadhomework _currentState = uploadhomework.view;
//   String? _selectedSubject;
//   String? _selectedClass;
//   String? _selectedDiv;

//   List<Map<String, String>> _subjects = [];
//   List<String> _classes = [];
//   List<String> _divs = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchClassList(widget.collegecode, widget.teacherid);

//     // createdButtonColor = Color.fromARGB(255, 56, 139, 228); // Blue
//     // pendingButtonColor = Colors.grey[200]!; // Container color
//     submitButtonColor = Colors.grey[200]!; // Container color
//     viewButtonColor = Color.fromARGB(255, 56, 139, 228);

//     // Initialize colors with default values
//   }

//   // void _selectCreated() {
//   //   setState(() {
//   //     _currentState = uploadhomework.created;
//   //     createdButtonColor = Color.fromARGB(255, 56, 139, 228); // Blue
//   //     pendingButtonColor = Colors.grey[200]!; // Container color
//   //     submitButtonColor = Colors.grey[200]!;
//   //     viewButtonColor = Colors.grey[200]!;
//   //   });
//   // }

//   // void _selectPending() {
//   //   setState(() {
//   //     _currentState = uploadhomework.pending;
//   //     createdButtonColor = Colors.grey[200]!; // Container color
//   //     pendingButtonColor = Colors.red; // Blue
//   //     submitButtonColor = Colors.grey[200]!;
//   //     viewButtonColor = Colors.grey[200]!;
//   //   });
//   // }

//   void _selectView() {
//     setState(() {
//       _currentState = uploadhomework.view;
//       // createdButtonColor = Colors.grey[200]!; // Container color
//       // pendingButtonColor = Colors.grey[200]!;
//       submitButtonColor = Colors.grey[200]!;
//       viewButtonColor = Color.fromARGB(255, 56, 139, 228);
//     });
//   }

//   void _selectSubmitted() {
//     setState(() {
//       _currentState = uploadhomework.submitted;
//       // createdButtonColor = Colors.grey[200]!; // Container color
//       // pendingButtonColor = Colors.grey[200]!; // Container color
//       submitButtonColor = Colors.green; // Blue
//       viewButtonColor = Colors.grey[200]!;
//     });
//   }

//   Future<void> fetchClassList(String collegecode, String teacherid) async {
//     final response = await http.get(
//       Uri.parse(
//           '$teacherclasslist?teacher_code=${widget.teacherid}&college_code=${widget.collegecode}'),
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _classes = (data['classList'] as List)
//             .map<String>((item) => item['stand'].toString())
//             .toSet()
//             .toList();
//         _divs = (data['classList'] as List)
//             .map<String>((item) => item['division'].toString())
//             .toSet()
//             .toList();
//         _subjects = (data['classList'] as List)
//             .map<Map<String, String>>((item) => {
//                   'name': item['subject_name'].toString(),
//                   'code': item['subject_code_prefixed'].toString(),
//                 })
//             .toList();

//         // Set initial values for dropdowns to the first entries
//         if (_subjects.isNotEmpty) {
//           _selectedSubject = _subjects[0]['code'];
//         }
//         if (_classes.isNotEmpty) {
//           _selectedClass = _classes[0];
//         }
//         if (_divs.isNotEmpty) {
//           _selectedDiv = _divs[0];
//         }
//       });
//     } else {
//       throw Exception('Failed to load class list');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//      double screenWidth = MediaQuery.of(context).size.width;
//     double padding = screenWidth * 0.2;
//     return Scaffold(
//       body: Padding(
//               padding: EdgeInsets.symmetric(horizontal: padding),
//         child: Column(
//           children: [
//             // Container(
//             //   height: 150,
//             //   decoration: BoxDecoration(
//             //     color: Colors.blue
//             //   ),
//             //   // margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),

             
//             //   child: Row(
//             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //     children: [
//             //       Container(

//             //       child: InkWell(
//             //           onTap: (){
//             //             Navigator.pop(context);
//             //           },
//             //           child: Icon(Icons.arrow_back,size: 32,color: Colors.white,)),

//             //     ),

//             //       Padding(
//             //         padding: const EdgeInsets.all(8.0),
//             //         child: Text(
//             //           'Your homework\n is Here...',
//             //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
//             //           maxLines: 2,
//             //         ),
//             //       ),
//             //       SizedBox(width: 6),
//             //       Padding(
//             //         padding: const EdgeInsets.all(8.0),
//             //         child: Image.asset(
//             //           'assets/student homework.png',
//             //           width: 120,
//             //           height: 120,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             // SizedBox(height: 20),
       
//            Container(
//   // height: 100,
//   decoration: BoxDecoration(
//     // color: Colors.grey[200], // Container color
//   ),
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // Container(
//           //   width: 160, // Fixed width for "Created"
//           //   child: ElevatedButton(
//           //     onPressed: _selectView,
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: viewButtonColor,
//           //       elevation: 0,
//           //       shape: RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.circular(5),
//           //         side: BorderSide(color: Colors.grey),
//           //       ),
//           //     ),
//           //     child: Text(
//           //       'Created',
//           //       style: TextStyle(
//           //         color: viewButtonColor == Colors.grey[200]!
//           //             ? Colors.black
//           //             : Colors.white,
//           //         fontWeight: FontWeight.bold,
//           //         fontSize: 16,
//           //       ),
//           //     ),
//           //   ),
//           // ),
        
        
//           Container(
//             width: 160, // Fixed width for "View"
//             child: ElevatedButton(
//               onPressed: _selectView,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: viewButtonColor,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                   side: BorderSide(color: Colors.grey),
//                 ),
//               ),
//               child: Text(
//                 'View',
//                 style: TextStyle(
//                   color: viewButtonColor == Colors.grey[200]!
//                       ? Colors.black
//                       : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
       
//            Container(
//             width: 160, // Fixed width for "Submitted"
//             child: ElevatedButton(
//               onPressed: _selectSubmitted,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: submitButtonColor,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                   side: BorderSide(color: Colors.grey),
//                 ),
//               ),
//               child: Text(
//                 'Submitted',
//                 style: TextStyle(
//                   color: submitButtonColor == Colors.grey[200]!
//                       ? Colors.black
//                       : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
       
       
//         ],
//       ),
//       // Row(
//       //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       //   children: [
//       //     // Container(
//       //     //   width: 160, // Fixed width for "Pending"
//       //     //   child: ElevatedButton(
//       //     //     onPressed: _selectPending,
//       //     //     style: ElevatedButton.styleFrom(
//       //     //       backgroundColor: pendingButtonColor,
//       //     //       elevation: 0,
//       //     //       shape: RoundedRectangleBorder(
//       //     //         borderRadius: BorderRadius.circular(5),
//       //     //         side: BorderSide(color: Colors.grey),
//       //     //       ),
//       //     //     ),
//       //     //     child: Text(
//       //     //       'Pending',
//       //     //       style: TextStyle(
                  
//       //     //         color: pendingButtonColor == Colors.grey[200]!
//       //     //             ? Colors.black
//       //     //             : Colors.white,
//       //     //         fontWeight: FontWeight.bold,
//       //     //         fontSize: 16,
                 
              
//       //     //       ),
//       //     //     ),
//       //     //   ),
//       //     // ),
        
//       //     Container(
//       //       width: 160, // Fixed width for "Submitted"
//       //       child: ElevatedButton(
//       //         onPressed: _selectSubmitted,
//       //         style: ElevatedButton.styleFrom(
//       //           backgroundColor: submitButtonColor,
//       //           elevation: 0,
//       //           shape: RoundedRectangleBorder(
//       //             borderRadius: BorderRadius.circular(5),
//       //             side: BorderSide(color: Colors.grey),
//       //           ),
//       //         ),
//       //         child: Text(
//       //           'Submitted',
//       //           style: TextStyle(
//       //             color: submitButtonColor == Colors.grey[200]!
//       //                 ? Colors.black
//       //                 : Colors.white,
//       //             fontWeight: FontWeight.bold,
//       //             fontSize: 16,
//       //           ),
//       //         ),
//       //       ),
//       //     ),
       
//       //   ],
//       // ),
    
//     ],
//   ),
// ),

//             SizedBox(
//               height: 20,
//             ),

// Container(
//   child: Padding(
//     padding: const EdgeInsets.all(10.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             decoration: InputDecoration(
//               labelText: 'Subject',
//               border: OutlineInputBorder(),
//             ),
//             value: _selectedSubject,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedSubject = newValue;
//               });
//             },
//             items: _subjects.map<DropdownMenuItem<String>>((subject) {
//               return DropdownMenuItem<String>(
//                 value: subject['code'],
//                 child: Text(subject['name']!),
//               );
//             }).toList(),
//           ),
//         ),
//         SizedBox(width: 10),
//         SizedBox(
//           width: 75,
//           child: DropdownButtonFormField<String>(
//             decoration: InputDecoration(
//               labelText: 'Class',
//               border: OutlineInputBorder(),
//             ),
//             value: _selectedClass,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedClass = newValue;
//               });
//             },
//             items: _classes.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         ),
//         SizedBox(width: 10),
//         SizedBox(
//           width: 75,
//           child: DropdownButtonFormField<String>(
//             decoration: InputDecoration(
//               labelText: 'Div',
//               border: OutlineInputBorder(),
//             ),
//             value: _selectedDiv,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedDiv = newValue;
//               });
//             },
//             items: _divs.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                  child: _buildCurrentView(), // Remove Expanded
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentView() {
//     switch (_currentState) {
//       case uploadhomework.created:
//         return CreateHomework(
//           collegecode: widget.collegecode,
//           teacherid: widget.teacherid,
//           standard: _selectedClass, // Example: Pass selected class
//           division: _selectedDiv, // Example: Pass selected division
//           subjectid: _selectedSubject,
//         );
//       case uploadhomework.pending:
//         return PendingAssignmentList(
//           collegecode: widget.collegecode,
//           teacherid: widget.teacherid,
//           standard: _selectedClass ?? '', // Example: Pass selected class
//           division: _selectedDiv ?? '', // Example: Pass selected division
//           subjectid: _selectedSubject ?? '',
//         ); // Placeholder for pending state
//       case uploadhomework.view:
//         return ViewAssignmentList(
//           collegecode: widget.collegecode,
//           teacherid: widget.teacherid,
//           standard: _selectedClass, // Example: Pass selected class
//           division: _selectedDiv, // Example: Pass selected division
//           subjectid: _selectedSubject, // Example: Pass selected subject
//         );
//       //  return ViewAssignmentList();
//       case uploadhomework.submitted:
//         return SubmittedAssignmentList(
//           collegecode: widget.collegecode,
//           teacherid: widget.teacherid,
//           standard: _selectedClass, // Example: Pass selected class
//           division: _selectedDiv, // Example: Pass selected division
//           subjectid: _selectedSubject,
//         ); // Placeholder for submitted state
//       default:
//         return Container();
//     }
//   }


// }
import 'package:dgadmin/Admin/Teacher/Pendinghomewrk.dart';
import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'submittedhomework.dart';

class TeacherHomework extends StatefulWidget {
  final String teacherid;
  final String collegecode;
  const TeacherHomework({super.key, required this.teacherid, required this.collegecode});

  @override
  State<TeacherHomework> createState() => _TeacherHomeworkState();
  
}
enum uploadhomework {  view, submitted }

class _TeacherHomeworkState extends State<TeacherHomework> {





  // late Color createdButtonColor;
  // late Color pendingButtonColor;
  late Color submitButtonColor;
  late Color viewButtonColor;
   uploadhomework _currentState = uploadhomework.view;
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedDiv;

  List<Map<String, String>> _subjects = [];
  List<String> _classes = [];
  List<String> _divs = [];

  @override
  void initState() {
    super.initState();
    fetchClassList(widget.collegecode, widget.teacherid);

    // createdButtonColor = Color.fromARGB(255, 56, 139, 228); // Blue
    // pendingButtonColor = Colors.grey[200]!; // Container color
    submitButtonColor = Colors.grey[200]!; // Container color
    viewButtonColor = Color.fromARGB(255, 56, 139, 228);

    // Initialize colors with default values
  }

  // void _selectCreated() {
  //   setState(() {
  //     _currentState = uploadhomework.created;
  //     createdButtonColor = Color.fromARGB(255, 56, 139, 228); // Blue
  //     pendingButtonColor = Colors.grey[200]!; // Container color
  //     submitButtonColor = Colors.grey[200]!;
  //     viewButtonColor = Colors.grey[200]!;
  //   });
  // }

  // void _selectPending() {
  //   setState(() {
  //     _currentState = uploadhomework.pending;
  //     createdButtonColor = Colors.grey[200]!; // Container color
  //     pendingButtonColor = Colors.red; // Blue
  //     submitButtonColor = Colors.grey[200]!;
  //     viewButtonColor = Colors.grey[200]!;
  //   });
  // }

  void _selectView() {
    setState(() {
      _currentState = uploadhomework.view;
      // createdButtonColor = Colors.grey[200]!; // Container color
      // pendingButtonColor = Colors.grey[200]!;
      submitButtonColor = Colors.grey[200]!;
      viewButtonColor = Color.fromARGB(255, 56, 139, 228);
    });
  }

  void _selectSubmitted() {
    setState(() {
      _currentState = uploadhomework.submitted;
      // createdButtonColor = Colors.grey[200]!; // Container color
      // pendingButtonColor = Colors.grey[200]!; // Container color
      submitButtonColor = Colors.green; // Blue
      viewButtonColor = Colors.grey[200]!;
    });
  }

  Future<void> fetchClassList(String collegecode, String teacherid) async {
    final response = await http.get(
      Uri.parse(
          '$teacherclasslist?teacher_code=${widget.teacherid}&college_code=${widget.collegecode}'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _classes = (data['classList'] as List)
            .map<String>((item) => item['stand'].toString())
            .toSet()
            .toList();
        _divs = (data['classList'] as List)
            .map<String>((item) => item['division'].toString())
            .toSet()
            .toList();
        _subjects = (data['classList'] as List)
            .map<Map<String, String>>((item) => {
                  'name': item['subject_name'].toString(),
                  'code': item['subject_code_prefixed'].toString(),
                })
            .toList();

        // Set initial values for dropdowns to the first entries
        if (_subjects.isNotEmpty) {
          _selectedSubject = _subjects[0]['code'];
        }
        if (_classes.isNotEmpty) {
          _selectedClass = _classes[0];
        }
        if (_divs.isNotEmpty) {
          _selectedDiv = _divs[0];
        }
      });
    } else {
      throw Exception('Failed to load class list');
    }
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
            // Container(
            //   height: 150,
            //   decoration: BoxDecoration(
            //     color: Colors.blue
            //   ),
            //   // margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),

             
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Container(

            //       child: InkWell(
            //           onTap: (){
            //             Navigator.pop(context);
            //           },
            //           child: Icon(Icons.arrow_back,size: 32,color: Colors.white,)),

            //     ),

            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Text(
            //           'Your homework\n is Here...',
            //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
            //           maxLines: 2,
            //         ),
            //       ),
            //       SizedBox(width: 6),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Image.asset(
            //           'assets/student homework.png',
            //           width: 120,
            //           height: 120,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 20),
       
           Container(
  // height: 100,
  decoration: BoxDecoration(
    // color: Colors.grey[200], // Container color
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container(
          //   width: 160, // Fixed width for "Created"
          //   child: ElevatedButton(
          //     onPressed: _selectView,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: viewButtonColor,
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(5),
          //         side: BorderSide(color: Colors.grey),
          //       ),
          //     ),
          //     child: Text(
          //       'Created',
          //       style: TextStyle(
          //         color: viewButtonColor == Colors.grey[200]!
          //             ? Colors.black
          //             : Colors.white,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16,
          //       ),
          //     ),
          //   ),
          // ),
        
        
          Container(
            width: 160, // Fixed width for "View"
            child: ElevatedButton(
              onPressed: _selectView,
              style: ElevatedButton.styleFrom(
                backgroundColor: viewButtonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  color: viewButtonColor == Colors.grey[200]!
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
       
           Container(
            width: 160, // Fixed width for "Submitted"
            child: ElevatedButton(
              onPressed: _selectSubmitted,
              style: ElevatedButton.styleFrom(
                backgroundColor: submitButtonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              child: Text(
                'Submitted',
                style: TextStyle(
                  color: submitButtonColor == Colors.grey[200]!
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
       
       
        ],
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     // Container(
      //     //   width: 160, // Fixed width for "Pending"
      //     //   child: ElevatedButton(
      //     //     onPressed: _selectPending,
      //     //     style: ElevatedButton.styleFrom(
      //     //       backgroundColor: pendingButtonColor,
      //     //       elevation: 0,
      //     //       shape: RoundedRectangleBorder(
      //     //         borderRadius: BorderRadius.circular(5),
      //     //         side: BorderSide(color: Colors.grey),
      //     //       ),
      //     //     ),
      //     //     child: Text(
      //     //       'Pending',
      //     //       style: TextStyle(
                  
      //     //         color: pendingButtonColor == Colors.grey[200]!
      //     //             ? Colors.black
      //     //             : Colors.white,
      //     //         fontWeight: FontWeight.bold,
      //     //         fontSize: 16,
                 
              
      //     //       ),
      //     //     ),
      //     //   ),
      //     // ),
        
      //     Container(
      //       width: 160, // Fixed width for "Submitted"
      //       child: ElevatedButton(
      //         onPressed: _selectSubmitted,
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: submitButtonColor,
      //           elevation: 0,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(5),
      //             side: BorderSide(color: Colors.grey),
      //           ),
      //         ),
      //         child: Text(
      //           'Submitted',
      //           style: TextStyle(
      //             color: submitButtonColor == Colors.grey[200]!
      //                 ? Colors.black
      //                 : Colors.white,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 16,
      //           ),
      //         ),
      //       ),
      //     ),
       
      //   ],
      // ),
    
    ],
  ),
),

            SizedBox(
              height: 20,
            ),

Container(
  child: Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
            value: _selectedSubject,
            onChanged: (String? newValue) {
              setState(() {
                _selectedSubject = newValue;
              });
            },
            items: _subjects.map<DropdownMenuItem<String>>((subject) {
              return DropdownMenuItem<String>(
                value: subject['code'],
                child: Text(subject['name']!),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
            value: _selectedClass,
            onChanged: (String? newValue) {
              setState(() {
                _selectedClass = newValue;
              });
            },
            items: _classes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 75,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Div',
              border: OutlineInputBorder(),
            ),
            value: _selectedDiv,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDiv = newValue;
              });
            },
            items: _divs.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  ),
),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                 child: _buildCurrentView(), // Remove Expanded
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentState) {
      // case uploadhomework.created:
      //   return CreateHomework(
      //     collegecode: widget.collegecode,
      //     teacherid: widget.teacherid,
      //     standard: _selectedClass, // Example: Pass selected class
      //     division: _selectedDiv, // Example: Pass selected division
      //     subjectid: _selectedSubject,
      //   );
      // case uploadhomework.pending:
      //   return PendingAssignmentList(
      //     collegecode: widget.collegecode,
      //     teacherid: widget.teacherid,
      //     standard: _selectedClass ?? '', // Example: Pass selected class
      //     division: _selectedDiv ?? '', // Example: Pass selected division
      //     subjectid: _selectedSubject ?? '',
      //   ); // Placeholder for pending state
      case uploadhomework.view:
        return ViewAssignmentList(
          collegecode: widget.collegecode,
          teacherid: widget.teacherid,
          standard: _selectedClass, // Example: Pass selected class
          division: _selectedDiv, // Example: Pass selected division
          subjectid: _selectedSubject, // Example: Pass selected subject
        );
      case uploadhomework.submitted:
        return SubmittedAssignmentList(
          collegecode: widget.collegecode,
          teacherid: widget.teacherid,
          standard: _selectedClass, // Example: Pass selected class
          division: _selectedDiv, // Example: Pass selected division
          subjectid: _selectedSubject,
        ); // Placeholder for submitted state
      default:
        return Container();
    }
  }


}