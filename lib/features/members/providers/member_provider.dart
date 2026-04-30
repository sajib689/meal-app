import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../auth/models/user_model.dart';
import 'package:dio/dio.dart';

class MemberProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<UserModel> _members = [];
  bool _isLoading = false;

  List<UserModel> get members => _members;
  bool get isLoading => _isLoading;

  Future<void> fetchMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/auth/users');
      if (response.statusCode == 200) {
        _members = (response.data as List).map<UserModel>((json) => UserModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Fetch Members Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateMemberStatus(String userId, String status) async {
    try {
        final response = await _apiService.put('/auth/users/$userId', data: {
            'status': status
        });
        if (response.statusCode == 200) {
            await fetchMembers();
            return true;
        }
    } catch (e) {
        debugPrint("Update Member Status Error: $e");
    }
    return false;
  }

  Future<bool> createMember(String name, String email, String password, String phone) async {
    try {
        final response = await _apiService.post('/auth/create-member', data: {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
            'role': 'member',
            'status': 'active'
        });
        if (response.statusCode == 201) {
            await fetchMembers();
            return true;
        }
    } catch (e) {
        debugPrint("Create Member Error: $e");
    }
    return false;
  }

  Future<bool> deleteUser(String userId) async {
    try {
        final response = await _apiService.delete('/auth/users/$userId');
        if (response.statusCode == 200) {
            await fetchMembers();
            return true;
        }
    } catch (e) {
        debugPrint("Delete User Error: $e");
    }
    return false;
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
        final response = await _apiService.post('/auth/users/$userId/reset-password', data: {
            'password': newPassword
        });
        if (response.statusCode == 200) {
            return true;
        }
    } catch (e) {
        debugPrint("Reset Password Error: $e");
    }
    return false;
  }
}
