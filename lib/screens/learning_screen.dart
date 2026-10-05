import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../providers/user_data_provider.dart';
import '../models/project.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _selectedFilter = 'All Recommended';

  static Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary),
            SizedBox(width: 8),
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
            Spacer(),
            Text(
              'Learning Hub',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(width: 12),
            Builder(builder: (context) {
              final user = FirebaseAuth.instance.currentUser;
              final name = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'U';
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary,
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              );
            }),
          ],
        ),
      ),
      body: Consumer<UserDataProvider>(builder: (context, data, _) {
        final targetRole = data.targetCareer.isNotEmpty ? data.targetCareer : 'Tech Role';
        final score = data.profileScore > 0 ? data.profileScore : 0;
        final missingCount = data.missingSkills.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Tailored badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        text: 'AI Tailored for ',
                        children: [
                          TextSpan(text: targetRole, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ],
                      ),
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Progress Overview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48, height: 48,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(value: 1.0, color: AppTheme.subtle, strokeWidth: 4),
                          CircularProgressIndicator(value: (score / 100.0).clamp(0.0, 1.0), color: AppTheme.tertiary, strokeWidth: 4),
                          Center(child: Text('$score%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target Role Alignment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          Text(
                            missingCount > 0
                                ? 'Bridge $missingCount key skill gaps to reach ${score >= 90 ? 100 : score + 15}%'
                                : 'Upload resume in Profile to analyze your alignment',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.insights, color: AppTheme.secondary, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar & Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: AppTheme.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Search $targetRole courses, skills...', style: TextStyle(fontSize: 14, color: AppTheme.grey))),
                          Icon(Icons.mic, size: 18, color: AppTheme.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                    ),
                    child: Icon(Icons.tune, color: AppTheme.grey, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Recommended'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Coursera'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Udemy'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hands-on Projects'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Verified Labs'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Curated Courses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Curated Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.purpleHighlight, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '$missingCount Critical Gaps',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      Icon(Icons.chevron_right, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<CourseModel>>(
                future: ApiService().fetchRecommendedCourses(skills: [targetRole, ...data.missingSkills].join(",")),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Failed to load courses.\n${snapshot.error}", textAlign: TextAlign.center, style: TextStyle(color: AppTheme.error)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No courses found.", style: TextStyle(color: Colors.white70)));
                  }

                  var courses = snapshot.data!;
                  if (_selectedFilter != 'All Recommended') {
                    courses = courses.where((course) {
                      final provider = (course.provider ?? '').toLowerCase();
                      final filter = _selectedFilter.toLowerCase();
                      if (filter.contains('coursera') && provider.contains('coursera')) return true;
                      if (filter.contains('udemy') && provider.contains('udemy')) return true;
                      if (filter.contains('hands-on') && (course.tags?.any((t) => t.toLowerCase().contains('project')) ?? false)) return true;
                      if (filter.contains('verified') && (course.tags?.any((t) => t.toLowerCase().contains('lab')) ?? false)) return true;
                      return false;
                    }).toList();
                  }

                  if (courses.isEmpty) {
                    return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No $_selectedFilter courses found for your role.", style: TextStyle(color: AppTheme.textSecondary))));
                  }

                  return Column(
                    children: courses.map((course) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildApiCourseCard(context, course),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              Text('Real-World Project Blueprints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('Build high-signal portfolio proof vetted against target hiring rubrics.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),

              // ── Live Firestore projects via Provider ─────────────────────
              if (data.isLoading) ...[
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              ] else if (data.projects.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Icon(Icons.code_outlined, size: 40, color: AppTheme.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('Project blueprints will appear here after Lumina analyzes your resume.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    _buildProjectBlueprint1(context),
                    const SizedBox(height: 16),
                    _buildProjectBlueprint2(context),
                  ]),
                )
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _buildDynamicProjectCard(context, data.projects[i]),
                )
              ],
            ],
          ),
        );
      }),
    );
  }

  // ── Dynamic project card from Firestore data ──────────────────────────────
  Widget _buildDynamicProjectCard(BuildContext context, Project project) {
    final difficultyColor = project.difficulty == 'Advanced'
        ? AppTheme.secondary
        : project.difficulty == 'Intermediate'
            ? AppTheme.primary
            : AppTheme.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: difficultyColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.verified, size: 14, color: difficultyColor),
              const SizedBox(width: 4),
              Text(project.difficulty?.toUpperCase() ?? 'PROJECT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: difficultyColor)),
            ]),
          ),
          if (project.estimatedTime != null)
            Text(project.estimatedTime!, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 12),
        Text(project.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(project.description, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        if (project.techStack.isNotEmpty)
          Wrap(spacing: 6, runSpacing: 6, children: project.techStack.map((tech) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(10)),
            child: Text(tech, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          )).toList()),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _launchExternalUrl(
            context,
            project.githubUrl != null && project.githubUrl!.isNotEmpty
                ? project.githubUrl!
                : 'https://github.com/search?q=${Uri.encodeComponent(project.title)}',
          ),
          icon: Text('Start Project', style: TextStyle(color: AppTheme.cardBg, fontSize: 12)),
          label: Icon(Icons.play_arrow, size: 16, color: AppTheme.cardBg),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ]),
    );
  }

  Widget _buildFilterChip(String text) {
    final isSelected = _selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tertiary : AppTheme.cardBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppTheme.cardBg : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildDynamicSkillGapCourseCard(BuildContext context, String skill, String targetRole) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Text('CRITICAL SKILL GAP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('4.9 • Top Match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Mastering $skill for $targetRole',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Tailored learning path specifically recommended by Lumina AI to bridge your resume gap in $skill.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.build_circle_outlined, size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Focus: $skill',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.secondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://www.coursera.org/search?query=${Uri.encodeComponent('$skill $targetRole')}',
                ),
                icon: const Icon(Icons.play_circle_outline, size: 16),
                label: const Text('Start Course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard1(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/5/400/200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.cardBg.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Text('Coursera', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        const SizedBox(width: 4),
                        Text('• DeepLearning.AI', style: TextStyle(fontSize: 10, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10, left: 10, right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.primary, size: 16),
                          const SizedBox(width: 4),
                          Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.cardBg)),
                          const SizedBox(width: 4),
                          Text('(12.4k)', style: TextStyle(fontSize: 12, color: AppTheme.cardBg)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.cardBg.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text('4 Weeks', style: TextStyle(fontSize: 10, color: AppTheme.cardBg)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Advanced LLM Interface & UX Architecture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Master non-deterministic interface states, token streaming affordances, and cognitive friction dampening for multi-turn reasoning agents.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('Prompt Eval', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('Context Windows', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://www.coursera.org/search?query=${Uri.encodeComponent('Advanced LLM Interface UX Architecture')}',
                ),
                icon: Text('Enroll Now', style: TextStyle(color: AppTheme.cardBg, fontSize: 12)),
                label: Icon(Icons.arrow_forward, size: 16, color: AppTheme.cardBg),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)), child: Text('UDEMY BUSINESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText))),
                        const SizedBox(width: 8),
                        Text('18 Hours • On-demand', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Quantitative UX Metrics & Live Telemetry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Instrument telemetry funnels, write designer SQL queries, and measure AI hallucination drop-off impact directly in Mixpanel.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network('https://picsum.photos/seed/6/100/100', width: 64, height: 64, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text('4.9 (8.1k)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('SQL for Designers', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('Mixpanel', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://www.udemy.com/courses/search/?q=${Uri.encodeComponent('Quantitative UX Metrics Telemetry')}',
                ),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purpleHighlight.withValues(alpha: 0.5), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
                child: Text('Enroll', style: TextStyle(color: AppTheme.deepPurpleText, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard3(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)), child: Text('STANFORD ONLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryText))),
                        const SizedBox(width: 8),
                        Text('Self-Paced • 3 Weeks', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Enterprise AI Guardrails & HITL Systems', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Human-in-the-loop fallback schemas, token confidence visualization, and scalable Figma variable systems for regulated domains.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network('https://picsum.photos/seed/7/100/100', width: 64, height: 64, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('Safety AI', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('Figma Tokens', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://www.coursera.org/search?query=${Uri.encodeComponent('Enterprise AI Guardrails Stanford')}',
                ),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purpleHighlight.withValues(alpha: 0.5), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
                child: Text('Enroll', style: TextStyle(color: AppTheme.deepPurpleText, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectBlueprint1(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: AppTheme.primaryText),
                    const SizedBox(width: 4),
                    Text('HIGH RECRUITER SIGNAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                  ],
                ),
              ),
              Text('Intermediate • 2 Wks', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Multi-Modal Voice & Vision AI Copilot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Architect end-to-end user journeys for zero-latency camera streams with voice interruption capabilities.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TARGET RUBRIC MATCHES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)), child: const Text('Stripe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)), child: const Text('Figma', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Handles 300ms audio latency states gracefully', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Includes interactive Prototype & Design System Kit', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.people, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 4),
                    Flexible(child: Text('412 designers completed', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://github.com/search?q=${Uri.encodeComponent('Voice Vision AI Copilot')}',
                ),
                icon: Text('Start Project', style: TextStyle(color: AppTheme.cardBg, fontSize: 12)),
                label: Icon(Icons.play_arrow, size: 16, color: AppTheme.cardBg),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectBlueprint2(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.purpleHighlight.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.stars, size: 14, color: AppTheme.deepPurpleText),
                    const SizedBox(width: 4),
                    Text('SENIOR STAFF TIER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText)),
                  ],
                ),
              ),
              Text('Advanced • 3 Wks', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Autonomous Agent Task-Planning Canvas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Create an infinite interactive workspace interface showing step-by-step sub-agent delegation, rollback trees, and user-override checkpoints.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TARGET RUBRIC MATCHES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)), child: const Text('Anthropic', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Tree-of-thought visual branching models', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Direct sandbox execution permissions UI', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.psychology, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Flexible(child: Text('Aligned with Claude 3.5 Sonnet UX', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _launchExternalUrl(
                  context,
                  'https://github.com/search?q=${Uri.encodeComponent('Autonomous Agent Task Planning Canvas')}',
                ),
                icon: Text('View Spec', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                label: Icon(Icons.visibility, size: 16, color: AppTheme.textPrimary),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.highlight, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildApiCourseCard(BuildContext context, CourseModel course) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              course.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.subtle,
                child: Center(child: Icon(Icons.broken_image, color: AppTheme.grey, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(course.provider, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  course.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchExternalUrl(context, course.url),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text("Enroll Now", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cardBg)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
