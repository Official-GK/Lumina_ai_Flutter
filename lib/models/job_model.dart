class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String description;
  final String redirectUrl;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.description,
    required this.redirectUrl,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      company: json['company'] as String? ?? 'Confidential',
      location: json['location'] as String? ?? 'Remote',
      salary: json['salary'] as String? ?? 'Competitive',
      description: json['description'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String? ?? '',
    );
  }
}
