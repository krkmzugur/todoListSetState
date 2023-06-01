import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/model/todo.dart';

import 'SessionManager.dart';

class TodoDatabase {
  final String apiUrl = 'http://192.168.1.94:1337/api/todos';
  String statusText = "";

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final data = jsonBody['data'] as List<dynamic>;
      return data.map((item) => Todo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> updateTodoCompletionStatus(
      int todoId, bool newCompletionStatus, BuildContext context) async {
    final url = '$apiUrl/$todoId';
    final jwt = await SessionManager.getJwt();

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwt',
      },
      body: json.encode({
        'data': {
          'completed': newCompletionStatus,
        },
      }),
    );

    if (response.statusCode == 200) {
      statusText = "Todo completion status updated successfully";
    } else {
      statusText = "Todo completion status update failed";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(statusText),
      ),
    );
  }

  Future<void> addTodo(String newTodoTitle, BuildContext context) async {
    bool len = newTodoTitle.trim().isNotEmpty;

    if (len) {
      final jwt = await SessionManager.getJwt();
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
          body: json.encode({
            'data': {
              'title': newTodoTitle,
              'completed': false,
            },
          }),
        );

        if (response.statusCode == 200) {
          // final jsonBody = json.decode(response.body);
          // final newTodo = Todo.fromJson(jsonBody['data']);
          statusText = "Todo  added successfully";
        } else {
          statusText =
              'Todo ne yazık ki eklenemedi HTTP: ${response.statusCode}';
          throw Exception('Failed to add todo');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusText),
          ),
        );
      } catch (e) {}
    }
  }

  Future<void> updateTodoTitle(
      int todoId, String newTitle, BuildContext context) async {
    bool len = newTitle.trim().isNotEmpty;
    if (len) {
      final url = '$apiUrl/$todoId';
      final jwt = await SessionManager.getJwt();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwt',
        },
        body: json.encode({
          'data': {
            'title': newTitle,
          },
        }),
      );

      if (response.statusCode == 200) {
        statusText = "Todo title updated successfully";
      } else {
        statusText = 'Todo title update failed: ${response.statusCode}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusText),
        ),
      );
    }
  }

  Future<void> deleteTodoItem(int todoId, BuildContext context) async {
    final url = '$apiUrl/$todoId';
    final jwt = await SessionManager.getJwt();

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        statusText = "Todo successfully deleted";
      } else {
        statusText = 'Todo ne yazık ki silinemedi HTTP: ${response.statusCode}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusText),
        ),
      );
    } catch (e) {
      print('An error occurred while deleting todo: $e');
    }
  }
}
