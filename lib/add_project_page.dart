import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddProjectPage extends StatefulWidget {
  final Map<String, dynamic>? project;

  const AddProjectPage({
    super.key,
    this.project,
  });

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? dueDate;
  String status = 'Ongoing';
  int progress = 0;
  String priority = 'Medium';

  @override
  void initState() {
    super.initState();

    final project = widget.project;

    if (project != null) {
      nameController.text = project['name'] ?? '';
      descriptionController.text = project['description'] ?? '';
      status = project['status'] ?? 'Ongoing';
      progress = (project['progress'] as num?)?.toInt() ?? 0;
      priority = project['priority'] ?? 'Medium';

      if (project['dueDate'] != null) {
        dueDate = DateTime.tryParse(project['dueDate'].toString());
      }
    }
  }
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveProject() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a project name.'),
        ),
      );
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;

      final projectData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'dueDate': dueDate?.toIso8601String(),
        'status': status,
        'priority': priority,
        'progress': status == 'Completed' ? 100 : progress,
      };

      if (widget.project == null) {
        await db.insert('projects', projectData);
      } else {
        await db.update(
          'projects',
          projectData,
          where: 'id = ?',
          whereArgs: [widget.project!['id']],
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month,
                color: Color(0xFF246BFD),
              ),
              title: const Text('Due Date'),
              subtitle: Text(
                dueDate == null
                    ? 'No date selected'
                    : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    dueDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(
                labelText: 'Project Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Ongoing',
                  child: Text('Ongoing'),
                ),
                DropdownMenuItem(
                  value: 'Completed',
                  child: Text('Completed'),
                ),
                DropdownMenuItem(
                  value: 'On Hold',
                  child: Text('On Hold'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 28),

            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: const InputDecoration(
                labelText: 'Project Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    priority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

          const SizedBox(height: 20),

          Text(
            'Project Progress: $progress%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          Slider(
            value: progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '$progress%',
            activeColor: const Color(0xFF246BFD),
            onChanged: status == 'Completed' || status == 'On Hold'
                ? null
                : (value) {
              setState(() {
                progress = value.round();
              });
            },
          ),

          const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveProject,
                icon: const Icon(Icons.save),
                label: const Text('Save Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}