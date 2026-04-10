enum JobStatus { pending, inProgress, completed, cancelled }

enum JobPriority { low, medium, high, urgent }

class JobNote {
  final String id;
  final String text;
  final DateTime createdAt;

  JobNote({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JobNote.fromJson(Map<String, dynamic> json) => JobNote(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class JobPhoto {
  final String id;
  final String uri;
  final String? caption;
  final DateTime createdAt;

  JobPhoto({
    required this.id,
    required this.uri,
    this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'uri': uri,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JobPhoto.fromJson(Map<String, dynamic> json) => JobPhoto(
        id: json['id'] as String,
        uri: json['uri'] as String,
        caption: json['caption'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class Job {
  final String id;
  final String title;
  final String description;
  final JobStatus status;
  final JobPriority priority;
  final String clientName;
  final String address;
  final List<JobNote> notes;
  final List<JobPhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.clientName,
    required this.address,
    required this.notes,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  Job copyWith({
    String? id,
    String? title,
    String? description,
    JobStatus? status,
    JobPriority? priority,
    String? clientName,
    String? address,
    List<JobNote>? notes,
    List<JobPhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'clientName': clientName,
        'address': address,
        'notes': notes.map((n) => n.toJson()).toList(),
        'photos': photos.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: JobStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => JobStatus.pending,
        ),
        priority: JobPriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => JobPriority.medium,
        ),
        clientName: json['clientName'] as String,
        address: json['address'] as String,
        notes: (json['notes'] as List<dynamic>)
            .map((n) => JobNote.fromJson(n as Map<String, dynamic>))
            .toList(),
        photos: (json['photos'] as List<dynamic>)
            .map((p) => JobPhoto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}

class DashboardStats {
  final int totalJobs;
  final int activeJobs;
  final int completedJobs;
  final int pendingJobs;

  DashboardStats({
    required this.totalJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.pendingJobs,
  });
}

class User {
  final String id;
  final String email;
  final String name;
  final String? company;
  final String? trade;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.company,
    this.trade,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'company': company,
        'trade': trade,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        company: json['company'] as String?,
        trade: json['trade'] as String?,
      );
}
