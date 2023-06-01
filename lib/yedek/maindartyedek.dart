import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../login.dart';
import '../model/SessionManager.dart';
import '../utils/constants.dart';

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

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];

  Future<void> fetchTodos() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.94:1337/api/todos'));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final data = jsonBody['data'] as List<dynamic>;
      setState(() {
        todos = data.map((item) => Todo.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> updateTodo(int todoId, bool newCompletionStatus) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.94:1337/api/todos/$todoId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'data': {
          'completed': newCompletionStatus,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Todo completion status updated successfully');
      print('Response body: ${response.body}');
    } else {
      print('Todo completion status update failed');
      print('Response body: ${response.body}');
    }
  }

  Future<void> addTodo(String newTodoTitle) async {
    final url = 'http://192.168.1.94:1337/api/todos';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'data': {
          'title': newTodoTitle,
          'completed': false,
        },
      }),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final newTodo = Todo.fromJson(jsonBody['data']);
      setState(() {
        todos.add(newTodo);
      });
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  void onCheckBoxTapped(int todoId, bool currentCompletionStatus) {
    final newCompletionStatus = !currentCompletionStatus;
    updateTodo(todoId, newCompletionStatus);
    setState(() {
      todos.firstWhere((todo) => todo.id == todoId).completed =
          newCompletionStatus;
    });
  }

  Future<void> updateTodoTitle(int todoId, String newTitle) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.94:1337/api/todos/$todoId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'data': {
          'title': newTitle,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Todo title updated successfully');
    } else {
      print('Todo title update failed');
      print('Response body: ${response.body}');
    }
  }

  void editTodoTitle(int todoId, String currentTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = currentTitle;
        return AlertDialog(
          title: Text('Todo Başlığını Düzenle'),
          content: TextField(
            controller: TextEditingController(
                text: currentTitle), // Başlığı varsayılan olarak ayarlayın
            onChanged: (value) {
              newTitle = value;
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Vazgeç'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      todos
                          .firstWhere((todo) => todo.id == todoId)
                          .updateTitle(newTitle);
                    });
                    updateTodoTitle(todoId,
                        newTitle); // API'ye başlığı güncelleme isteği gönder
                    Navigator.pop(context);
                  },
                  child: Text('Kaydet'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void deleteTodo(int todoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Sil'),
          content: Text('Silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog kutusunu kapat
              },
              child: Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                deleteTodoItem(
                    todoId); // Todo öğesini silme işlemini gerçekleştir
                Navigator.pop(context); // Dialog kutusunu kapat
              },
              child: Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTodoItem(int todoId) async {
    final url = 'http://192.168.1.94:1337/api/todos/$todoId';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Todo successfully deleted');
        setState(() {
          todos.removeWhere((todo) => todo.id == todoId);
        });
      } else {
        print('Failed to delete todo. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while deleting todo: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomNavigationBar: bottomBar,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Center(
          child: Text("Todo List"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await SessionManager.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.list),
          //   onPressed: () {},
          // )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchTodos(); // API'den yeni todo verilerini almak için işlevi çağırın
        },
        child: todos.isEmpty == true
            ? Center(
                child: Text(
                "Todo is empty",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ))
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: new BoxDecoration(
                              border: new Border(
                                  right: new BorderSide(
                                      width: 1.0, color: Colors.white24))),
                          child: Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.green,
                            value: todo.completed,
                            onChanged: (value) =>
                                onCheckBoxTapped(todo.id, todo.completed),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            editTodoTitle(todo.id, todo.title);
                          },
                          child: Text(
                            todo.title,
                            style: TextStyle(
                                decoration: todo.completed == true
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                        subtitle: Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                  // tag: 'hero',
                                  child: LinearProgressIndicator(
                                      backgroundColor:
                                          Color.fromRGBO(209, 224, 224, 0.2),
                                      value: 1.0,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.green)),
                                )),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text("Advanced",
                                      style: TextStyle(color: Colors.white))),
                            )
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            deleteTodo(todo.id);
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni todo eklemek için bir diyalog kutusu gösterin
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newTodoTitle = '';
              return AlertDialog(
                title: Text('Yeni Todo Ekle'),
                content: TextField(
                  onChanged: (value) {
                    newTodoTitle = value;
                  },
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: () {
                          addTodo(newTodoTitle);
                          Navigator.pop(context);
                        },
                        child: Text('Ekle'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoListPage(),
  ));
}
