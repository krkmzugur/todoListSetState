import 'package:flutter/material.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/model/todo_db.dart';
import 'package:todo/profile.dart';
import 'login.dart';
import 'model/SessionManager.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoDatabase todoDatabase = TodoDatabase();
  List<Todo> todos = [];
  // Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    fetchTodos();
    //getUserData();
  }

  // Future<void> getUserData() async {
  //   final user = await SessionManager.getUser();
  //   setState(() {
  //     _user = user;
  //   });
  // }

  Future<void> fetchTodos() async {
    try {
      final fetchedTodos = await todoDatabase.fetchTodos();
      setState(() {
        todos = fetchedTodos;
      });
    } catch (e) {
      print('Failed to fetch todos: $e');
    }
  }

  void updateTodoCompletionStatus(int todoId, bool currentCompletionStatus) {
    final newCompletionStatus = !currentCompletionStatus;
    if (!mounted) return;
    todoDatabase.updateTodoCompletionStatus(
        todoId, newCompletionStatus, context);
    setState(() {
      todos.firstWhere((todo) => todo.id == todoId).completed =
          newCompletionStatus;
    });
  }

  Future<void> addTodoItem(String newTodoTitle, BuildContext context) async {
    try {
      if (!mounted) return;
      await todoDatabase.addTodo(newTodoTitle, context);
      await fetchTodos();
    } catch (e) {
      print('Failed to add todo: $e');
    }
  }

  void updateTodoTitle(int todoId, String newTitle) {
    if (!mounted) return;
    todoDatabase.updateTodoTitle(todoId, newTitle, context);
    setState(() {
      todos.firstWhere((todo) => todo.id == todoId).updateTitle(newTitle);
    });
  }

  void deleteTodoItem(int todoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Sil'),
          content: Text('Silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () async {
                if (!mounted) return;
                await todoDatabase.deleteTodoItem(todoId, context);
                await fetchTodos();
                Navigator.pop(context);
              },
              child: Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Center(
          child: Text(
            // '${_user?['username']}',
            'Todo List',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await SessionManager.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchTodos();
        },
        child: todos.isEmpty
            ? Center(
                child: Text(
                  'Todo listesi boş',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card(
                    elevation: 8.0,
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: BoxDecoration(
                            border: Border(
                              right:
                                  BorderSide(width: 1.0, color: Colors.white24),
                            ),
                          ),
                          child: Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.green,
                            value: todo.completed,
                            onChanged: (value) => updateTodoCompletionStatus(
                                todo.id, todo.completed),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String newTitle = todo.title;
                                return AlertDialog(
                                  title: Text('Todo Başlığını Düzenle'),
                                  content: TextField(
                                    controller:
                                        TextEditingController(text: newTitle),
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
                                            if (!mounted) return;
                                            updateTodoTitle(todo.id, newTitle);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Güncelle'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: LinearProgressIndicator(
                                  backgroundColor:
                                      Color.fromRGBO(209, 224, 224, 0.2),
                                  value: 1.0,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.green),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Advanced',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            deleteTodoItem(todo.id);
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
                          if (!mounted) return;
                          addTodoItem(newTodoTitle, context);
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
