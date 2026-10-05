import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../providers/user_data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<UserDataProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? 'there';
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

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
        ]),
        actions: [
          Center(child: Text('Dashboard', style: TextStyle(fontSize: 12, color: AppTheme.grey.shade600, fontWeight: FontWeight.w500))),
          const SizedBox(width: 12),
          _userAvatar(context, user),
          const SizedBox(width: 16),
        ],
      ),
      body: data.isLoading
          ? _buildLoadingSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(children: [
                          Flexible(
                            child: Text('$greeting, $displayName',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          const Text('👋', style: TextStyle(fontSize: 22)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.highlight.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: Icon(Icons.notifications_outlined, size: 20, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Target career ────────────────────────────────────────
                  if (data.profile.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.my_location, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('Target: ', style: TextStyle(color: AppTheme.grey.shade700, fontSize: 14)),
                      Flexible(
                        child: Text(data.profile.targetCareer,
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 24),

                  // ── Score card ───────────────────────────────────────────
                  data.profile.isEmpty
                      ? _buildNoProfileCard(context)
                      : _buildReadinessCard(data),

                  const SizedBox(height: 16),

                  // ── Skills card ──────────────────────────────────────────
                  if (data.profile.isNotEmpty) _buildSkillsCard(data),

                  const SizedBox(height: 16),

                  // ── Quick metrics ────────────────────────────────────────
                  if (data.profile.isNotEmpty) ...[
                    Row(children: [
                      Expanded(child: _buildMetricCard(
                        Icons.crisis_alert, 'Priority',
                        '${data.profile.missingSkills.length} Key Gaps',
                        data.profile.missingSkills.take(2).join(' & '),
                        Colors.redAccent,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard(
                        Icons.work, 'High Fit',
                        '18 Live Roles',
                        'Matched to your trajectory',
                        AppTheme.primary,
                      )),
                    ]),
                    const SizedBox(height: 16),
                  ],

                  // ── Next step banner ─────────────────────────────────────
                  if (data.profile.isNotEmpty) _buildNextStepBanner(data),
                ],
              ),
            ),
    );
  }

  // ── Loading skeleton ────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _shimmer(height: 180, radius: 20),
        const SizedBox(height: 16),
        _shimmer(height: 120, radius: 20),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _shimmer(height: 90, radius: 16)),
          const SizedBox(width: 12),
          Expanded(child: _shimmer(height: 90, radius: 16)),
        ]),
      ]),
    );
  }

  Widget _shimmer({required double height, double radius = 8}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.subtle,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── No profile yet — direct to Profile page ────────────────────────────
  Widget _buildNoProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Icon(Icons.insert_chart_outlined_rounded, size: 52, color: AppTheme.primary.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('Your Career Score Awaits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Upload your resume from the Profile page to get your personalized Career Readiness Score.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to the Profile tab (index 4 in bottom nav)
            // The MainScreen handles this via its bottom nav
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.person_outline, color: AppTheme.primary),
          label: Text('Go to Profile → Upload Resume', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }

  // ── Readiness score card (real data) ────────────────────────────────────
  Widget _buildReadinessCard(UserDataProvider data) {
    final score = data.profile.profileScore;
    final scoreValue = score / 100.0;
    final weeks = data.profile.weeksToRole;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.donut_large, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Career Readiness Score', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text('Calibrated to live open roles', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
              ]),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
              child: Text('Live', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Circular score indicator
        SizedBox(
          width: 160, height: 160,
          child: Stack(children: [
            Center(child: SizedBox(
              width: 150, height: 150,
              child: CircularProgressIndicator(
                value: scoreValue,
                strokeWidth: 12,
                backgroundColor: AppTheme.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tertiary),
              ),
            )),
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$score%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('Readiness', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.trending_up, color: AppTheme.primary, size: 16),
              const SizedBox(width: 4),
              Text('${data.completedSteps} steps ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary)),
              Text('done', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
            ]),
          )),
          const SizedBox(width: 12),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.schedule, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 4),
              Text(weeks != null ? '$weeks weeks ' : '– ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary)),
              Text('to role', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
            ]),
          )),
        ]),
      ]),
    );
  }

  // ── Skills card (real data) ─────────────────────────────────────────────
  Widget _buildSkillsCard(UserDataProvider data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.hub, color: AppTheme.secondary),
          ),
          const SizedBox(width: 12),
          Text('Skill Assessment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 16),

        // Current skills
        if (data.profile.currentSkills.isNotEmpty) ...[
          Row(children: [
            Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text('You Have (${data.profile.currentSkills.length})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: data.profile.currentSkills.map((s) => _skillChip(s, true)).toList()),
          const SizedBox(height: 16),
        ],

        // Missing skills
        if (data.profile.missingSkills.isNotEmpty) ...[
          Row(children: [
            Icon(Icons.priority_high, size: 16, color: AppTheme.error),
            const SizedBox(width: 6),
            Text('Priority Gaps (${data.profile.missingSkills.length})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: data.profile.missingSkills.map((s) => _skillChip(s, false)).toList()),
        ],
      ]),
    );
  }

  Widget _skillChip(String text, bool has) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: has ? AppTheme.subtle : AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(has ? Icons.verified : Icons.bolt, size: 12,
            color: has ? AppTheme.primary : AppTheme.error),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: TextStyle(fontSize: 11, color: has ? AppTheme.textPrimary : AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ── Metric card ─────────────────────────────────────────────────────────
  Widget _buildMetricCard(IconData icon, String badge, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.grey)),
        const SizedBox(height: 12),
        Row(children: [
          Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 14, color: color),
        ]),
      ]),
    );
  }

  // ── Next step banner ────────────────────────────────────────────────────
  Widget _buildNextStepBanner(UserDataProvider data) {
    // Use first "in_progress" step or fall back to first pending step
    final activeStep = data.roadmapSteps.where((s) => s.isActive).firstOrNull
        ?? data.roadmapSteps.where((s) => s.isPending).firstOrNull;

    final nextAction = activeStep?.title ?? data.profile.nextRecommendedStep ?? 'Continue your learning roadmap';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.cardBg, AppTheme.subtle]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.auto_awesome, color: AppTheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RECOMMENDED NEXT STEP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
            const SizedBox(height: 4),
            Text(nextAction, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            if (activeStep != null) ...[
              const SizedBox(height: 4),
              Text(activeStep.description, style: TextStyle(fontSize: 12, color: AppTheme.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ])),
        ]),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Start learning before it's too late!",
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _userAvatar(BuildContext context, User? user) {
    final name = user?.displayName ?? user?.email ?? 'U';
    final initials = name.split(' ').take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.primary,
        child: Text(initials.isNotEmpty ? initials : 'U', style: TextStyle(color: AppTheme.cardBg, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
