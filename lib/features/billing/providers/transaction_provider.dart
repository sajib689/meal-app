import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/transaction_model.dart';
import 'package:dio/dio.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions({bool isAdmin = false, DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().substring(0, 10);
        queryParams['endDate'] = endDate.toIso8601String().substring(0, 10);
      }

      final path = isAdmin ? '/transaction/all' : '/transaction/my-transactions';
      final response = await _apiService.get(path, queryParameters: queryParams);
      if (response.statusCode == 200) {
        _transactions = (response.data as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      print("Fetch Transactions Error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deposit(String userId, double amount, String description) async {
    try {
      final response = await _apiService.post('/auth/deposit', data: {
        'userId': userId,
        'amount': amount,
        'description': description,
      });
      if (response.statusCode == 200) {
        await fetchTransactions();
        return true;
      }
    } on DioError catch (e) {
      print("Deposit Error: ${e.response?.data}");
    }
    return false;
  }
}
