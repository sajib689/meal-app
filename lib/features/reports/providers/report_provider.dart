import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/report_model.dart';
import 'package:dio/dio.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _dashboardStats = {};
  List<ReportModel> _reports = [];
  bool _isLoading = false;

  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/report/get-stats');
      if (response.statusCode == 200) {
        _dashboardStats = response.data;
      }
    } on DioError catch (e) {
      print("Fetch Stats Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/report/all');
      if (response.statusCode == 200) {
        _reports = (response.data as List)
            .map((json) => ReportModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch Reports Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> generateMonthlyReport(String month) async {
    try {
      final response = await _apiService.post('/report/generate', data: {
        'month': month,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchAllReports();
        return true;
      }
    } on DioError catch (e) {
      print("Generate Report Error: ${e.response?.data}");
    }
    return false;
  }
}
