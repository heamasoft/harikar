// lib/screens/AdsManagementPage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SelectDetailPage.dart';
import '../widgets/footer_menu.dart'; // <-- add this

class AdsManagementPage extends StatefulWidget {
  @override
  _AdsManagementPageState createState() => _AdsManagementPageState();
}

class _AdsManagementPageState extends State<AdsManagementPage> {
  final String _fetchAdsUrl =
      'https://legaryan.heama-soft.com/fetch_slideshow_details.php';
  final String _updateAdsUrl =
      'https://legaryan.heama-soft.com/update_ads_status.php';

  List<Map<String, dynamic>> _ads = [];
  List<Map<String, dynamic>> _filteredAds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAds();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredAds = List.from(_ads);
      } else {
        _filteredAds = _ads.where((item) {
          final name = (item['name'] as String).toLowerCase();
          final phone = (item['contact_number'] as String).toLowerCase();
          return name.contains(q) || phone.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _fetchAds() async {
    setState(() => _isLoading = true);
    try {
      final resp = await http.get(Uri.parse(_fetchAdsUrl));
      final body = json.decode(resp.body);
      if (body['status'] == 'success') {
        var list = (body['data'] as List).cast<Map<String, dynamic>>();
        var adsList = list.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
            'contact_number': item['phone_number'] ?? '',
            'photo_url': item['photo_url'] ?? '',
          };
        }).toList();
        if (adsList.length > 5) adsList = adsList.sublist(0, 5);
        _ads = adsList;
        _filteredAds = List.from(_ads);
      } else {
        _ads = _filteredAds = [];
      }
    } catch (e) {
      print("Error fetching ads: $e");
      _ads = _filteredAds = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAd(String id) async {
    final resp = await http.post(
      Uri.parse(_updateAdsUrl),
      body: {'id': id, 'ads': '0'},
    );
    if (resp.statusCode == 200) {
      _fetchAds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete ad')),
      );
    }
  }

  void _confirmDelete(String id) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            isArabic ? 'تأكيد الحذف' : 'دڵنیابوون بۆ سڕینەوە',
            style: const TextStyle(fontFamily: 'NotoKufi'),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد حذف هذا الإعلان؟'
                : 'دڵنیایت بۆ سڕینەوەی ئەم ڕیکلامە؟',
            style: const TextStyle(fontFamily: 'NotoKufi'),
          ),
          actions: [
            TextButton(
              child: Text(
                isArabic ? 'إلغاء' : 'ڕەتکردنەوە',
                style: const TextStyle(fontFamily: 'NotoKufi'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                isArabic ? 'حذف' : 'سڕینەوە',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'NotoKufi',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAd(id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addAd() async {
    if (_ads.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot have more than 5 ads.')),
      );
      return;
    }
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => SelectDetailPage()),
    );
    if (result != null && result.containsKey('id')) {
      final detailId = result['id'].toString();
      final resp = await http.post(
        Uri.parse(_updateAdsUrl),
        body: {'id': detailId, 'ads': '1'},
      );
      if (resp.statusCode == 200)
        _fetchAds();
      else
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add ad')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final placeholder =
        isArabic ? 'ابحث بالاسم أو رقم الهاتف' : 'گەران بە ناو یان ژمارە';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.black45,
                  fontFamily: 'NotoKufi',
                ),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'NotoKufi',
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: _addAd,
              tooltip: isArabic ? 'إضافة إعلان' : 'زیادکردنی ڕیکلام',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredAds.isEmpty
                ? Center(
                    child: Text(
                      isArabic ? 'لا توجد إعلانات' : 'هیچ ڕیکلامێک نیە',
                      style:
                          const TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredAds.length,
                    itemBuilder: (ctx, i) {
                      final ad = _filteredAds[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ad['photo_url'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                width: 60,
                                height: 60,
                              ),
                            ),
                          ),
                          title: Text(
                            ad['name'],
                            style: const TextStyle(
                              fontFamily: 'NotoKufi',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            ad['contact_number'],
                            style: const TextStyle(fontFamily: 'NotoKufi'),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.redAccent,
                            onPressed: () => _confirmDelete(ad['id']),
                          ),
                        ),
                      );
                    },
                  ),
        bottomNavigationBar:
            FooterMenu(), // no args → selectedIndex defaults to –1
      ),
    );
  }
}
