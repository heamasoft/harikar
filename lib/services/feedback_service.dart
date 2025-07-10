// // lib/services/feedback_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class FeedbackService {
//   final String apiUrl =
//       'https://legaryan.heama-soft.com/submit_feedback.php'; // Replace with your actual URL

//   Future<Map<String, dynamic>> submitFeedback(
//       String name, String phoneNumber, String message) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           'name': name,
//           'phone_number': phoneNumber,
//           'message': message,
//         }),
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         return responseData;
//       } else {
//         return {
//           "status": "error",
//           "message": "Server responded with status code ${response.statusCode}."
//         };
//       }
//     } catch (e) {
//       return {"status": "error", "message": "An error occurred: $e"};
//     }
//   }
// }
