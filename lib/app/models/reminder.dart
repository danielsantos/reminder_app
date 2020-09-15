
class Reminder {

  final int id;
  final String description;
  final String dateTime;

  Reminder(this.id, this.description, this.dateTime);

  @override
  String toString() {
    return 'Reminder{id: $id, description: $description, dateTime: $dateTime}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'dateTime': dateTime,
    };
  }

}