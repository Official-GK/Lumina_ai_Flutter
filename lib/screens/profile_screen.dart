import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../providers/user_data_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<UserDataProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final initials = displayName.split(' ').take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    final score = data.profile.profileScore;
    final projectCount = data.projects.length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(children: [
          Icon(Icons.auto_awesome, color: AppTheme.primary),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Lumina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text('Career AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ]),
          const Spacer(),
          Text('User Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: Text(initials.isNotEmpty ? initials : 'U',
                style: TextStyle(color: AppTheme.cardBg, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: AppTheme.isDarkMode,
            builder: (context, isDark, child) => IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.textPrimary),
              onPressed: AppTheme.toggleDarkMode,
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout_outlined, color: AppTheme.error),
            tooltip: 'Sign Out',
            onPressed: () async {
              final nav = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.cardBg,
                  title: Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary)),
                  content: Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Sign Out', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await AuthService.signOut();
                nav.pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Avatar
                  Stack(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(initials.isNotEmpty ? initials : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                    ),
                    Positioned(bottom: -4, right: -4, child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: AppTheme.tertiary, shape: BoxShape.circle),
                      child: Icon(Icons.check, size: 12, color: AppTheme.cardBg),
                    )),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Flexible(child: Text(displayName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          score >= 70 ? 'Recruiter Ready' : score >= 40 ? 'In Progress' : 'Getting Started',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      data.profile.isEmpty ? 'Upload your resume to see your career role' : data.profile.targetCareer,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/pricing'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.verified, size: 12, color: AppTheme.secondary),
                          const SizedBox(width: 4),
                          Text('View Premium Plans', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                        ]),
                      ),
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),
                // ── Live metric cards ──────────────────────────────────
                Row(children: [
                  Expanded(child: _buildMetricCard(
                    data.profile.isEmpty ? '—' : '$score%',
                    'Readiness Score', Icons.auto_graph, AppTheme.primary,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(
                    '$projectCount', 'AI Projects', Icons.folder_special, AppTheme.secondary,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard(
                    '${data.completedSteps}', 'Steps Done', Icons.military_tech, AppTheme.tertiary,
                  )),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share, size: 16, color: AppTheme.cardBg),
                    label: Text('Share Portfolio', style: TextStyle(color: AppTheme.cardBg, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.tune, size: 16, color: AppTheme.textSecondary),
                    label: Text('Edit', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.highlight.withValues(alpha: 0.8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Resume Upload Section (only here in Profile) ───────────────
            _buildResumeUploadSection(data),
            const SizedBox(height: 24),

            // ── Tab Switcher ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 0 ? AppTheme.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _selectedTabIndex == 0 ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.folder_open, size: 16, color: _selectedTabIndex == 0 ? AppTheme.primary : AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text('Projects (${data.projects.length})',
                          style: TextStyle(fontSize: 12, fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal, color: _selectedTabIndex == 0 ? AppTheme.primary : AppTheme.textSecondary)),
                    ]),
                  ),
                )),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 1 ? AppTheme.cardBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _selectedTabIndex == 1 ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.token, size: 16, color: _selectedTabIndex == 1 ? AppTheme.secondary : AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text('Skills & Gaps', style: TextStyle(fontSize: 12, fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal, color: _selectedTabIndex == 1 ? AppTheme.secondary : AppTheme.textSecondary)),
                    ]),
                  ),
                )),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Tab Content ───────────────────────────────────────────────
            if (_selectedTabIndex == 0) _buildProjectsTab(data),
            if (_selectedTabIndex == 1) _buildSkillsTab(data),
          ],
        ),
      ),
    );
  }

  // ── Resume Upload Card (only shown here) ──────────────────────────────────
  Widget _buildResumeUploadSection(UserDataProvider data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0.12), AppTheme.secondary.withValues(alpha: 0.08)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            data.profile.isEmpty ? 'Upload Resume' : 'Re-analyze Resume',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          Text(
            data.profile.isEmpty
                ? 'Get your AI career score, skill gaps & roadmap'
                : 'Update your score with your latest resume',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ])),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(data.profile.isEmpty ? 'Upload' : 'Update', style: TextStyle(color: AppTheme.cardBg, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  // ── Projects Tab ─────────────────────────────────────────────────────────
  Widget _buildProjectsTab(UserDataProvider data) {
    if (data.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }

    if (data.projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(Icons.folder_open, size: 48, color: AppTheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No projects yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Upload your resume and Lumina AI will recommend portfolio projects tailored to your skill gaps.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
        ]),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: data.projects.length,
      itemBuilder: (context, i) {
        final p = data.projects[i];
        final colorIndex = i % 4;
        final imgSeed = i + 1;
        return _buildProjectCard(p.title, p.techStack.take(2).join(' • '), '${(i + 1) * 42}', 'https://picsum.photos/seed/$imgSeed/400/300', colorIndex);
      },
    );
  }

  // ── Skills Tab ────────────────────────────────────────────────────────────
  Widget _buildSkillsTab(UserDataProvider data) {
    if (data.profile.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(Icons.psychology_outlined, size: 48, color: AppTheme.secondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No skill data yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Upload your resume to see your verified skills and priority skill gaps.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
        ]),
      );
    }

    return Column(children: [
      // Current skills
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text('Verified Skills (${data.profile.currentSkills.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: data.profile.currentSkills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified, size: 12, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(s, style: TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
            ]),
          )).toList()),
        ]),
      ),
      const SizedBox(height: 12),
      // Missing skills
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.priority_high, size: 16, color: AppTheme.error),
            const SizedBox(width: 8),
            Text('Priority Gaps (${data.profile.missingSkills.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: data.profile.missingSkills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bolt, size: 12, color: AppTheme.error),
              const SizedBox(width: 4),
              Text(s, style: TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
            ]),
          )).toList()),
        ]),
      ),
    ]);
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildProjectCard(String title, String subtitle, String views, String imgUrl, int colorIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(imgUrl, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppTheme.subtle, child: Icon(Icons.code, color: AppTheme.primary, size: 32))),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Icon(Icons.visibility, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(views, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ]),
              Icon(Icons.arrow_forward, size: 14, color: AppTheme.primary),
            ]),
          ]),
        ),
      ]),
    );
  }
}
