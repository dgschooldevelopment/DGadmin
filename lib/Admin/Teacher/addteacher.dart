import 'package:dgadmin/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddTeacher extends StatefulWidget {
  final String collegecode;
  final String collegename;
  final String collegeimage;

  const AddTeacher(
      {super.key,
      required this.collegecode,
      required this.collegename,
      required this.collegeimage});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();

  List<Map<String, String>> classes = [];
  List<String> standards = [];
  List<String> divisions = [];
  String? uploadedImageUrl;




  String? selectedStandard;
  String? selectedDivision;

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

          // Extract unique standards
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

  // Function to submit the form data to the API
  Future<void> submitTeacherDetails() async {
    // Validate password and confirm password
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // Prepare request body
    final body = {
      "tname": nameController.text,
      "tpassword": passwordController.text,
      "mobileno": mobileController.text,
      "teacher_email": emailController.text,
      "teacher_profile": uploadedImageUrl ??
          "http://195.35.45.44:5001/images/Student/Default_image.png", // Use uploaded URL or dummy image
      "date_of_birth": dobController.text,
      "teacher_education": educationController.text,
      "standard": selectedStandard,
      "division": selectedDivision,
      "collegeCode": widget.collegecode,
    };

    print(body);

    try {
      final response = await http.post(
        Uri.parse('$addTeacher?college_code=${widget.collegecode}'),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );
      print(response.body);
      // Check response status
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
          clearFormFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add teacher: ${responseBody['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchClasses();
  }

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Upload the image and get the URL
      String? imageUrl = await _uploadImage(_profileImage!);

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl; // Store the uploaded image URL
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

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
    });

    print('Uploading image...');

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody'); // Debug response

      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseBody);
        if (responseData['message'] == 'Image uploaded successfully') {
          String imageUrl = responseData['imageUrl'];

          // Check if the returned URL is missing port 5001
          if (!imageUrl.contains(":5001")) {
            imageUrl = imageUrl.replaceFirst(
                "http://195.35.45.44", "http://195.35.45.44:5001");
          }

          print('Corrected Image URL: $imageUrl');
          return imageUrl;
        } else {
          print('Server returned error: ${responseData['message']}');
        }
      } else {
        print('Failed to upload image. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }

    return null;
  }

  void clearFormFields() {
    setState(() {
      nameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      mobileController.clear();
      emailController.clear();
      dobController.clear();
      educationController.clear();
      selectedStandard = null;
      selectedDivision = null;
      uploadedImageUrl = null;
      _profileImage = null;
    });
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
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipOval(
                    child: Image.network(
                      widget.collegeimage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  // SizedBox(height: 20),
                  // Profile Image & Add Profile Button
                  // Column(
                  //   children: [
                  //     ClipOval(
                  //       child: _profileImage != null
                  //           ? Image.file(
                  //               _profileImage!,
                  //               width: 120,
                  //               height: 120,
                  //               fit: BoxFit.cover,
                  //             )
                  //           : Image.asset(
                  //               'assets/teacher.png', // Default Image
                  //               width: 120,
                  //               height: 120,
                  //               fit: BoxFit.cover,
                  //             ),
                  //     ),
                  //     const SizedBox(height: 10),
                  //     ElevatedButton.icon(
                  //       onPressed: _pickImage,
                  //       icon: Icon(Icons.add_a_photo),
                  //       label: Text('Add Profile'),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.blue,
                  //         foregroundColor: Colors.white,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 20, vertical: 10),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 10),
                  _buildSection(
                    context,
                    'Teacher Details',
                    [
                      Column(
                        children: [
                          ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/teacher.png', // Default Image
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
                      _buildTextField(context, 'Name:           ', 'Name',
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

                          // Expanded(
                          //   child: _buildTextField(
                          //       context, 'DOB:             ', 'Date Of Birth',
                          //       controller: dobController),
                          // ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                                context, 'Education:', 'Education',
                                controller: educationController),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     Text(
                      //       'Class Teacher: ',
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Standard',
                      //         standards,
                      //         value: selectedStandard,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedStandard = value;
                      //             selectedDivision =
                      //                 null; // Reset division when standard changes
                      //             divisions = classes
                      //                 .where(
                      //                     (item) => item["standard"] == value)
                      //                 .map((item) => item["division"]!)
                      //                 .toSet()
                      //                 .toList();
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Division',
                      //         divisions,
                      //         value: selectedDivision,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedDivision = value;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     Text(
                      //       'Subjects:         ',
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Standard',
                      //         standards,
                      //         value: selectedStandard,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedStandard = value;
                      //             selectedDivision =
                      //                 null; // Reset division when standard changes
                      //             divisions = classes
                      //                 .where(
                      //                     (item) => item["standard"] == value)
                      //                 .map((item) => item["division"]!)
                      //                 .toSet()
                      //                 .toList();
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Division',
                      //         divisions,
                      //         value: selectedDivision,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedDivision = value;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Standard',
                      //         standards,
                      //         value: selectedStandard,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedStandard = value;
                      //             selectedDivision =
                      //                 null; // Reset division when standard changes
                      //             divisions = classes
                      //                 .where(
                      //                     (item) => item["standard"] == value)
                      //                 .map((item) => item["division"]!)
                      //                 .toSet()
                      //                 .toList();
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Division',
                      //         divisions,
                      //         value: selectedDivision,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedDivision = value;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Standard',
                      //         standards,
                      //         value: selectedStandard,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedStandard = value;
                      //             selectedDivision =
                      //                 null; // Reset division when standard changes
                      //             divisions = classes
                      //                 .where(
                      //                     (item) => item["standard"] == value)
                      //                 .map((item) => item["division"]!)
                      //                 .toSet()
                      //                 .toList();
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildDropdown(
                      //         context,
                      //         'Division',
                      //         divisions,
                      //         value: selectedDivision,
                      //         onChanged: (value) {
                      //           setState(() {
                      //             selectedDivision = value;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSection(
                    context,
                    'Login Details',
                    [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    context, 'Password:      ', 'Password',
                                    controller: passwordController,
                                    obscureText: true),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(context,
                                    'Confirm Password:', 'Confirm Password',
                                    controller: confirmPasswordController,
                                    obscureText: true),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: submitTeacherDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
  
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                textStyle:
                                    TextStyle(fontSize: screenWidth * 0.015),
                              ),
                              child: Text('Submit',style: TextStyle(fontSize: 17),),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // SizedBox(height: 20),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: submitTeacherDetails,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blue,
                  //             foregroundColor: Colors.white,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  //       textStyle: TextStyle(fontSize: screenWidth * 0.02),
                  //     ),
                  //     child: Text('Submit'),
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
        const SizedBox(width: 8), // Add some spacing between Text and TextField
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
