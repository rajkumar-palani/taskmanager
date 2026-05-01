class Task {
  String? objectId;
  String title;
  String description;
  String status; // Pending, InProgress, Complete
  String? ownerId;
  DateTime? createdAt;

  Task({
    this.objectId,
    required this.title,
    required this.description,
    required this.status,
    this.ownerId,
    this.createdAt,
  });

  factory Task.fromParse(Map<String, dynamic> map) {
    // Safely extract nested owner.objectId which may be a Map in Parse results.
    String? ownerId;
    final owner = map['owner'];
    if (owner is Map) {
      ownerId = owner['objectId'] as String?;
    }

    // Parse createdAt if present (Parse returns ISO8601 timestamp string)
    DateTime? created;
    final createdRaw = map['createdAt'];
    if (createdRaw is String && createdRaw.isNotEmpty) {
      try {
        created = DateTime.tryParse(createdRaw)?.toLocal();
      } catch (_) {
        created = null;
      }
    }

    return Task(
      objectId: map['objectId'] as String?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      ownerId: ownerId,
      createdAt: created,
    );
  }

  Map<String, dynamic> toParse() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'status': status,
    };
    if (ownerId != null) {
      data['owner'] = {
        '__type': 'Pointer',
        'className': '_User',
        'objectId': ownerId,
      };
    }
    return data;
  }
}

