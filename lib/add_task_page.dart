import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddTaskPage extends StatefulWidget {

  final Map<String, dynamic>? task;

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? dueDate;
  String priority = 'Medium';

  @override
  void initState() {
    super.initState();

    titleController.text = widget.task?['title'] ?? '';
    descriptionController.text =
        widget.task?['description'] ?? '';

    final savedDate = widget.task?['dueDate'];

    if (savedDate is DateTime) {
      dueDate = savedDate;
    } else if (savedDate is String) {
      dueDate = DateTime.tryParse(savedDate);
    }

    priority = widget.task?['priority'] ?? 'Medium';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  Future<void> saveTask() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
        ),
      );
      return;
    }

    final task = {
      if (widget.task?['id'] != null)
        'id': widget.task!['id'],
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'completed': widget.task?['completed'] ?? 0,
    };

    try {
      await DatabaseHelper.instance.saveTask(task);

      if (!mounted) return;

      Navigator.pop(context, task);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $e'),
        ),
      );
    }
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
            'Add Task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
              'Task Title',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter description (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: selectDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        dueDate == null
                            ? 'Select date'
                            : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      priorityButton('Low', Colors.green),
                      const SizedBox(width: 6),
                      priorityButton('Medium', Colors.blue),
                      const SizedBox(width: 6),
                      priorityButton('High', Colors.red),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0878F9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Task',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            );
        }

  Widget priorityButton(String value, Color color) {
    bool selected = priority == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            priority = value;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? color.withValues(alpha: 0.15)
              : Colors.white,
          foregroundColor: color,
          side: BorderSide(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(value),
      ),
    );
  }
}