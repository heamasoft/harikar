// lib/widgets/feedback_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  FeedbackCard({
    required this.feedback,
    required this.onDelete,
    required this.onTap,
  });

  /// Generates initials from the user's name
  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    String initials = "";
    for (var part in names) {
      if (part.isNotEmpty) {
        initials += part[0];
      }
    }
    return initials.toUpperCase();
  }

  /// Formats the phone number for WhatsApp
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Remove leading zero if present
    if (cleanedNumber.startsWith('0')) {
      cleanedNumber = cleanedNumber.substring(1);
    }

    // Add Iraq country code
    String whatsappNumber = '964' + cleanedNumber;

    return whatsappNumber;
  }

  /// Launches WhatsApp with the formatted phone number
  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ژمارەی مۆبایل نادیارە')),
      );
      return;
    }

    String formattedNumber = _formatPhoneNumber(phoneNumber);

    // WhatsApp URL scheme
    Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    // Check if WhatsApp can be launched
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ئەم ژمارەیە لە WhatsApp بەردەست نیە')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic colors based on theme
    Color avatarBackground = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepPurpleAccent.shade700
        : Colors.deepPurpleAccent;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Avatar, Name, Phone, and Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarBackground,
                    child: Text(
                      feedback['name'].isNotEmpty
                          ? _getInitials(feedback['name'])
                          : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Name and Phone Number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['name'] ?? 'ناوی بەکارهێنەر',
                          style: TextStyle(
                            fontFamily: 'NotoKufi',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _launchWhatsApp(
                              context, feedback['phone_number']),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                feedback['phone_number'] ??
                                    'ژمارەی مۆبایل نادیارە',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 14,
                                  color: Colors.blueAccent, // Clickable color
                                  decoration: TextDecoration
                                      .underline, // Indicate clickable
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDelete,
                    tooltip: 'سڕینەوەی فیدباک',
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Feedback Message
              Text(
                feedback['message'] ?? 'پەیام نادیارە',
                style: TextStyle(
                  fontFamily: 'NotoKufi',
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              // Timestamp or Additional Info
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatTimestamp(feedback['timestamp']),
                  style: TextStyle(
                    fontFamily: 'NotoKufi',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats the timestamp into a readable format
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    DateTime parsedDate = DateTime.parse(timestamp);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
  }
}
