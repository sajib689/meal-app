import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/bazar_model.dart';
import 'package:dio/dio.dart';

class BazarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<BazarModel> _bazars = [];
  bool _isLoading = false;

  List<BazarModel> get bazars => _bazars;
  bool get isLoading => _isLoading;

  Future<void> fetchBazarHistory({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().substring(0, 10);
        queryParams['endDate'] = endDate.toIso8601String().substring(0, 10);
      }

      final response = await _apiService.get('/bazar/all', queryParameters: queryParams);
      if (response.statusCode == 200) {
        _bazars = (response.data as List)
            .map<BazarModel>((json) => BazarModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch Bazar Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveBazar(String id) async {
    try {
      final response = await _apiService.patch('/bazar/approve/$id');
      if (response.statusCode == 200) {
        await fetchBazarHistory();
        return true;
      }
    } on DioError catch (e) {
      print("Approve Bazar Error: ${e.response?.data}");
    }
    return false;
  }

  Future<bool> deleteBazar(String id) async {
    try {
      final response = await _apiService.delete('/bazar/$id');
      if (response.statusCode == 200) {
        await fetchBazarHistory();
        return true;
      }
    } on DioError catch (e) {
      print("Delete Bazar Error: ${e.response?.data}");
    }
    return false;
  }

  Future<bool> addBazar(List<String> items, double totalCost, String date, String description) async {
    try {
      final response = await _apiService.post('/bazar/add', data: {
        'items': items,
        'totalCost': totalCost,
        'date': date,
        'description': description,
      });
      if (response.statusCode == 201) {
        await fetchBazarHistory();
        return true;
      }
    } on DioError catch (e) {
      print("Add Bazar Error: ${e.response?.data}");
    }
    return false;
  }
}
