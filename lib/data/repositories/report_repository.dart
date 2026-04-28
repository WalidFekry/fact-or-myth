import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService _apiService;

  ReportRepository(this._apiService);

  Future<Map<String, dynamic>> submitReport(ReportModel report) async {
    try {
      final response = await _apiService.post(
        '/submit-report',
        report.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
