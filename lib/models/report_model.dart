import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String comment;
  final String reportedBy; // Can be admin, traveler, or companier
  final String reportedUserId;
  final DateTime createdAt;

  ReportModel({
    required this.reportId,
    required this.comment,
    required this.reportedBy,
    required this.reportedUserId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'comment': comment,
      'reportedBy': reportedBy,
      'reportedUserId': reportedUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      comment: map['comment'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReportModel.fromMap(data);
  }
}