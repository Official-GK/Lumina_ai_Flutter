// lib/models/user_profile.dart
// Mirrors the Firestore document at: profiles/{uid}

class UserProfile {
  final String uid;
  final String targetCareer;
  final List<String> currentSkills;
  final List<String> missingSkills;
  final int profileScore;
  final String? nextRecommendedStep;
  final int? weeksToRole;

  const UserProfile({
    required this.uid,
    required this.targetCareer,
    required this.currentSkills,
    required this.missingSkills,
    required this.profileScore,
    this.nextRecommendedStep,
    this.weeksToRole,
  });

  // ── Empty / fallback profile shown before resume is uploaded ──────────────
  static const empty = UserProfile(
    uid: '',
    targetCareer: '',
    currentSkills: [],
    missingSkills: [],
    profileScore: 0,
  );

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json, String uid) {
    return UserProfile(
      uid: uid,
      targetCareer: json['target_career'] as String? ?? '',
      currentSkills: List<String>.from(json['current_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      profileScore: (json['profile_score'] as num?)?.toInt() ?? 0,
      nextRecommendedStep: json['next_recommended_step'] as String?,
      weeksToRole: (json['weeks_to_role'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'target_career': targetCareer,
        'current_skills': currentSkills,
        'missing_skills': missingSkills,
        'profile_score': profileScore,
        if (nextRecommendedStep != null) 'next_recommended_step': nextRecommendedStep,
        if (weeksToRole != null) 'weeks_to_role': weeksToRole,
      };

  UserProfile copyWith({
    String? uid,
    String? targetCareer,
    List<String>? currentSkills,
    List<String>? missingSkills,
    int? profileScore,
    String? nextRecommendedStep,
    int? weeksToRole,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      targetCareer: targetCareer ?? this.targetCareer,
      currentSkills: currentSkills ?? this.currentSkills,
      missingSkills: missingSkills ?? this.missingSkills,
      profileScore: profileScore ?? this.profileScore,
      nextRecommendedStep: nextRecommendedStep ?? this.nextRecommendedStep,
      weeksToRole: weeksToRole ?? this.weeksToRole,
    );
  }
}
