import 'package:flutter/material.dart';
import 'add_project_page.dart';
import 'database_helper.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('projects', orderBy: 'id DESC');

      if (!mounted) return;

      setState(() {
        projects = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading projects: $e')),
      );
    }
  }

  Future<void> openAddProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProjectPage(),
      ),
    );

    await loadProjects();
  }

  Future<void> deleteProject(Map<String, dynamic> project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project['name']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [project['id']],
      );

      await loadProjects();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting project: $e')),
      );
    }
  }

  Future<void> saveProjectProgress(
      Map<String, dynamic> project,
      int progress,
      ) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final newStatus = progress == 100
          ? 'Completed'
          : (project['status'] == 'Completed' ? 'Ongoing' : project['status']);

      await db.update(
        'projects',
        {
          'progress': progress,
          'status': newStatus,
        },
        where: 'id = ?',
        whereArgs: [project['id']],
      );

      await loadProjects();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving progress: $e')),
      );
    }
  }

  Widget _buildSummaryCard(
      String title,
      int count,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
            children: [
            Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
                Text(
                  'Keep track of your work and deadlines.',
                  style: TextStyle(fontSize: 14,
                    color: Colors.grey.shade600,
                  height: 1.4,
                  ),
                ),
        Row(
          children: [
            _buildSummaryCard(
              'Ongoing',
              projects.where((p) => (p['status'] ?? 'Ongoing') == 'Ongoing').length,
              Colors.blue,
              Icons.timelapse,
            ),
            const SizedBox(width: 8),
                _buildSummaryCard(
                  'Completed',
                  projects.where((p) => p['status'] == 'Completed').length,
                  Colors.green,
                  Icons.check_circle_outline,
                ),
                const SizedBox(width: 8),
                  _buildSummaryCard(
                    'On Hold',
                    projects.where((p) => p['status'] == 'On Hold').length,
                    Colors.red,
                    Icons.pause_circle_outline,
                  ),
                  ],
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : projects.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      const Icon(
                      Icons.folder_open,
                      size: 80,
                      color: Color(0xFF246BFD),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No projects yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                      const Text(
                        'Add your first project to get started.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: openAddProject,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Project'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF246BFD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProjectPage(
                                  project: project,
                                ),
                              ),
                            );

                            await loadProjects();
                          },
                          child: Card(
                        elevation: 3,
                        shadowColor: Colors.blue.withValues(alpha: 0.12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.blue.withValues(alpha: 0.08),
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF246BFD).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.folder_rounded,
                              color: Color(0xFF246BFD),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            project['name']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              if ((project['description'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  project['description'].toString(),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: (project['status'] ?? 'Ongoing') == 'Completed'
                                      ? Colors.green.withValues(alpha: 0.12)
                                      : (project['status'] ?? 'Ongoing') == 'On Hold'
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : Colors.blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '● ${project['status'] ?? 'Ongoing'}',
                                  style: TextStyle(
                                    color: (project['status'] ?? 'Ongoing') == 'Completed'
                                        ? Colors.green.shade700
                                        : (project['status'] ?? 'Ongoing') == 'On Hold'
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Builder(
                                builder: (context) {
                                  final status = project['status'] ?? 'Ongoing';

                                  final progress = status == 'Completed'
                                      ? 100
                                      : ((project['progress'] as num?)?.toInt() ?? 0);

                                  final progressColor = status == 'Completed'
                                      ? Colors.green
                                      : status == 'On Hold'
                                      ? Colors.red
                                      : Colors.blue;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progress: $progress%',
                                        style: TextStyle(
                                          color: progressColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      LinearProgressIndicator(
                                        value: progress.clamp(0, 100) / 100,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progressColor,
                                        ),
                                        minHeight: 7,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      const SizedBox(height: 8),
                                          if (status != 'Completed')
                                            Slider(
                                              value: progress.clamp(0, 100).toDouble(),
                                              min: 0,
                                              max: 100,
                                              divisions: 20,
                                              label: '$progress%',
                                              activeColor: progressColor,
                                              onChanged: (value) {
                                                setState(() {
                                                  project['progress'] = value.round();
                                                });
                                              },
                                              onChangeEnd: (value) {
                                                saveProjectProgress(project, value.round());
                                              },
                                            ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 8),
                              if (project['dueDate'] != null)
                                Text(
                                  'Due: ${project['dueDate'].toString().split('T').first}',
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete project',
                                onPressed: () => deleteProject(project),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.touch_app_outlined,
                                  color: Color(0xFF246BFD),
                                ),
                                tooltip: 'View project details',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddProjectPage(
                                        project: project,
                                      ),
                                    ),
                                  );
                                  await loadProjects();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      );
                    },
                  ),
                ),

                if (projects.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openAddProject,
                icon: const Icon(Icons.add),
                label: const Text('Add Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}