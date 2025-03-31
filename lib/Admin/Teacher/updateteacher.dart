import 'dart:convert';
import 'dart:io';
import 'package:dgadmin/base.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateTeacher extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;
  final String teachercode;

  const UpdateTeacher({
    super.key,
    required this.collegecode,
    required this.collegename,
    required this.collegeimage,
    required this.teachercode,
  });

  @override
  State<UpdateTeacher> createState() => _UpdateTeacherState();
}

class _UpdateTeacherState extends State<UpdateTeacher> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  List<Map<String, String>> classes = [];
  List<String> standards = [];
  List<String> divisions = [];
  String? uploadedImageUrl;

  String? selectedStandard;
  String? selectedDivision;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchClasses().then((_) {
      fetchTeacherInfo(); // Ensures classes are available before fetching teacher data
    });
  }

  Future<void> fetchTeacherInfo() async {
    final url = Uri.parse(
        '$teacherinfo?teacher_code=${widget.teachercode}&college_code=${widget.collegecode}');

    try {
      final response = await http.get(url);
      final rawData = json.decode(response.body);
      final data = rawData is String ? json.decode(rawData) : rawData;

      if (data is Map<String, dynamic>) {
        setState(() {
          nameController.text = data['tname'] ?? '';
          emailController.text = data['teacher_email'] ?? '';
          mobileController.text = data['mobileno'] ?? '';
          dobController.text = data['date_of_birth']?.split('T')[0] ?? '';
          educationController.text = data['teacher_education'] ?? '';
          passwordController.text = data['tpassword'];
          confirmPasswordController.text = data['tpassword'];

          selectedStandard = data['stand'];
          selectedDivision = data['division'];
          uploadedImageUrl = data['teacher_profile'];

          print('Selected Standard: $selectedStandard');
          print('Selected Division: $selectedDivision');
          print("uplooadimaeurl: $uploadedImageUrl");

          if (selectedStandard != null) {
            divisions = classes
                .where((item) => item["standard"] == selectedStandard)
                .map((item) => item["division"]!)
                .toSet()
                .toList();

            print(
                'Available Divisions for Standard $selectedStandard: $divisions');

            if (!divisions.contains(selectedDivision)) {
              print('Resetting selectedDivision as it is not in the list');
              selectedDivision = null;
            }
          }

          print('Final Selected Division: $selectedDivision');
        });
      }
    } catch (e) {
      print('Error fetching teacher info: $e');
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$allClasses?college_code=${widget.collegecode}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          classes = data
              .map((item) => {
                    "standard": item["standard"].toString(),
                    "division": item["division"].toString()
                  })
              .toList();

          standards = classes.map((item) => item["standard"]!).toSet().toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load classes')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  /// Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      String? imageUrl = await _uploadImage(_profileImage!);

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    var uploadUrl = Uri.parse('http://195.35.45.44:5001/upload?folder=Student');
    var request = http.MultipartRequest('POST', uploadUrl);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.headers.addAll({"Content-Type": "multipart/form-data"});

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseBody);
        if (responseData['message'] == 'Image uploaded successfully') {
          String imageUrl = responseData['imageUrl'];

          if (!imageUrl.contains(":5001")) {
            imageUrl = imageUrl.replaceFirst(
                "http://195.35.45.44", "http://195.35.45.44:5001");
          }
          print(imageUrl);
          return imageUrl;
        }
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
    return null;
  }

  Future<void> updateTeacherDetails() async {
    print("Update Student");
    final url = Uri.parse(
        '$updateteacher/${widget.teachercode}?college_code=${widget.collegecode}');

    final Map<String, dynamic> requestBody = {
      "tname": nameController.text,
      "tpassword": passwordController.text,
      "mobileno": mobileController.text,
      "teacher_email": emailController.text,
      "teacher_profile": uploadedImageUrl ?? "", // Profile image URL
      "date_of_birth": dobController.text,
      "teacher_education": educationController.text,
      "collegeCode": widget.collegecode,
      "standard": selectedStandard,
      "division": selectedDivision,
    };
    print("Request body:------------------->");
    print(requestBody);
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );
      print(response.statusCode);
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update teacher')),
        );
      }
    } catch (e) {
      print('Error updating teacher details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating teacher')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.2;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 50),
                ClipOval(
                  child: Image.network(widget.collegeimage,
                      width: 100, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(width: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.collegename,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "College Code : ${widget.collegecode}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                    SizedBox(height: 10),

                   Align(
                    alignment: Alignment.topLeft, // Move to top right
                    child: CircleAvatar(
                      backgroundColor:
                          Colors.white, // Background color of the circle
                      radius: 24, // Adjust size as needed
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSection(
                    context,
                    'Teacher Details',
                    [
                      Column(
                        children: [
                          ClipOval(
                            child: uploadedImageUrl != null &&
                                    uploadedImageUrl!.isNotEmpty
                                ? Image.network(
                                    uploadedImageUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                          'Image Load Error: $error'); // Debugging
                                      return Image.asset(
                                        'assets/teacher.png', // Fallback if network image fails
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/teacher.png', // Default placeholder image
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.add_a_photo),
                            label: Text('Add Profile'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(context, 'Name:            ', 'Name',
                          controller: nameController),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                context, 'Email:            ', 'Email',
                                controller: emailController),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                                context, 'Mobile No:', 'Mobile No',
                                controller: mobileController),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  dobController.text =
                                      formattedDate; // Update the TextField with selected date
                                }
                              },
                              child: AbsorbPointer(
                                // Prevent manual text input
                                child: _buildTextField(
                                  context,
                                  'DOB:             ',
                                  'Date Of Birth',
                                  controller: dobController,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                                context, 'Education:', 'Education',
                                controller: educationController),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Class Teacher: ',
                            style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: _buildDropdown(
                              context,
                              'Standard',
                              standards,
                              value: selectedStandard,
                              onChanged: (value) {
                                setState(() {
                                  selectedStandard = value;
                                  selectedDivision =
                                      null; // Reset division when standard changes
                                  divisions = classes
                                      .where(
                                          (item) => item["standard"] == value)
                                      .map((item) => item["division"]!)
                                      .toSet()
                                      .toList();
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              context,
                              'Division',
                              divisions,
                              value: selectedDivision,
                              onChanged: (value) {
                                setState(() {
                                  selectedDivision = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSection(
                    context,
                    'Login Details',
                    [
                      Column(
                        
                        children: [
                           SizedBox(height: 10,),
                          Row(
                            children: [
                             
                              Expanded(
                                child: _buildTextField(
                                    context, 'Password:      ', 'Password',
                                    controller: passwordController,
                                    obscureText: false),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(context, 'Confirm Password:',
                                    'Confirm Password',
                                    controller: confirmPasswordController,
                                    obscureText: false),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: updateTeacherDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                                foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        textStyle: TextStyle(fontSize: screenWidth * 0.015),
                      ),
                      child: Text('Update',style: TextStyle(fontSize: 17),),
                    ),
                  ),
                        ],
                      ),
                    ],
                  ),
                  // SizedBox(height: 20),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: updateTeacherDetails,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blue,
                  //               foregroundColor: Colors.white,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  //       textStyle: TextStyle(fontSize: screenWidth * 0.02),
                  //     ),
                  //     child: Text('Update'),
                  //   ),
                  // ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.025,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String labelName,
      {bool obscureText = false,
      int maxLines = 1,
      TextEditingController? controller}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold), // Adjust font size as needed
        ),
        const SizedBox(width: 5), // Add some spacing between Text and TextField
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: labelName,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items,
      {String? value, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
