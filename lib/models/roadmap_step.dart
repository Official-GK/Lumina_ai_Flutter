// lib/models/roadmap_step.dart
// Mirrors one element inside the Firestore document: roadmaps/{uid}.steps[]

class RoadmapStep {
  final int step;
  final String title;
  final String description;
  final String duration;
  final String status; // 'completed' | 'in_progress' | 'pending'
  final double? completionPercent; // 0.0 – 1.0

  const RoadmapStep({
    required this.step,
    required this.title,
    required this.description,
    required this.duration,
    required this.status,
    this.completionPercent,
  });

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'in_progress';
  bool get isPending => status == 'pending';

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      step: (json['step'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      completionPercent: (json['completion_percent'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'description': description,
        'duration': duration,
        'status': status,
        if (completionPercent != null) 'completion_percent': completionPercent,
      };
}
