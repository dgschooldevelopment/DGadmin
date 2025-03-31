// import 'package:dgadmin/Admin/Others/assignsubject.dart';
// import 'package:dgadmin/Admin/Others/idcard.dart';
// import 'package:dgadmin/base.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class OthersDash extends StatefulWidget {
//   final String collegecode;
//   const OthersDash({super.key, required this.collegecode});

//   @override
//   State<OthersDash> createState() => _OthersDashState();
// }

// class _OthersDashState extends State<OthersDash> {
//   final TextEditingController _classController = TextEditingController();
//   final TextEditingController _divisionController = TextEditingController();

//   Widget _buildTextField(
//       String label, String hintText, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 70, // Consistent label width
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 labelText: hintText,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.blue, width: 2),
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _addClass() async {
//     String className = _classController.text.trim();
//     String division = _divisionController.text.trim();

//     if (className.isEmpty || division.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter all details")),
//       );
//       return;
//     }

//     final url = "$addClass?college_code=${widget.collegecode}";

//     final body = jsonEncode({
//       "standard": className,
//       "division": division,
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: body,
//       );

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 201 &&
//           responseData['message'] == "Class added successfully.") {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text("Class added: ID ${responseData['class_id']}")),
//         );

//         _classController.clear();
//         _divisionController.clear();
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: ${responseData['message']}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to add class: $error")),
//       );
//     }
//   }

//   void _showAddClassDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Add Class"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildTextField("Class:", "Enter class name", _classController),
//               _buildTextField(
//                   "Division:", "Enter division", _divisionController),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: _addClass,
//               child: const Text("Add Class"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Others Dashboard"),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.class_),
//             title: const Text("Add Class"),
//             subtitle: const Text("Add class and division"),
//             trailing: const Icon(Icons.arrow_forward),
//             onTap: _showAddClassDialog,
//           ),
//           const Divider(),
//           const ListTile(
//             leading: Icon(Icons.money),
//             title: Text("Add Fee type"),
//             subtitle: Text("Add fee type"),
//             trailing: Icon(Icons.arrow_forward),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.subject),
//             title: const Text("Assign subject to teacher"),
//             subtitle: const Text("Assign subject to teacher"),
//             trailing: const Icon(Icons.arrow_forward),
//             onTap: () => showAssignSubjectDialog(
//                 context), // ✅ Correct way to call function
//           ),
//           const Divider(),
//           ListTile(
//             leading: Icon(Icons.card_membership),
//             title: Text("ID Card"),
//             subtitle: Text("ID Card"),
//             trailing: Icon(Icons.arrow_forward),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       StudentListForIDCard(collegecode: widget.collegecode),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dgadmin/Admin/Others/assignsubject.dart';
import 'package:dgadmin/Admin/Others/idcard.dart';
import 'package:dgadmin/base.dart';

class OthersDash extends StatefulWidget {
  final String collegecode;
  const OthersDash({super.key, required this.collegecode});

  @override
  State<OthersDash> createState() => _OthersDashState();
}

class _OthersDashState extends State<OthersDash> {

   final TextEditingController _classController = TextEditingController();
   final TextEditingController _divisionController = TextEditingController();

  int _selectedIndex = 0; // 0: Dashboard, 1: ID Card

  void _showIDCardScreen() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _showDashboard() {
    setState(() {
      _selectedIndex = 0;
    });
  }


 Future<void> _addClass() async {
    String className = _classController.text.trim();
    String division = _divisionController.text.trim();

    if (className.isEmpty || division.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all details")),
      );
      return;
    }

    final url = "$addClass?college_code=${widget.collegecode}";

    final body = jsonEncode({
      "standard": className,
      "division": division,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 &&
          responseData['message'] == "Class added successfully.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Class added: ID ${responseData['class_id']}")),
        );

        _classController.clear();
        _divisionController.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseData['message']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add class: $error")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Others Dashboard" : "ID Card"),
        leading: _selectedIndex == 1
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _showDashboard,
              )
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardView(),
          StudentListForIDCard(
            collegecode: widget.collegecode,
            onBack: _showDashboard, // Pass callback function to handle back
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.class_),
          title: const Text("Add Class"),
          subtitle: const Text("Add class and division"),
          trailing: const Icon(Icons.arrow_forward),
          onTap: _showAddClassDialog,
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.money),
          title: Text("Add Fee type"),
          subtitle: Text("Add fee type"),
          trailing: Icon(Icons.arrow_forward),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.subject),
          title: const Text("Assign subject to teacher"),
          subtitle: const Text("Assign subject to teacher"),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => showAssignSubjectDialog(context, widget.collegecode),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.card_membership),
          title: Text("ID Card"),
          subtitle: Text("ID Card"),
          trailing: Icon(Icons.arrow_forward),
          onTap: _showIDCardScreen, // Switch view instead of navigation
        ),
      ],
    );
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Class"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Class:", "Enter class name", TextEditingController()),
              _buildTextField("Division:", "Enter division", TextEditingController()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addClass();
                // Handle class addition logic
              },
              child: const Text("Add Class"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: hintText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
