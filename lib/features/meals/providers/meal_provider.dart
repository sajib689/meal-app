import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/meal_model.dart';
import 'package:dio/dio.dart';

class MealProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<MealModel> _meals = [];
  bool _isLoading = false;

  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;

  Future<void> fetchMyMeals({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().substring(0, 10);
        queryParams['endDate'] = endDate.toIso8601String().substring(0, 10);
      }

      final response = await _apiService.get('/meal/my-meals', queryParameters: queryParams);
      if (response.statusCode == 200) {
        _meals = (response.data as List)
            .map<MealModel>((json) => MealModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch My Meals Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllMeals({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().substring(0, 10);
        queryParams['endDate'] = endDate.toIso8601String().substring(0, 10);
      }

      final response = await _apiService.get('/meal/all', queryParameters: queryParams);
      if (response.statusCode == 200) {
        _meals = (response.data as List)
            .map<MealModel>((json) => MealModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch All Meals Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addOrUpdateMeal(String date, double breakfast, double lunch, double dinner, {String? userId}) async {
    try {
      final response = await _apiService.post('/meal/add', data: {
        'date': date,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
        if (userId != null) 'userId': userId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyMeals();
        return true;
      }
    } on DioError catch (e) {
      print("Add/Update Meal Error: ${e.response?.data}");
    }
    return false;
  }

  Future<bool> deleteMeal(String id) async {
    try {
      final response = await _apiService.delete('/meal/$id');
      if (response.statusCode == 200) {
        await fetchMyMeals();
        return true;
      }
    } on DioError catch (e) {
      print("Delete Meal Error: ${e.response?.data}");
    }
    return false;
  }

  Future<Map<String, dynamic>?> getMonthlySummary(String month, String year) async {
    try {
      final response = await _apiService.get('/meal/summary', queryParameters: {
        'month': month,
        'year': year,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioError catch (e) {
      print("Get Monthly Summary Error: ${e.response?.data}");
    }
    return null;
  }

  Future<bool> updateMeal(String userId, String date, double breakfast, double lunch, double dinner) async {
    try {
      final response = await _apiService.post('/meal/update', data: {
        'userId': userId,
        'date': date,
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
      });
      if (response.statusCode == 200) {
        await fetchMyMeals();
        return true;
      }
    } on DioError catch (e) {
      print("Update Meal Error: ${e.response?.data}");
    }
    return false;
  }
}
