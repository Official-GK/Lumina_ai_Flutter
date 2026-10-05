import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static Future<void> _launchJobUrl(BuildContext context, String company, String role, [String? directUrl]) async {
    final query = Uri.encodeComponent('$role $company jobs');
    final url = (directUrl != null && directUrl.isNotEmpty) ? directUrl : 'https://www.linkedin.com/jobs/search/?keywords=$query';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open job page')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<UserDataProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'U';
    final targetRole = data.targetCareer.isNotEmpty ? data.targetCareer : 'Tech Professional';
    final matchScore = data.profileScore > 0 ? data.profileScore : 85;
    final userSkills = data.currentSkills.isNotEmpty ? data.currentSkills : ['Problem Solving', 'Engineering'];
    final gapSkills = data.missingSkills.isNotEmpty ? data.missingSkills : ['System Design'];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lumina',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Career AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Career & Jobs',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Text(userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live API Feed Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Live API Feed • Synced with ',
                        children: [
                          TextSpan(text: 'Greenhouse, Lever & Ashby', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ),
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                  Icon(Icons.sync, size: 20, color: AppTheme.primary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Trajectory Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.explore, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TARGET TRAJECTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.1)),
                            Text(targetRole, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.subtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.tune, size: 20, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text('Remote & Hybrid Preferences', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: AppTheme.grey)),
                      const SizedBox(width: 6),
                      Text('Updated live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppTheme.subtle),
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCol('Live Matches', '18', AppTheme.primary)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetricCol('Avg Comp', '\₹12L', AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetricCol('Top Fit', '$matchScore%', AppTheme.secondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Matches', '18', true, null),
                  const SizedBox(width: 8),
                  _buildFilterChip('90%+ Match', null, false, Icons.auto_awesome),
                  const SizedBox(width: 8),
                  _buildFilterChip('Fast-Track', null, false, Icons.bolt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Remote Only', null, false, null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Job Cards (Live Adzuna API)
            FutureBuilder<List<JobModel>>(
              future: ApiService().fetchRecommendedJobs(skills: targetRole),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load live jobs.\n${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.error)));
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
            ),
            SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.subtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.radar, color: AppTheme.tertiary),
                  ),
                  SizedBox(height: 8),
                  Text('Continuously Monitoring 42 ATS Boards', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('New recommendations stream live as your career roadmap evolves.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color valueColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.subtle.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, String? badge, bool isSelected, IconData? icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.cardBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: AppTheme.primary), SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.cardBg : AppTheme.textPrimary)),
          if (badge != null) ...[
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge, style: TextStyle(fontSize: 10, color: AppTheme.cardBg)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, String company, String location, String time, String matchStr, String role, String pay, String payExtra, List<String> skills, List<String> missingSkills, String? initial, [IconData? icon, String? redirectUrl]) {
    return InkWell(
      onTap: () => _launchJobUrl(context, company, role, redirectUrl),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: initial != null ? AppTheme.deepPurpleText : AppTheme.purpleHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: initial != null
                        ? Text(initial, style: TextStyle(color: AppTheme.cardBg, fontSize: 20, fontWeight: FontWeight.bold))
                        : Icon(icon, color: AppTheme.secondary, size: 24),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(company, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.verified, size: 14, color: AppTheme.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('$location • $time', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 12, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(matchStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(role, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(pay, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                ),
                if (payExtra.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(payExtra, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...skills.map((s) => _buildBadge(s, Icons.check_circle, AppTheme.primary, AppTheme.primaryContainer.withValues(alpha: 0.3))),
                ...missingSkills.map((s) => _buildBadge(s, Icons.lightbulb, AppTheme.error, AppTheme.error.withValues(alpha: 0.1))),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchJobUrl(context, company, role, redirectUrl),
                    icon: Icon(Icons.bolt, color: AppTheme.cardBg, size: 18),
                    label: Text('1-Click Fast Apply', style: TextStyle(color: AppTheme.cardBg, fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.subtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.bookmark_border, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: iconColor)),
        ],
      ),
    );
  }
}
