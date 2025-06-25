// lib/screens/FeedbackPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_drawer.dart'; // Ensure this path is correct
import '../widgets/feedback_card.dart'; // Updated FeedbackCard with enhanced design

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // List to store fetched feedback entries
  List<Map<String, dynamic>> _feedbackEntries = [];

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Flag to ensure data is fetched only once
  bool _didFetchFeedback = false;

  @override
  void initState() {
    super.initState();
    // Remove data fetching from initState.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchFeedback) {
      _fetchFeedbackEntries();
      _didFetchFeedback = true;
    }
  }

  /// Fetches all feedback entries from the backend API
  Future<void> _fetchFeedbackEntries() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Construct the URL (no pagination parameters)
    final String url = 'https://legaryan.heama-soft.com/get_feedback.php';

    debugPrint("Fetching feedback from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<Map<String, dynamic>> fetchedFeedback =
              List<Map<String, dynamic>>.from(data['data']);

          setState(() {
            _feedbackEntries = fetchedFeedback;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ??
                (isArabic
                    ? 'فشل في تحميل الملاحظات.'
                    : 'هەڵە لە بارکردنی فیدباکەکان');
          });
        }
      } else {
        setState(() {
          _errorMessage = isArabic
              ? 'خطأ في النظام: ${response.statusCode}'
              : 'هەڵەی سیستەمی: ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint("Error fetching feedback: $e");
      setState(() {
        _errorMessage = isArabic
            ? 'حدث خطأ أثناء جلب الملاحظات.'
            : 'هەڵەیەک ڕوویدا لە هەڵگرتنی فیدباکەکان.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Deletes a feedback entry by ID
  Future<void> _deleteFeedback(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Confirm deletion with the user
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? "حذف" : "سڕینەوە",
              style: TextStyle(fontFamily: 'NotoKufi')),
          content: Text(
              isArabic
                  ? "هل أنت متأكد من حذف هذه الملاحظات؟"
                  : "دڵنیایە لە سڕینەوەی ئەم فیدباکە؟",
              style: TextStyle(fontFamily: 'NotoKufi')),
          actions: [
            TextButton(
              child: Text(isArabic ? "لا" : "نەخێر",
                  style: TextStyle(
                      color: Colors.deepPurple, fontFamily: 'NotoKufi')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(isArabic ? "نعم" : "بەڵێ",
                  style: TextStyle(
                      color: Colors.deepPurple, fontFamily: 'NotoKufi')),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String url = 'https://legaryan.heama-soft.com/delete_feedback.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      debugPrint("Delete API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Remove the deleted entry from the list
          setState(() {
            _feedbackEntries
                .removeWhere((entry) => entry['id'].toString() == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? "تم حذف الملاحظات." : "فیدباکەکە سڕایەوە.",
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              data['message'] ??
                  (isArabic ? "فشل حذف الملاحظات." : "سڕینەوەی فیدباکە ناکرێ."),
              style: TextStyle(fontFamily: 'NotoKufi'),
            )),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            isArabic
                ? "خطأ في النظام: ${response.statusCode}"
                : "هەڵەی سیستەمی: ${response.statusCode}",
            style: TextStyle(fontFamily: 'NotoKufi'),
          )),
        );
      }
    } catch (e) {
      debugPrint("Error deleting feedback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          isArabic ? "حدث خطأ أثناء حذف الملاحظات." : "هەڵەی سڕینەوەی فیدباکە",
          style: TextStyle(fontFamily: 'NotoKufi'),
        )),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigates to the details screen (if applicable)
  void _navigateToDetails(Map<String, dynamic> feedback) {
    // For now, show a dialog with feedback details
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            feedback['name'] ?? (isArabic ? "اسم المستخدم" : "ناوی بەکارهێنەر"),
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic
                    ? "رقم الهاتف: ${feedback['phone_number'] ?? 'غير متوفر'}"
                    : "ژمارەی مۆبایل: ${feedback['phone_number'] ?? 'نەدۆزرایەوە'}",
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
              SizedBox(height: 10),
              Text(
                isArabic ? "الرسالة:" : "پەیام:",
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
              SizedBox(height: 5),
              Text(
                feedback['message'] ??
                    (isArabic ? "الرسالة غير محددة" : "پەیام نادیارە"),
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                isArabic ? "إغلاق" : "داخستن",
                style: TextStyle(fontFamily: 'NotoKufi'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Builds individual feedback cards
  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return FeedbackCard(
      feedback: feedback,
      onDelete: () => _deleteFeedback(feedback['id'].toString()),
      onTap: () => _navigateToDetails(feedback),
    );
  }

  /// Builds the main content of the page
  Widget _buildContent() {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(
            fontFamily: 'NotoKufi',
            fontSize: 16,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_feedbackEntries.isEmpty) {
      return Center(
        child: Text(
          isArabic ? "لا توجد ملاحظات." : "هیچ فیدباکێک نەدۆزرایەوە.",
          style: TextStyle(
            fontFamily: 'NotoKufi',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _feedbackEntries.length,
        itemBuilder: (context, index) {
          final feedback = _feedbackEntries[index];
          return _buildFeedbackCard(feedback);
        },
      );
    }
  }

  /// Refreshes the feedback list (pull-to-refresh or after deletion)
  Future<void> _refreshFeedback() async {
    await _fetchFeedbackEntries();
  }

  @override
  Widget build(BuildContext context) {
    // Define the gradient for the AppBar
    final Gradient appBarGradient = LinearGradient(
      colors: [Colors.deepPurple, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl, // Enforce RTL direction
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? "الملاحظات" : "فیدباکەکان",
            style: TextStyle(
              fontFamily: 'NotoKufi',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: appBarGradient, // Apply gradient
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        endDrawer: CustomDrawer(),
        body: Column(
          children: [
            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshFeedback,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
