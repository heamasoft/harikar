import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// your existing menu widgets:
import '../widgets/custom_drawer.dart';
import '../widgets/footer_menu.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  bool _didFetch = false;

  @override
  void initState() {
    super.initState();
    // Only set up search listener here; don't fetch yet
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    try {
      final response = await http.get(
        Uri.parse('https://legaryan.heama-soft.com/get_users2.php'),
      );
      if (response.statusCode != 200) {
        throw Exception('Server responded ${response.statusCode}');
      }

      final jsonStr = utf8.decode(response.bodyBytes);
      final decoded = json.decode(jsonStr);

      if (decoded is Map && decoded['status'] == 'error') {
        throw Exception(decoded['message']);
      }
      if (decoded is! List) {
        throw Exception('Unexpected JSON: $decoded');
      }

      setState(() {
        _users = decoded.map<User>((e) => User.fromJson(e)).toList();
        _filteredUsers = List.from(_users);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'خطأ في تحميل المستخدمين: $e'
                : 'هەڵە لە بارکردنی بەکارهێنەرەکان: $e',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterUsers(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredUsers = List.from(_users));
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredUsers = _users.where((u) {
          return u.fullName.toLowerCase().contains(q) ||
              u.phoneNumber.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  void _showEditDialog(User user) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    final passCtrl = TextEditingController(text: user.password);

    bool isApprovedLocal = user.isApproved;
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(
              isArabic ? 'تعديل المستخدم' : 'دەستکاری بەکارهێنەر',
              style: TextStyle(fontFamily: 'NotoKufi'),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الاسم الكامل' : 'ناوی تەواو',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isArabic
                              ? 'يرجى إدخال الاسم'
                              : 'تکایە ناو بنووسە';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رقم الهاتف' : 'ژمارەی تەلەفون',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isArabic
                              ? 'يرجى إدخال رقم الهاتف'
                              : 'تکایە ژمارەی تەلەفون بنووسە';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: passCtrl,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'كلمة المرور' : 'وشەی تێپەڕەوە',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setModalState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isArabic
                              ? 'يرجى إدخال كلمة المرور'
                              : 'تکایە وشەی تێپەڕەوە بنووسە';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(
                        isArabic ? 'معتمد' : 'پەسەندکراو',
                        style: TextStyle(fontFamily: 'NotoKufi'),
                      ),
                      value: isApprovedLocal,
                      onChanged: (v) {
                        setModalState(() {
                          isApprovedLocal = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  isArabic ? 'إلغاء' : 'هەڵبگرەوە',
                  style: TextStyle(fontFamily: 'NotoKufi'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text(
                  isArabic ? 'تحديث' : 'نوێکردنەوە',
                  style: TextStyle(fontFamily: 'NotoKufi'),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  _updateUser(
                    user.id,
                    nameCtrl.text.trim(),
                    phoneCtrl.text.trim(),
                    passCtrl.text.trim(),
                    isApprovedLocal,
                    _formKey,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUser(
    int id,
    String name,
    String phone,
    String pass,
    bool approved,
    GlobalKey<FormState> formKey,
  ) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!formKey.currentState!.validate()) return;

    try {
      final res = await http.post(
        Uri.parse('https://legaryan.heama-soft.com/update_user2.php'),
        body: {
          'id': id.toString(),
          'full_name': name,
          'phone_number': phone,
          'password': pass,
          'is_approved': approved ? '1' : '0',
        },
      );
      final jsonRes = json.decode(utf8.decode(res.bodyBytes));
      if (jsonRes['status'] == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonRes['message'],
              style: TextStyle(fontFamily: 'NotoKufi'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        await _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تم التحديث بنجاح' : 'سەرکەوتووی نوێکرایەوە',
              style: TextStyle(fontFamily: 'NotoKufi'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'حدث خطأ ما' : 'هەڵەیەک ڕوویدا',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text(
            isArabic ? 'المستخدمون' : 'بەکارهێنەرەکان',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'NotoKufi',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                      hintText: isArabic
                          ? 'ابحث بالاسم أو رقم الهاتف'
                          : 'گەڕان بە ناو یان ژمارەی تەلەفون',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Colors.deepPurple),
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? Center(
                              child: Text(
                                isArabic
                                    ? 'لا يوجد مستخدمون'
                                    : 'هیچ بەکارهێنەرێک نیە',
                                style: TextStyle(
                                  fontFamily: 'NotoKufi',
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (_, i) {
                                final u = _filteredUsers[i];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showEditDialog(u),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            u.fullName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoKufi',
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.phone,
                                                  size: 16,
                                                  color: Colors.deepPurple),
                                              SizedBox(width: 6),
                                              Text(u.phoneNumber),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.lock,
                                                  size: 16,
                                                  color: Colors.deepPurple),
                                              SizedBox(width: 6),
                                              Text(u.password),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            '${isArabic ? 'معتمد' : 'پەسەندکراو'}: ' +
                                                (u.isApproved
                                                    ? (isArabic
                                                        ? 'نعم'
                                                        : 'بەڵێ')
                                                    : (isArabic
                                                        ? 'لا'
                                                        : 'نەخێر')),
                                            style: TextStyle(
                                              color: u.isApproved
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontFamily: 'NotoKufi',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FooterMenu(selectedIndex: 2),
      ),
    );
  }
}

class User {
  final int id;
  final String fullName, phoneNumber, password;
  final bool isApproved;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> j) {
    final appr = j['is_approved'];
    bool flag;
    if (appr is bool) {
      flag = appr;
    } else if (appr is num) {
      flag = appr == 1;
    } else {
      flag = appr.toString() == '1';
    }
    return User(
      id: int.parse(j['id'].toString()),
      fullName: j['full_name'],
      phoneNumber: j['phone_number'],
      password: j['password'],
      isApproved: flag,
    );
  }
}
