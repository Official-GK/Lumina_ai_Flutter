import re

with open('lib/services/api_service.dart', 'r') as f:
    content = f.read()

if "import '../models/job_model.dart';" not in content:
    content = content.replace("import 'package:http/http.dart' as http;", "import 'package:http/http.dart' as http;\nimport '../models/job_model.dart';")

new_func = """  Future<List<JobModel>> fetchRecommendedJobs({String skills = 'Flutter', String country = 'in'}) async {
    final headers = await _authHeaders();
    final res = await http
        .get(
          Uri.parse('$baseUrl/api/recommend-jobs?skills=$skills&country=$country'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      final jobsList = decoded['jobs'] as List;
      return jobsList.map((j) => JobModel.fromJson(j)).toList();
    }
    throw ApiException(decoded['detail'] ?? 'Jobs fetch failed', res.statusCode);
  }"""

if "fetchRecommendedJobs" not in content:
    content = content.replace("  // ─────────────────────────────────────────────────────────────────────────\n  // COURSE RECOMMENDATIONS", new_func + "\n\n  // ─────────────────────────────────────────────────────────────────────────\n  // COURSE RECOMMENDATIONS")

with open('lib/services/api_service.dart', 'w') as f:
    f.write(content)
print("api_service updated")
