// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, prefer_final_fields, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:taskly/Models/Task.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //late double _deviceWidth = MediaQuery.of(context).size.width;
  late double _deviceHeight = MediaQuery.of(context).size.height;
  Box? _box;

  String? _newTaskContent;

  _HomePageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          "Taskly !",
          style: TextStyle(fontSize: 25),
        ),
        toolbarHeight: _deviceHeight * (0.15),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
        future: Hive.openBox('tasks'),
        builder: (BuildContext _context, AsyncSnapshot _snapShot) {
          if (_snapShot.connectionState == ConnectionState.done) {
            _box = _snapShot.data;
            return _taskList();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemBuilder: (BuildContext _context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.done ? null : TextDecoration.lineThrough),
          ),
          subtitle: Text(task.timeStamp.toString()),
          trailing: Icon(task.done
              ? Icons.check_box_outline_blank
              : Icons.check_box_outlined),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: (){
            _box!.deleteAt(index);
            setState(() {
              
            });
          },
        );
      },
      itemCount: tasks.length,
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: Icon(Icons.add),
      onPressed: () {
        _displayTaskPopUp();
      },
    );
  }

  void _displayTaskPopUp() {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: Text("Add new Task"),
            content: TextField(
              onSubmitted: (_value) {
                if (_newTaskContent != null) {
                  var task = Task(
                      content: _newTaskContent!,
                      timeStamp: DateTime.now(),
                      done: true);
                  setState(() {
                    _box!.add(task.toMap());
                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (_value) {
                setState(() {
                  _newTaskContent = _value;
                });
              },
            ),
          );
        });
  }
}
