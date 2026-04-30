import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/notice_model.dart';
import 'package:dio/dio.dart';

class NoticeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NoticeModel> _notices = [];
  bool _isLoading = false;

  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;

  Future<void> fetchNotices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/notice/all');
      if (response.statusCode == 200) {
        _notices = (response.data as List)
            .map<NoticeModel>((json) => NoticeModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch Notices Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteNotice(String id) async {
    try {
      final response = await _apiService.delete('/notice/$id');
      if (response.statusCode == 200) {
        await fetchNotices();
        return true;
      }
    } on DioError catch (e) {
      print("Delete Notice Error: ${e.response?.data}");
    }
    return false;
  }

  Future<bool> createNotice(String title, String content) async {
    try {
      final response = await _apiService.post('/notice/create', data: {
        'title': title,
        'content': content,
      });
      if (response.statusCode == 201) {
        await fetchNotices();
        return true;
      }
    } on DioError catch (e) {
      print("Create Notice Error: ${e.response?.data}");
    }
    return false;
  }
}
