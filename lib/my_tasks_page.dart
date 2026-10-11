import 'package:flutter/material.dart';
import 'add_task_page.dart';
import 'database_helper.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  String selectedTab = 'All';

  List<Map<String, dynamic>> tasks = [];

  Future<void> loadTasks() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('tasks', orderBy: 'id DESC');

    if (!mounted) return;

    setState(() {
      tasks = result.map((task) {
        return {
          ...task,
          'completed': task['completed'] == 1,
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  DateTime? selectedDate;

  List<Map<String, dynamic>> get filteredTasks {
    if (selectedTab == 'Ongoing') {
      return tasks
          .where((task) => task['completed'] != true)
          .toList();
    }

    if (selectedTab == 'Completed') {
      return tasks
          .where((task) => task['completed'] == true)
          .toList();
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF172554),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'My Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
          IconButton(
            onPressed: () async {
              final newTask = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTaskPage(),
                ),
              );

              if (newTask != null) {
                await loadTasks();
              }
            },
      icon: const Icon(
        Icons.add_circle,
        color: Color(0xFF0878F9),
        size: 36,
      ),
    ),
    const SizedBox(width: 8),
    ],
    ),
    body: Column(
    children: [
    const SizedBox(height: 20),

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
    children: [
    buildTab('All'),
    const SizedBox(width: 8),
    buildTab('Ongoing'),
    const SizedBox(width: 8),
    buildTab('Completed'),
    ],
    ),
    ),

      Expanded(
        child: tasks.isEmpty
            ? const Center(
          child: Text(
            'No tasks yet. Tap + to add a task.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 15,
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final isCompleted = task['completed'] == true;

            return Card(
              color: isCompleted
                  ? const Color(0xFFD9FBEA)
                  : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                minLeadingWidth: 30,
                horizontalTitleGap: 8,
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: (value) async {
                    final newStatus = value ?? false;

                    setState(() {
                      task['completed'] = newStatus;
                    });

                    await DatabaseHelper.instance.saveTask(task);

                    await loadTasks();
                  },
                ),
                title: Text(
                  task['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task['description'] ?? ''),
                      const SizedBox(height: 6),

                      if (task['dueDate'] != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 15,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Due: ${task['dueDate'] is DateTime
                                    ? '${task['dueDate'].day.toString().padLeft(2, '0')}/${task['dueDate'].month.toString().padLeft(2, '0')}/${task['dueDate'].year}'
                                    : task['dueDate'] != null
                                    ? DateTime.parse(task['dueDate'].toString()).day.toString().padLeft(2, '0') +
                                    '/' +
                                    DateTime.parse(task['dueDate'].toString()).month.toString().padLeft(2, '0') +
                                    '/' +
                                    DateTime.parse(task['dueDate'].toString()).year.toString()
                                    : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task['priority'] == 'High'
                            ? Colors.red.shade100
                            : task['priority'] == 'Medium'
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Priority: ${task['priority'] ?? 'Low'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: task['priority'] == 'High'
                                ? Colors.red.shade900
                                : task['priority'] == 'Medium'
                                ? Colors.blue.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                icon: const Icon(
                Icons.edit,
                  color: Colors.blue,
                  size: 20,
                ),
                onPressed: () async {
                  final result =
                  await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskPage(task: task),
                    ),
                  );

                  if (result != null) {
                    await loadTasks();
                  }
                },
              ),
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Task?'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await DatabaseHelper.instance.deleteTask(task['id']);

                              if (!context.mounted) return;

                              setState(() {
                                tasks.removeWhere(
                                      (item) => item['id'] == task['id'],
                                );
                              });

                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
                ],
              ),
              ),
            );
          },
        ),
      ),
    ],
    ),
    );
  }

  Widget buildTab(String tab) {
    bool isSelected = selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0878F9)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0878F9)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            tab,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}