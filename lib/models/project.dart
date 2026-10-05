// lib/models/project.dart
// Mirrors Firestore document: portfolios/{uid}.recommended_projects[]

class Project {
  final String title;
  final String description;
  final List<String> techStack;
  final String? githubUrl;
  final String? difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
  final String? estimatedTime;

  const Project({
    required this.title,
    required this.description,
    required this.techStack,
    this.githubUrl,
    this.difficulty,
    this.estimatedTime,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      techStack: List<String>.from(json['tech_stack'] ?? []),
      githubUrl: json['github_url'] as String?,
      difficulty: json['difficulty'] as String?,
      estimatedTime: json['estimated_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tech_stack': techStack,
        if (githubUrl != null) 'github_url': githubUrl,
        if (difficulty != null) 'difficulty': difficulty,
        if (estimatedTime != null) 'estimated_time': estimatedTime,
      };
}
