class Todo {
  int id;
  String title;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  void updateTitle(String newTitle) {
    title = newTitle;
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['attributes']['title'],
      completed: json['attributes']['completed'],
    );
  }
}
