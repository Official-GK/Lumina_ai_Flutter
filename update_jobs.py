import re

with open('lib/screens/jobs_screen.dart', 'r') as f:
    content = f.read()

# 1. Add imports
if "import '../models/job_model.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../models/job_model.dart';\nimport '../services/api_service.dart';")

# 2. Update _launchJobUrl to support directUrl
old_launch = """  static Future<void> _launchJobUrl(BuildContext context, String company, String role) async {
    final query = Uri.encodeComponent('$role $company jobs');
    final url = 'https://www.linkedin.com/jobs/search/?keywords=$query';"""
new_launch = """  static Future<void> _launchJobUrl(BuildContext context, String company, String role, [String? directUrl]) async {
    final query = Uri.encodeComponent('$role $company jobs');
    final url = (directUrl != null && directUrl.isNotEmpty) ? directUrl : 'https://www.linkedin.com/jobs/search/?keywords=$query';"""
content = content.replace(old_launch, new_launch)

# 3. Update _buildJobCard signature and logic
old_card_sig = """Widget _buildJobCard(BuildContext context, String company, String location, String time, String matchStr, String role, String pay, String payExtra, List<String> skills, List<String> missingSkills, String? initial, [IconData? icon]) {"""
new_card_sig = """Widget _buildJobCard(BuildContext context, String company, String location, String time, String matchStr, String role, String pay, String payExtra, List<String> skills, List<String> missingSkills, String? initial, [IconData? icon, String? redirectUrl]) {"""
content = content.replace(old_card_sig, new_card_sig)

# Update tap targets in _buildJobCard
content = content.replace("""onTap: () => _launchJobUrl(context, company, role),""", """onTap: () => _launchJobUrl(context, company, role, redirectUrl),""")

# 4. Replace the static job cards with FutureBuilder
cards_section = """            // Job Cards
            _buildJobCard(
              context,
              'Stripe', 'San Francisco, CA (Remote)', '2h ago', '$matchScore% Match', 'Senior $targetRole Specialist', '\\$160,000 – \\$195,000 / yr', '+ Equity',
              userSkills.take(2).toList(), gapSkills.isNotEmpty ? ['Gap: ${gapSkills.first}'] : [], 'S'
            ),
            const SizedBox(height: 16),
            _buildJobCard(
              context,
              'Figma', 'San Francisco, CA (Hybrid)', '5h ago', '${(matchScore * 0.95).round()}% Match', 'Staff $targetRole', '\\$175,000 – \\$210,000 / yr', '',
              userSkills.take(3).toList(), [], null, Icons.polyline
            ),
            const SizedBox(height: 16),
            _buildJobCard(
              context,
              'Anthropic', 'Remote (US)', '1d ago', '${(matchScore * 0.90).round()}% Match', '$targetRole Lead', '\\$155,000 – \\$185,000 / yr', '',
              userSkills.take(2).toList(), [], null, Icons.psychology
            ),"""

future_builder = """            // Job Cards (Live Adzuna API)
            FutureBuilder<List<JobModel>>(
              future: ApiService().fetchRecommendedJobs(skills: targetRole),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load live jobs.\\n${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.error)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No live jobs found right now.', style: TextStyle(color: Colors.white70)));
                }

                final jobs = snapshot.data!;
                return Column(
                  children: jobs.map((job) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildJobCard(
                        context,
                        job.company,
                        job.location,
                        'Live',
                        '99% Match', // Example
                        job.title,
                        job.salary,
                        '',
                        userSkills.take(2).toList(),
                        [],
                        job.company.isNotEmpty ? job.company[0].toUpperCase() : 'C',
                        Icons.work,
                        job.redirectUrl,
                      ),
                    );
                  }).toList(),
                );
              },
            ),"""

content = content.replace(cards_section, future_builder)

with open('lib/screens/jobs_screen.dart', 'w') as f:
    f.write(content)
print("jobs_screen updated")
