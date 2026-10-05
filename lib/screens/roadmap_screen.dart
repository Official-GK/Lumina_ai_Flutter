import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/user_data_provider.dart';
import '../models/roadmap_step.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<UserDataProvider>();

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
          Text('Roadmap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          const SizedBox(width: 12),
          GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: CircleAvatar(radius: 16, backgroundColor: AppTheme.primary, child: Icon(Icons.person, color: AppTheme.cardBg, size: 18))),
        ]),
      ),
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.profile.isEmpty
              ? _buildEmptyState(context)
              : _buildContent(context, data),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.alt_route, size: 64, color: AppTheme.primary.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('No Roadmap Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text('Upload your resume and let Lumina AI generate a personalized step-by-step career roadmap for you.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/upload'),
          icon: Icon(Icons.cloud_upload_outlined, color: AppTheme.cardBg),
          label: Text('Upload Resume', style: TextStyle(color: AppTheme.cardBg, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    ));
  }

  Widget _buildContent(BuildContext context, UserDataProvider data) {
    final steps = data.roadmapSteps;
    final pendingCount = data.pendingSteps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Target trajectory card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.explore, size: 18, color: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                Text('TARGET TRAJECTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.circle, size: 6, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text('${data.profile.profileScore}% Aligned',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Text(data.profile.targetCareer,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Master ${data.profile.missingSkills.length} key missing competencies to unlock tier-1 hiring pools.',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.insights, size: 20, color: AppTheme.primary)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ESTIMATED EFFORT', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    Text(data.profile.weeksToRole != null ? '${data.profile.weeksToRole} Weeks to Goal' : 'Custom Pace',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ]),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                  child: Text('Tier-1 Fit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // Skills breakdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Current skills
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Row(children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.25), shape: BoxShape.circle), child: Icon(Icons.check, size: 14, color: AppTheme.primary)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('Skills You Have (Verified)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text('${data.profile.currentSkills.length} Validated', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ]),
            const SizedBox(height: 12),
            data.profile.currentSkills.isEmpty
                ? Text('No skills detected yet — upload your resume.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))
                : Wrap(spacing: 8, runSpacing: 8, children: data.profile.currentSkills.map(_buildSkillChip).toList()),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppTheme.subtle),
            ),
            // Missing skills
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Row(children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.priority_high, size: 14, color: AppTheme.error)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('Missing Skills (Priority Gaps)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text('${data.profile.missingSkills.length} Critical', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.error)),
            ]),
            const SizedBox(height: 12),
            data.profile.missingSkills.isEmpty
                ? Text('Great — no critical gaps detected!', style: TextStyle(fontSize: 13, color: AppTheme.primary))
                : Wrap(spacing: 8, runSpacing: 8, children: data.profile.missingSkills.map(_buildMissingSkillChip).toList()),
          ]),
        ),
        const SizedBox(height: 24),

        // Timeline header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Personalized Trajectory Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('Real-time synchronized career plan', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Text('$pendingCount Steps Left', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ),
        ]),
        const SizedBox(height: 16),

        // ── Real-time steps from Firestore via ListView.builder ──────────
        steps.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
                child: Text('Your roadmap steps will appear here after the AI analyzes your resume.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
              )
            : Column(
                children: steps.asMap().entries.map((entry) {
                  final isLast = entry.key == steps.length - 1;
                  return _buildTimelineStep(entry.value, isLast);
                }).toList(),
              ),
        const SizedBox(height: 24),

        // Bottom banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.6), shape: BoxShape.circle), child: Icon(Icons.smart_toy, size: 20, color: AppTheme.secondary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Need live mentor feedback?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('Ask the AI Career Assistant anytime', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ])),
          ]),
        ),
      ]),
    );
  }

  // ── Timeline step card ──────────────────────────────────────────────────
  Widget _buildTimelineStep(RoadmapStep step, bool isLast) {
    final isCompleted = step.isCompleted;
    final isActive = step.isActive;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node dot
          Container(
            width: isActive ? 28 : 24,
            height: isActive ? 28 : 24,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.primary : isActive ? AppTheme.cardBg : AppTheme.subtle,
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 4) : null,
            ),
            child: isCompleted
                ? Icon(Icons.check, size: 14, color: AppTheme.cardBg)
                : isActive
                    ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)))
                    : Center(child: Text('${step.step}', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold))),
          ),
          // Card body wrapped in Expanded so it NEVER overflows horizontally
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isActive ? 18 : 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withValues(alpha: isActive ? 0.95 : 0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.12), blurRadius: 32, offset: const Offset(0, 12))]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.tertiary.withValues(alpha: 0.2)
                              : isActive
                                  ? AppTheme.purpleHighlight
                                  : AppTheme.subtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive) ...[
                              Icon(Icons.circle, size: 6, color: AppTheme.secondary),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isCompleted ? 'Completed' : isActive ? 'Active Now' : 'Upcoming',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? AppTheme.primaryText
                                    : isActive
                                        ? AppTheme.secondary
                                        : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          step.duration,
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(step.title, style: TextStyle(fontSize: isActive ? 17 : 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(step.description, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  // Progress bar for active step
                  if (isActive && step.completionPercent != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sprint Completion', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Text('${(step.completionPercent! * 100).round()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: step.completionPercent,
                      backgroundColor: AppTheme.highlight,
                      color: AppTheme.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.verified, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _buildMissingSkillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bolt, size: 14, color: AppTheme.error),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
