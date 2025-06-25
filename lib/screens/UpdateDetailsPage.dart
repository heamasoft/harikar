import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb

class UpdateDetailsPage extends StatefulWidget {
  final String detailId;

  UpdateDetailsPage({required this.detailId});

  @override
  _UpdateDetailsPageState createState() => _UpdateDetailsPageState();
}

class _UpdateDetailsPageState extends State<UpdateDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  // Dropdown Data
  List<dynamic> _subCategories = [];
  List<dynamic> _users = [];
  List<String> _cities = ['دهۆک', 'زاخۆ', 'سلێمانی', 'هەولێر'];

  // Selected Values
  String? _selectedSubCategory;
  String? _selectedUser;
  String? _selectedCity;
  bool _isActive = true;

  // Images
  List<String> _existingImages = [];
  List<dynamic> _newImages = []; // Can be File or Uint8List
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
    _fetchUsers();
    _fetchDetailData();
  }

  Future<void> _fetchSubCategories() async {
    final url =
        Uri.parse('https://legaryan.heama-soft.com/get_subcategories.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _subCategories = jsonDecode(response.body)['data'];
        });
      }
    } catch (e) {
      _showMessage("Failed to load subcategories.",
          success: false, arabicMessage: "فشل تحميل الفئات الفرعية.");
    }
  }

  Future<void> _fetchUsers() async {
    final url = Uri.parse('https://legaryan.heama-soft.com/get_users.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _users = jsonDecode(response.body)['data'];
        });
      }
    } catch (e) {
      _showMessage("Failed to load users.",
          success: false, arabicMessage: "فشل تحميل المستخدمين.");
    }
  }

  Future<void> _fetchDetailData() async {
    final url =
        Uri.parse('https://legaryan.heama-soft.com/get_detail_by_id.php');
    final response = await http.post(url, body: {'id': widget.detailId});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        _nameController.text = data['name'] ?? '';
        _contactController.text = data['contact_number'] ?? '';
        _locationController.text = data['location'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _additionalInfoController.text = data['additional_info'] ?? '';
        _isActive = (data['is_active']?.toString() == '1');
        _selectedSubCategory = data['sub_category_id']?.toString() ?? null;
        _selectedUser = data['user_id']?.toString() ?? null;

        // Set selected city if available
        if (_cities.contains(data['location'])) {
          _selectedCity = data['location'];
        } else {
          _selectedCity = null;
        }
        _existingImages = List<String>.from(data['images'] ?? []);
      });
    } else {
      _showMessage("Failed to load details.",
          success: false, arabicMessage: "فشل تحميل المعلومات.");
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      for (var xFile in pickedImages) {
        if (kIsWeb) {
          final bytes = await xFile.readAsBytes();
          setState(() {
            _newImages.add(bytes); // Add as Uint8List for web
          });
        } else {
          setState(() {
            _newImages.add(File(xFile.path));
          });
        }
      }
    }
  }

  void _removeExistingImage(String imageUrl) {
    setState(() => _existingImages.remove(imageUrl));
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final url = Uri.parse('https://legaryan.heama-soft.com/update_details.php');
    final request = http.MultipartRequest('POST', url);

    try {
      // Add form fields
      request.fields['id'] = widget.detailId;
      request.fields['sub_category_id'] = _selectedSubCategory ?? '';
      request.fields['user_id'] = _selectedUser ?? '';
      request.fields['name'] = _nameController.text.trim();
      request.fields['contact_number'] = _contactController.text.trim();
      request.fields['location'] = _selectedCity ?? '';
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['is_active'] = _isActive ? '1' : '0';
      request.fields['additional_info'] = _additionalInfoController.text.trim();
      request.fields['existing_images'] = jsonEncode(_existingImages);

      print("Request Fields: ${request.fields}");

      // Add new images if any
      for (var image in _newImages) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images[]',
              image,
              filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        } else if (image is File) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', image.path),
          );
        }
      }

      print("Sending update request...");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Response status: ${response.statusCode}");
      print("Response body: $responseBody");

      final responseData = jsonDecode(responseBody);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showMessage("Data updated successfully",
            success: true, arabicMessage: "تم تحديث المعلومات بنجاح");
        Navigator.pop(context); // Trigger return to previous screen
      } else {
        print("Server Error: ${responseData['message']}");
        _showMessage("Error: ${responseData['message']}",
            success: false, arabicMessage: "خطأ: ${responseData['message']}");
      }
    } catch (e, stackTrace) {
      print("Error occurred: $e");
      print("Stack Trace: $stackTrace");
      _showMessage("An error occurred: $e",
          success: false, arabicMessage: "حدث خطأ: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message,
      {bool success = false, String? arabicMessage}) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String displayMessage =
        isArabic && arabicMessage != null ? arabicMessage : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage, style: TextStyle(fontFamily: 'NotoKufi')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Wrap(
      spacing: 10,
      children: [
        // Existing Images (from server)
        ..._existingImages.map((url) => _buildImageItem(url, true)),
        // New Images (locally picked)
        ..._newImages.asMap().entries.map((entry) {
          int index = entry.key;
          var image = entry.value;
          return _buildImageItem(image, false, index: index);
        }),
      ],
    );
  }

  Widget _buildImageItem(dynamic image, bool isExisting, {int? index}) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isExisting
              ? Image.network(
                  "https://legaryan.heama-soft.com/uploads/$image",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : kIsWeb && image is Uint8List
                  ? Image.memory(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      image as File,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExisting) {
                _deleteExistingImage(image);
              } else if (index != null) {
                _removeNewImage(index);
              }
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
  }

  Future<void> _deleteExistingImage(String imageUrl) async {
    final url = Uri.parse('https://legaryan.heama-soft.com/delete_image.php');
    try {
      final response = await http.post(url, body: {'image_url': imageUrl});
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _existingImages.remove(imageUrl);
        });
        _showMessage("Image deleted successfully",
            success: true, arabicMessage: "تم حذف الصورة بنجاح");
      } else {
        _showMessage("Error deleting image: ${responseData['message']}",
            arabicMessage: "خطأ في حذف الصورة: ${responseData['message']}");
      }
    } catch (e) {
      _showMessage("Error occurred while deleting: $e",
          arabicMessage: "حدث خطأ أثناء الحذف: $e");
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty
          ? (isArabic ? "هذا الحقل مطلوب" : "پێویستە پر بکرێتەوە")
          : null,
    );
  }

  Widget _buildRadioButtons() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? "هل هو مفعل؟" : "ئایا چالاکە؟",
          style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _isActive,
              onChanged: (value) => setState(() => _isActive = value!),
            ),
            Text(isArabic ? "نعم" : "بەڵێ",
                style: TextStyle(fontFamily: 'NotoKufi')),
            SizedBox(width: 20),
            Radio<bool>(
              value: false,
              groupValue: _isActive,
              onChanged: (value) => setState(() => _isActive = value!),
            ),
            Text(isArabic ? "لا" : "نەخێر",
                style: TextStyle(fontFamily: 'NotoKufi')),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionAndAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? "الوصف"
              : "وەسف",
          style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
        ),
        SizedBox(height: 8),
        _buildTextField(
            _descriptionController,
            Localizations.localeOf(context).languageCode == 'ar'
                ? "الوصف"
                : "وەسف",
            maxLines: 3),
        SizedBox(height: 15),
        Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? "معلومات إضافية (اختياري)"
              : "زانیاری زیاتر (اختیاری)",
          style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _additionalInfoController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: Localizations.localeOf(context).languageCode == 'ar'
                ? "معلومات إضافية (اختياري)"
                : "زانیاری زیاتر (اختیاری)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items, String? value,
      Function(String?) onChanged) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'].toString(),
          child: Text(
            item['name'] ?? item['full_name'] ?? '',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null
          ? (isArabic ? "هذا الحقل مطلوب" : "پێویستە $label هەڵبژێردرێت")
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl, // Ensures RTL layout
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurple,
          title: Text(
            isArabic ? "تحديث المعلومات" : "نوێکردنەوەی زانیاری",
            style: TextStyle(
              fontFamily: 'NotoKufi',
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subcategory Dropdown
                  _buildDropdown(
                    isArabic ? "نوع الفئة الفرعية" : "جۆری ژێرپۆل",
                    _subCategories,
                    _selectedSubCategory,
                    (value) => setState(() => _selectedSubCategory = value),
                  ),
                  SizedBox(height: 15),
                  // User Dropdown
                  _buildDropdown(
                    isArabic ? "المستخدم" : "بەکارهێنەر",
                    _users,
                    _selectedUser,
                    (value) => setState(() => _selectedUser = value),
                  ),
                  SizedBox(height: 15),
                  // Name Text Field
                  _buildTextField(_nameController,
                      isArabic ? "اسم المعلومات" : "ناوی زانیاری"),
                  SizedBox(height: 15),
                  // Phone Number Text Field
                  _buildTextField(_contactController,
                      isArabic ? "رقم الاتصال" : "ژمارەی پەیوەندیدان"),
                  SizedBox(height: 15),
                  // Location Dropdown
                  _buildDropdown(
                    isArabic ? "الموقع" : "شوێن",
                    _cities.map((city) => {"id": city, "name": city}).toList(),
                    _selectedCity,
                    (value) => setState(() => _selectedCity = value),
                  ),
                  SizedBox(height: 15),
                  // Radio Buttons for Active/Inactive
                  _buildRadioButtons(),
                  SizedBox(height: 15),
                  // Description and Additional Info
                  _buildDescriptionAndAdditionalInfo(),
                  SizedBox(height: 15),
                  // Image Preview Section
                  _buildImagePreview(),
                  SizedBox(height: 15),
                  // Button to Add Images
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.add_a_photo, color: Colors.white),
                    label: Text(
                      isArabic ? "أضف صوراً" : "وێنە زیاد بکە",
                      style: TextStyle(
                          fontFamily: 'NotoKufi', color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Update Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isArabic ? "تحديث" : "نوێکردنەوە",
                            style: TextStyle(
                              fontFamily: 'NotoKufi',
                              color: Colors.white,
                              fontSize: 18,
                            ),
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
