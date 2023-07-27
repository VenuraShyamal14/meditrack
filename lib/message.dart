class Message {

  final String key;
  final String text;
  final bool morning;
  final bool lunch;
  final bool dinner;
  final int selectedNumber;

  Message({
    required this.key,
    required this.text,
    required this.morning,
    required this.lunch,
    required this.dinner,
    required this.selectedNumber,
  });
}