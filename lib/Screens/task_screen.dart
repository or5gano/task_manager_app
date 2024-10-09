import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/db_helper.dart'; 

class TaskTracker extends StatefulWidget {
    static const String id = '/tasks';
  @override
  _TaskTrackerState createState() => _TaskTrackerState();
}

class _TaskTrackerState extends State<TaskTracker> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = TaskDatabase.instance.fetchTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasks = TaskDatabase.instance.fetchTasks();
    });
  }

 void _addOrEditTask({Task? task}) {
  final TextEditingController taskNameController = TextEditingController(text: task?.name ?? '');
  final TextEditingController taskDescriptionController = TextEditingController(text: task?.description ?? '');
  final TextEditingController taskDueDateController = TextEditingController(text: task?.dueDate ?? '');
  
  bool isEditing = task != null;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController, 
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: taskDescriptionController, 
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: taskDueDateController, 
                decoration: InputDecoration(labelText: 'Due Date (yyyy-mm-dd)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              String taskName = taskNameController.text;
              String taskDescription = taskDescriptionController.text;
              String taskDueDate = taskDueDateController.text;

              if (taskName.isNotEmpty && taskDueDate.isNotEmpty) {
                final newTask = Task(
                  id: task?.id,
                  name: taskName,
                  description: taskDescription,
                  dueDate: taskDueDate,
                );
                if (isEditing) {
                  TaskDatabase.instance.updateTask(newTask);
                } else {
                  TaskDatabase.instance.addTask(newTask);
                }
                _refreshTasks();
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      );
    },
  );
}


  void _deleteTask(int id) {
    TaskDatabase.instance.deleteTask(id);
    _refreshTasks();
  }

  void _toggleCompletion(Task task) {
    TaskDatabase.instance.updateTask(task..isCompleted = !task.isCompleted);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(_tasks),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(task.name,style: TextStyle(
                    decoration: task.isCompleted?TextDecoration.lineThrough: TextDecoration.none,
                  ),),
                  subtitle: Text('Due: ${task.dueDate}\n${task.description}',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  leading: Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.blue,
                    onChanged: (val) => _toggleCompletion(task),
                  ),
                   trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(task.id!), 
                  ),
                  onTap: () => _addOrEditTask(task: task),
                  //onLongPress: () => _deleteTask(task.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate {
  final Future<List<Task>> tasksFuture;
  TaskSearchDelegate(this.tasksFuture);

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final filteredTasks = snapshot.data!
            .where((task) => task.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return ListTile(
              title: Text(task.name),
              subtitle: Text(task.description),
              onTap: () => Navigator.pushNamed(context, '/details', arguments: task),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

   
        final suggestions = snapshot.data!
            .where((task) => task.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              title: Text(suggestion.name),
              onTap: () {
                query = suggestion.name;
                showResults(context); 
              },
            );
          },
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

