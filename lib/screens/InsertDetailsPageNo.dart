import 'dart:convert';
import 'dart:io';
import 'package:Harikar/screens/save_success_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import Provider

import '../widgets/custom_drawer.dart'; // Updated to use Provider
import '../models/user_model.dart'; // Import UserModel

class InsertDetailsPageNo extends StatefulWidget {
  final String? phoneNumber;
  final String? city;

  InsertDetailsPageNo({this.phoneNumber, this.city});

  @override
  _InsertDetailsPageNoState createState() => _InsertDetailsPageNoState();
}

class _InsertDetailsPageNoState extends State<InsertDetailsPageNo> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  // Dropdown Data
  List<dynamic> _subCategories = [];
  List<dynamic> _users = [];
  // Define cities in Kurdish; you can adjust Arabic names if needed
  List<String> _cities = ['دهۆک', 'زاخۆ', 'سلێمانی', 'هەولێر'];

  // Selected Values
  String? _selectedSubCategory;
  String? _selectedUser;
  String? _selectedCity;

  // Image Picker
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _selectedImages = []; // Accept both File and Uint8List
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
    _fetchUsers();

    // Pre-fill phone number and city from the passed data
    _contactController.text = widget.phoneNumber ?? '';
    _selectedCity = widget.city;
  }

  Future<void> _fetchSubCategories() async {
    final url =
        Uri.parse('https://legaryan.heama-soft.com/get_subcategories.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _subCategories = responseData['data'];
          });
        } else {
          _showMessage("Failed to load subcategories.",
              success: false, arabicMessage: "فشل تحميل الفئات الفرعية.");
        }
      }
    } catch (e) {
      _showMessage("Failed to load subcategories.",
          success: false, arabicMessage: "فشل تحميل الفئات الفرعية.");
    }
  }

  Future<void> _fetchUsers() async {
    // Set limit=0 to fetch all users
    final url =
        Uri.parse('https://legaryan.heama-soft.com/get_users.php?limit=0');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _users = responseData['data'];
          });
          // After fetching users, set the selected user based on Provider's UserModel
          _setSelectedUser();
        } else {
          _showMessage("Failed to load users.",
              success: false, arabicMessage: "فشل تحميل المستخدمين.");
        }
      } else {
        _showMessage("Failed to load users.",
            success: false, arabicMessage: "فشل تحميل المستخدمين.");
      }
    } catch (e) {
      _showMessage("Failed to load users.",
          success: false, arabicMessage: "فشل تحميل المستخدمين.");
    }
  }

  void _setSelectedUser() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final currentUserName = userModel.name.trim().toLowerCase();

    print(
        "InsertDetailsPageNo: Current user name from UserModel: '$currentUserName'");

    // Find the user in the _users list that matches the current user's name
    final matchedUser = _users.firstWhere(
        (user) =>
            (user['name']?.toString().trim().toLowerCase() ==
                currentUserName) ||
            (user['full_name']?.toString().trim().toLowerCase() ==
                currentUserName),
        orElse: () => null);

    if (matchedUser != null) {
      setState(() {
        _selectedUser = matchedUser['id'].toString();
      });
      print(
          "InsertDetailsPageNo: Matched user found. _selectedUser set to ${_selectedUser}");
    } else {
      print(
          "InsertDetailsPageNo: No matching user found. _selectedUser remains null.");
      // Show message in current locale
      _showMessage(
          "ناتوانین بەکارھێنەرەکەی خۆکار هەڵبژێرین. تکایە دەست خۆ بگرە.",
          success: false,
          arabicMessage:
              "لم نستطع اختيار المستخدم تلقائيًا. يرجى تسجيل الدخول مرة أخرى.");
    }
  }

  Future<void> _insertData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showMessage("پێویستە بەلایەنی کەم یەک وێنە هەڵبژێردرێت",
          success: false, arabicMessage: "يجب اختيار صورة واحدة على الأقل");
      return;
    }

    setState(() => _isSubmitting = true);

    final url = Uri.parse('https://legaryan.heama-soft.com/insert_details.php');
    final request = http.MultipartRequest('POST', url);

    // Add form fields
    request.fields['sub_category_id'] = _selectedSubCategory ?? '';
    request.fields['user_id'] = _selectedUser ?? '';
    request.fields['name'] = _nameController.text.trim();
    request.fields['contact_number'] = _contactController.text.trim();
    request.fields['location'] = _selectedCity ?? '';
    request.fields['description'] = _descriptionController.text.trim();
    request.fields['is_active'] = '1'; // Always send '1' (active)
    request.fields['additional_info'] = _additionalInfoController.text.trim();

    try {
      // Add images
      for (var image in _selectedImages) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images[]',
              image,
              filename:
                  DateTime.now().millisecondsSinceEpoch.toString() + '.jpg',
            ),
          );
        } else if (image is File) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              image.path,
            ),
          );
        }
      }

      print("InsertDetailsPageNo: Request Fields: ${request.fields}");
      print("InsertDetailsPageNo: Sending data to server...");
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      print("InsertDetailsPageNo: Response Status: ${response.statusCode}");
      print("InsertDetailsPageNo: Response Body: $responseString");

      final responseData = jsonDecode(responseString);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SaveSuccessPage(),
          ),
        );
      } else {
        String errorMessage = "هەڵە: ${responseData['message']}";
        if (responseData['image_errors'] != null) {
          errorMessage += "\nImage Errors: " +
              (responseData['image_errors'] as List).join(', ');
        }
        _showMessage(errorMessage, success: false, arabicMessage: errorMessage);
      }
    } catch (e, stackTrace) {
      print("InsertDetailsPageNo: Error: $e");
      print("InsertDetailsPageNo: Stack Trace: $stackTrace");
      _showMessage("هەڵەیەک ڕوویدا: $e",
          success: false, arabicMessage: "حدث خطأ: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      if (images.length + _selectedImages.length > 3) {
        _showMessage("تکایە زیاتر لە ٣ وێنە نەهەڵبژێرە",
            success: false, arabicMessage: "يرجى عدم اختيار أكثر من 3 صور");
      } else {
        for (var xFile in images) {
          if (kIsWeb) {
            // For Web: Convert XFile to Uint8List
            final bytes = await xFile.readAsBytes();
            setState(() {
              _selectedImages.add(bytes); // Add as Uint8List
            });
          } else {
            // For Mobile: Add File
            setState(() {
              _selectedImages.add(File(xFile.path));
            });
          }
        }
      }
    }
  }

  void _showMessage(String message,
      {bool success = false, String? arabicMessage}) {
    // If an Arabic message is provided and current language is Arabic, use it.
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String displayMessage =
        isArabic && arabicMessage != null ? arabicMessage : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          displayMessage,
          style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Wrap(
      spacing: 10,
      children: _selectedImages.isEmpty
          ? [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ]
          : _selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              var imageFile = entry.value;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.memory(
                            imageFile,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            imageFile,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              );
            }).toList(),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? "اختر الصور (الحد الأقصى 3 صور)"
              : "وێنەکان هەڵبژێرە (ماکسیمە ٣ وێنە)",
          style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.add_a_photo, color: Colors.white),
          label: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? "اختر الصور"
                : "وێنە هەڵبژێرە",
            style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 10),
        _buildImagePreview(),
        if (_selectedImages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? "يجب اختيار صورة واحدة على الأقل"
                  : "پێویستە بەلایەنی کەم یەک وێنە هەڵبژێردرێت",
              style: TextStyle(color: Colors.red, fontFamily: 'NotoKufi'),
            ),
          ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items, String? value,
      Function(String?) onChanged,
      {bool enabled = true}) {
    return Scrollbar(
      thumbVisibility: true, // Always show the scrollbar
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item['id'].toString(),
                  child: Text(item['name'] ?? item['full_name']),
                ))
            .toList(),
        onChanged: enabled ? onChanged : null, // Disable if enabled is false
        validator: (value) =>
            value == null ? "پێویستە $label هەڵبژێردرێت" : null,
        dropdownColor: Colors.white,
        isExpanded: true,
        menuMaxHeight: 300, // Set a maximum height for the dropdown menu
        itemHeight: 50, // Set a fixed height for each item
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((item) {
            return Container(
              alignment: Alignment.centerRight,
              child: Text(
                item['name'] ?? item['full_name'],
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
            isArabic
                ? "إدخال المعلومات الجديدة (غير مفعل)"
                : 'زیادکردنی زانیاری نوێ (چالاک نەکراو)',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'NotoKufi',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: CustomDrawer(), // Updated: Removed userName and phoneNumber
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown(isArabic ? "نوع الفئة الفرعية" : "جۆری ژێرپۆل",
                      _subCategories, _selectedSubCategory, (value) {
                    setState(() => _selectedSubCategory = value);
                  }),
                  SizedBox(height: 15),
                  _buildDropdown(
                    isArabic ? "المستخدم" : "بەکارهێنەر",
                    _users,
                    _selectedUser,
                    (value) {
                      setState(() => _selectedUser = value);
                    },
                    enabled: false, // Disable the dropdown
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? "اسم المعلومات" : "ناوی زانیاری",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? (isArabic ? "هذا الحقل مطلوب" : "پێویستە پر بکرێتەوە")
                        : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText:
                          isArabic ? "رقم الاتصال" : "ژمارەی پەیوەندیدان",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isArabic
                            ? "هذا الحقل مطلوب"
                            : "پێویستە ژمارەکە بنووسرێت";
                      } else if (value.length < 10 || value.length > 15) {
                        return isArabic
                            ? "يجب أن يكون الرقم بين 10 و15 رقم"
                            : "ژمارەکە دەبێت لانی کەم ١٠ ڕەقەم بێت و زۆرتر نەبێت لە ١٥";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  _buildDropdown(
                    isArabic ? "الموقع" : "شوێن",
                    _cities.map((city) {
                      return {"id": city, "name": city};
                    }).toList(),
                    _selectedCity,
                    (value) {
                      setState(() => _selectedCity = value);
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: isArabic ? "الوصف" : "وەسف",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isArabic
                            ? "هذا الحقل مطلوب"
                            : "پێویستە وەسف بنووسرێت";
                      } else if (value.length < 10) {
                        return isArabic
                            ? "يجب أن يكون الوصف على الأقل 10 أحرف"
                            : "پێویستە وەسف لانی کەم ١٠ پیت بێت";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _additionalInfoController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isArabic
                          ? "معلومات إضافية (اختياري)"
                          : "زانیاری زیاتر (اختیاری)",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildUploadSection(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _isSubmitting ? null : _insertData,
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isArabic ? "إدخال" : "زیادکردن",
                            style: TextStyle(
                                fontFamily: 'NotoKufi',
                                color: Colors.white,
                                fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
