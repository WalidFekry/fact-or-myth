import 'package:flutter/material.dart';
import '../data/models/report_model.dart';
import '../data/repositories/report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _reportRepository;

  ReportViewModel(this._reportRepository);

  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<bool> submitReport(ReportModel report) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _reportRepository.submitReport(report);
      
      if (response['success'] == true) {
        _successMessage = response['message'] ?? 'تم إرسال البلاغ بنجاح';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'حدث خطأ أثناء إرسال البلاغ';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ في الاتصال. حاول مرة أخرى';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }
}
