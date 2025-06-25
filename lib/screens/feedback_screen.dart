// lib/screens/feedback_screen.dart

import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import 'dashboard_screen.dart'; // Import the DashboardScreen

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _phoneNumber = '';
  String _message = '';

  bool _isSubmitting = false;
  bool _showSuccessMessage = false; // New state variable

  final FeedbackService _feedbackService = FeedbackService();

  // Method to handle form submission
  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true;
        _showSuccessMessage = false; // Reset success message on new submission
      });

      // Submit feedback via the service
      Map<String, dynamic> response =
          await _feedbackService.submitFeedback(_name, _phoneNumber, _message);

      setState(() {
        _isSubmitting = false;
      });

      // Determine the locale for feedback text
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';

      if (response['status'] == 'success') {
        setState(() {
          _showSuccessMessage = true; // Show success message
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? "تم إرسال ملاحظاتك بنجاح!"
                  : "فیدبەکەت بە سەرکەوتوویی نێردرا!",
              style: TextStyle(fontFamily: 'NotoKufi'),
            ),
          ),
        );
        _formKey.currentState!.reset();
      } else {
        // If the message is an array (multiple errors), join them into a single string
        String errorMessage = response['message'] is List
            ? (response['message'] as List).join(' ')
            : response['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(errorMessage, style: TextStyle(fontFamily: 'NotoKufi')),
          ),
        );
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
    // Alternatively, use named routes if set up:
    // Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current language
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // Obtain screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl, // Enforce RTL
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            isArabic ? "الإبلاغ" : 'سکالا',
            style: TextStyle(
              fontFamily: 'NotoKufi',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.blueAccent.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                _buildHeaderSection(screenWidth, isArabic),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(child: _buildForm(isArabic)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Section similar to DashboardScreen
  Widget _buildHeaderSection(double screenWidth, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo2.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic ? "صفحة الإبلاغ" : 'پەڕەی سکالا',
              style: TextStyle(
                fontFamily: 'NotoKufi',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Feedback Form
  Widget _buildForm(bool isArabic) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          _buildTextField(
            label: isArabic ? "الاسم" : 'ناو',
            icon: Icons.person,
            validatorMessage:
                isArabic ? "يرجى إدخال اسمك" : "تکایە ناوی خۆت بنووسە",
            keyboardType: TextInputType.name,
            onSaved: (value) {
              _name = value!.trim();
            },
          ),
          SizedBox(height: 20),

          // Phone Number Field
          _buildTextField(
            label: isArabic ? "رقم الجوال" : 'ژمارەی مۆبایل',
            icon: Icons.phone,
            validatorMessage: isArabic
                ? "يرجى إدخال رقم الجوال"
                : "تکایە ژمارەی مۆبایل بنووسە",
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isArabic
                    ? "يرجى إدخال رقم الجوال"
                    : "تکایە ژمارەی مۆبایل بنووسە";
              }
              if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.trim())) {
                return isArabic
                    ? "يرجى إدخال رقم جوال صحيح"
                    : "ژمارەی مۆبایل دروست بنووسە";
              }
              return null;
            },
            onSaved: (value) {
              _phoneNumber = value!.trim();
            },
          ),
          SizedBox(height: 20),

          // Message Field
          _buildTextField(
            label: isArabic ? "الرسالة" : 'پەیام',
            icon: Icons.message,
            validatorMessage:
                isArabic ? "يرجى إدخال رسالتك" : "تکایە پەیامەکەت بنووسە",
            maxLines: 5,
            onSaved: (value) {
              _message = value!.trim();
            },
          ),
          SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isArabic ? "إرسال" : 'ناردن',
                      style: TextStyle(
                        fontFamily: 'NotoKufi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20),

          // Success Message Card
          if (_showSuccessMessage)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isArabic
                                ? "شكراً لملاحظاتك. سنعمل على حل المشكلة وسنتواصل معك في أقرب وقت."
                                : "سوپاس بۆ فیدبەکەتان. ئێمە کێشەکە چارەسەر دەکەین و لە زووترین کاتدا پەیوەندیمان پێ دەکات.",
                            style: TextStyle(
                              fontFamily: 'NotoKufi',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Back to Dashboard Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          isArabic
                              ? "العودة إلى الرئيسية"
                              : 'گڕانەوە بۆ سەرەکی',
                          style: TextStyle(
                            fontFamily: 'NotoKufi',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Reusable Text Field Widget
  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    required String validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMessage;
            }
            return null;
          },
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      style: TextStyle(
        fontFamily: 'NotoKufi',
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}
