class CourseModel {
  final String id;
  final String title;
  final String provider;
  final String thumbnailUrl;
  final String url;
  final List<String> tags;

  CourseModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.thumbnailUrl,
    required this.url,
    required this.tags,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json["id"] as String? ?? "",
      title: json["title"] as String? ?? "Untitled Course",
      provider: json["provider"] as String? ?? "Unknown",
      thumbnailUrl: json["thumbnail_url"] as String? ?? "",
      url: json["url"] as String? ?? "",
      tags: (json["tags"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
