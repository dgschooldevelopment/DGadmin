import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Dailyupdate extends StatefulWidget {
  final String teacherId;
  final String collegeCode;
  const Dailyupdate({super.key, required this.teacherId, required this.collegeCode});

  @override
  State<Dailyupdate> createState() => _DailyupdateState();
}

class _DailyupdateState extends State<Dailyupdate> {
  List<dynamic> scheduleData = [];

  @override
  void initState() {
    super.initState();
    fetchScheduleData();
  }

  Future<void> fetchScheduleData() async {
    final String apiUrl = "$getteacherdailyupdate?college_code=${widget.collegeCode}&teacher_code=${widget.teacherId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          scheduleData = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load schedule data");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;
    return Scaffold(
      body: scheduleData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView.builder(
                itemCount: scheduleData.length,
                itemBuilder: (context, index) {
                  var item = scheduleData[index];
                  return ScheduleCard(
                    date: item['date'],
                    className: "${item['stand']} - ${item['division']}",
                    subject: item['subject_name'],
                    time: item['time'],
                    title: item['chapter_name'],
                    content: List<String>.from(item['points']),
                  );
                },
              ),
          ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String date;
  final String className;
  final String subject;
  final String time;
  final String title;
  final List<String> content;

  const ScheduleCard({
    required this.date,
    required this.className,
    required this.subject,
    required this.time,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(date);
    TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(time.split(":")[0]),
      minute: int.parse(time.split(":")[1]),
    );

    String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
    String formattedTime = parsedTime.format(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Class - $className ',
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                Text(subject,
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            Text('★ $title',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content
                  .map((point) =>
                      Text('• $point', style: const TextStyle(fontSize: 16)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Dailyupdate extends StatefulWidget {
//   final String teacherId;
//   final String collegeCode;
//   const Dailyupdate(
//       {super.key, required this.teacherId, required this.collegeCode});

//   @override
//   State<Dailyupdate> createState() => _DailyupdateState();
// }

// class _DailyupdateState extends State<Dailyupdate> {
//   List<dynamic> scheduleData = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchScheduleData();
//   }

//   Future<void> fetchScheduleData() async {
//     final String apiUrl =
//         "http://195.35.45.44:3001/get_teacher_dailyupdate?college_code=${widget.collegeCode}&teacher_code=${widget.teacherId}";
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         setState(() {
//           scheduleData = json.decode(response.body);
//         });
//       } else {
//         throw Exception("Failed to load schedule data");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: scheduleData.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.5,
//               ),
//               itemCount: scheduleData.length,
//               itemBuilder: (context, index) {
//                 var item = scheduleData[index];
//                 return ScheduleCard(
//                   date: item['date'],
//                   className: "${item['stand']} - ${item['division']}",
//                   subject: item['subject_name'],
//                   time: item['time'],
//                   title: item['chapter_name'],
//                   content: List<String>.from(item['points']),
//                 );
//               },
//             ),
//     );
//   }
// }

// class ScheduleCard extends StatelessWidget {
//   final String date;
//   final String className;
//   final String subject;
//   final String time;
//   final String title;
//   final List<String> content;

//   const ScheduleCard({
//     required this.date,
//     required this.className,
//     required this.subject,
//     required this.time,
//     required this.title,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     DateTime parsedDate = DateTime.parse(date);
//     TimeOfDay parsedTime = TimeOfDay(
//       hour: int.parse(time.split(":")[0]),
//       minute: int.parse(time.split(":")[1]),
//     );

//     String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
//     String formattedTime = parsedTime.format(context);

//     double screenWidth = MediaQuery.of(context).size.width;

//     double padding = screenWidth * 0.2;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   formattedDate,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.normal, fontSize: 16),
//                 ),
//                 Text(
//                   formattedTime,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.normal, fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 5),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Class - $className ',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.normal, fontSize: 16)),
//                 Text(subject,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.normal, fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 15),
//             Text('★ $title',
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 15),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: content
//                   .map((point) =>
//                       Text('• $point', style: const TextStyle(fontSize: 16)))
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
