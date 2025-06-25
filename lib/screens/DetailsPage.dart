// lib/screens/details_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_drawer.dart';
import 'UpdateDetailsPage.dart';

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<dynamic> _details = []; // Original data
  List<dynamic> _filteredDetails = []; // Filtered data
  List<String> _userNames = [];
  List<String> _subCategoryNames = [];

  String? _selectedUserName;
  String? _selectedSubCategory;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _didFetchDetails = false; // Flag to ensure data is fetched once

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    // Remove _fetchDetails() from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchDetails) {
      _fetchDetails();
      _didFetchDetails = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url = Uri.parse('https://legaryan.heama-soft.com/get_details.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _details = responseData['data'];
            _filteredDetails = _details;
            _extractDropdownOptions();
            _isLoading = false;
          });
        } else {
          _showMessage(isArabic
              ? "خطأ في تحميل المعلومات"
              : "هەڵە لە بارکردنی زانیاریەکان");
        }
      }
    } catch (e) {
      _showMessage(isArabic ? "حدث خطأ: $e" : "هەڵەیەک ڕوویدا: $e");
    }
  }

  void _extractDropdownOptions() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    _userNames = _details
        .map((item) =>
            item['user_name']?.toString() ??
            (isArabic ? "لا يوجد اسم مستخدم" : "ناوی بەکارهێنەر نییە"))
        .toSet()
        .toList()
        .cast<String>();

    _subCategoryNames = _details
        .map((item) =>
            item['sub_category_name']?.toString() ??
            (isArabic ? "غير محدد" : "نەدیارە"))
        .toSet()
        .toList()
        .cast<String>();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredDetails = _details.where((item) {
        final matchesUserName =
            _selectedUserName == null || item['user_name'] == _selectedUserName;
        final matchesSubCategory = _selectedSubCategory == null ||
            item['sub_category_name'] == _selectedSubCategory;
        final matchesSearch = query.isEmpty ||
            (item['name']?.toLowerCase()?.contains(query) ?? false) ||
            (item['user_name']?.toLowerCase()?.contains(query) ?? false);
        return matchesUserName && matchesSubCategory && matchesSearch;
      }).toList();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(fontFamily: 'NotoKufi')),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: isArabic
                  ? "البحث باسم المعلومات..."
                  : "گەڕان بەناوی زانیاری...",
              hintStyle:
                  TextStyle(color: Colors.white70, fontFamily: 'NotoKufi'),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white70),
            ),
            style: TextStyle(color: Colors.white, fontFamily: 'NotoKufi'),
            cursorColor: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: CustomDrawer(),
        backgroundColor: Colors.grey.shade100,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildFilters(isArabic),
                  Expanded(
                    child: _filteredDetails.isEmpty
                        ? Center(
                            child: Text(
                              isArabic ? "لا توجد معلومات" : "هیچ زانیاری نییە",
                              style: TextStyle(
                                  fontFamily: 'NotoKufi', fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: _filteredDetails.length,
                            itemBuilder: (context, index) {
                              return _buildModernDetailCard(
                                  _filteredDetails[index], isArabic);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilters(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedUserName,
              decoration: InputDecoration(
                labelText: isArabic
                    ? "البحث باسم المستخدم"
                    : "گەڕان بەناوی بەکارهێنەر",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    isArabic ? "جميع المستخدمين" : "هەموو بەکارهێنەران",
                    style: TextStyle(fontFamily: 'NotoKufi'),
                  ),
                ),
                ..._userNames.map((name) => DropdownMenuItem<String>(
                      value: name,
                      child:
                          Text(name, style: TextStyle(fontFamily: 'NotoKufi')),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUserName = value;
                  _applyFilters();
                });
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSubCategory,
              decoration: InputDecoration(
                labelText: isArabic
                    ? "البحث بنوع الفئة الفرعية"
                    : "گەڕان بە جۆری ژێرپۆل",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    isArabic ? "جميع الفئات الفرعية" : "هەموو ژێرپۆلەکان",
                    style: TextStyle(fontFamily: 'NotoKufi'),
                  ),
                ),
                ..._subCategoryNames.map((name) => DropdownMenuItem<String>(
                      value: name,
                      child:
                          Text(name, style: TextStyle(fontFamily: 'NotoKufi')),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSubCategory = value;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailCard(Map<String, dynamic> item, bool isArabic) {
    bool isActive = item['is_active'] == '1';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      child: Column(
        children: [
          // Header with User Name, Active Status, Delete, and Update Icons
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['user_name'] ??
                        (isArabic
                            ? "لا يوجد اسم مستخدم"
                            : "ناوی بەکارهێنەر نییە"),
                    style: TextStyle(
                      fontFamily: 'NotoKufi',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.greenAccent : Colors.redAccent,
                  size: 24,
                ),
                SizedBox(width: 8),
                // Update Icon
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateDetailsPage(detailId: item['id'].toString()),
                      ),
                    ).then((_) {
                      _fetchDetails(); // Reload details after update
                    });
                  },
                ),
                // Delete Icon
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () =>
                      _confirmDelete(item['id'].toString(), isArabic),
                ),
              ],
            ),
          ),
          // Body Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    Icons.category,
                    isArabic ? "نوع الفئة الفرعية" : "جۆری ژێرپۆل",
                    item['sub_category_name']),
                _buildDetailRow(
                    Icons.label, isArabic ? "الاسم" : "ناو", item['name']),
                _buildDetailRow(
                    Icons.phone,
                    isArabic ? "رقم الاتصال" : "ژمارەی پەیوەندی",
                    item['contact_number']),
                _buildDetailRow(Icons.location_on, isArabic ? "الموقع" : "شوێن",
                    item['location']),
                _buildDetailRow(Icons.description, isArabic ? "الوصف" : "وەسف",
                    item['description']),
                if (item['images'] != null &&
                    (item['images'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        isArabic ? "الصور:" : "وێنەکان:",
                        style: TextStyle(
                          fontFamily: 'NotoKufi',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildImageCarousel(item['images']),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? "حذف" : "سڕینەوە",
            style: TextStyle(fontFamily: 'NotoKufi')),
        content: Text(
          isArabic
              ? "هل أنت متأكد من حذف هذه المعلومات؟"
              : "دڵنیای کە ئەم زانیاریە بسڕیتەوە؟",
          style: TextStyle(fontFamily: 'NotoKufi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isArabic ? "لا" : "نەخێر",
                style: TextStyle(color: Colors.red, fontFamily: 'NotoKufi')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDetails(id, isArabic);
            },
            child: Text(isArabic ? "نعم" : "بەڵێ",
                style: TextStyle(color: Colors.green, fontFamily: 'NotoKufi')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDetails(String id, bool isArabic) async {
    final url = Uri.parse('https://legaryan.heama-soft.com/delete_details.php');
    try {
      final response = await http.post(url, body: {'id': id});
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        _showMessage(isArabic
            ? "تم حذف المعلومات بنجاح"
            : "زانیاری بە سەرکەوتوویی سڕاوە");
        _fetchDetails(); // Reload data after deletion
      } else {
        _showMessage(isArabic
            ? "خطأ في الحذف: ${responseData['message']}"
            : "هەڵە لە سڕینەوە: ${responseData['message']}");
      }
    } catch (e) {
      _showMessage(isArabic ? "حدث خطأ: $e" : "هەڵەیەک ڕوویدا: $e");
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontFamily: 'NotoKufi', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> imageUrls) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: 8),
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                    "https://legaryan.heama-soft.com/uploads/${imageUrls[index]}"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
