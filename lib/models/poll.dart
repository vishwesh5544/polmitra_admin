import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polmitra_admin/models/user.dart';

class Poll {
  final String id;
  final String question;
  final List<String> options;
  final String netaId;
  final Map<String, int> responses;
  final List<String> responders;
  final PolmitraUser? neta;
  final bool isActive;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.netaId,
    this.responses = const {},
    this.responders = const [],
    this.neta,
    this.isActive = false
  });

  factory Poll.fromDocument({required DocumentSnapshot doc, PolmitraUser? neta}) {
    Map data = doc.data() as Map;
    return Poll(
        id: doc.id,
        question: data['question'] ?? '',
        options: List.from(data['options'] ?? []),
        netaId: data['netaId'] ?? '',
        responses: Map<String, int>.from(data['responses'] ?? {}),
        responders: List<String>.from(data['responders'] ?? []),
        neta: neta,
        isActive: data['isActive'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'netaId': netaId,
      'responses': responses,
      'responders': responders,
      'isActive': isActive
    };
  }

  Poll copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? netaId,
    Map<String, int>? responses,
    List<String>? responders,
    PolmitraUser? neta,
    bool? isActive
  }) {
    return Poll(
        id: id ?? this.id,
        question: question ?? this.question,
        options: options ?? this.options,
        netaId: netaId ?? this.netaId,
        responses: responses ?? this.responses,
        responders: responders ?? this.responders,
        neta: neta ?? this.neta,
        isActive: isActive ?? this.isActive
    );
  }


}
