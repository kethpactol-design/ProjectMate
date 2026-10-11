import 'package:flutter/material.dart';
import 'my_tasks_page.dart';
import 'database_helper.dart';
import 'schedule_page.dart';
import 'projects_page.dart';
import 'profile_page.dart';


class NextScreen extends StatefulWidget {
  final String? userEmail;

  const NextScreen({
    super.key,
    this.userEmail,
  });

  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {

  List<Map<String, dynamic>> todayTasks = [];
  List<Map<String, dynamic>> ongoingProjects = [];

  @override
  void initState() {
    super.initState();
    loadTodayTasks();
    loadOngoingProjects();
  }

  Future<void> loadTodayTasks() async {
    final tasks = await DatabaseHelper.instance.getTasks();

    if (!mounted) return;

    setState(() {
      todayTasks = tasks;
    });
  }

  Future<void> loadOngoingProjects() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'projects',
      where: 'status = ?',
      whereArgs: ['Ongoing'],
      orderBy: 'id DESC',
      limit: 2,
    );

    if (!mounted) return;

    setState(() {
      ongoingProjects = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 55, 24, 35),
              decoration: const BoxDecoration(
                color: Color(0xFF0878D1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.school,
                          size: 35,
                          color: Color(0xFF0878D1),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'ProjectMate! 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Let's make progress today.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Four Main Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyTasksPage(),
                          ),
                        );
                      },
                      child: menuItem(
                        Icons.assignment_outlined,
                        'My Tasks',
                        const Color(0xFF12A9E8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SchedulePage(),
                          ),
                        );
                      },
                      child: menuItem(
                        Icons.calendar_month,
                        'Schedule',
                        const Color(0xFFFF04462),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProjectsPage(),
                          ),
                        ).then((_) {
                          loadOngoingProjects();
                        });
                      },
                      child: menuItem(
                        Icons.folder_open,
                        'Projects',
                        const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                      child: menuItem(
                        Icons.person_outline,
                        'Profile',
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Today's Tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172554),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTasksPage(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

// Display Today's Tasks
            FutureBuilder(
              future: DatabaseHelper.instance.getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'No tasks yet. Add your first task!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final tasks = snapshot.data!;

                final today = DateTime.now();

                final todayTasks = tasks.where((task) {
                  if (task['dueDate'] == null) return false;

                  final dueDate = DateTime.tryParse(
                    task['dueDate'].toString(),
                  );

                  return dueDate != null &&
                      dueDate.year == today.year &&
                      dueDate.month == today.month &&
                      dueDate.day == today.day;
                }).toList();

                if (todayTasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Text(
                      'No tasks scheduled for today.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: todayTasks.map((task) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: Icon(
                          task['completed'] == 1 ||
                              task['completed'] == true
                              ? Icons.check_circle
                              : Icons.assignment_outlined,
                          color: const Color(0xFF12A9E8),
                        ),
                        title: Text(task['title'].toString()),
                        subtitle: Text(
                          task['description']?.toString() ?? '',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 25),

            // Ongoing Projects
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Ongoing Projects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172554),
                ),
              ),
            ),

            ...ongoingProjects.map((project) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name']?.toString() ?? 'Untitled Project',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project['description']?.toString() ?? 'No description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Priority: ${project['priority']?.toString() ?? 'Not set'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF246BFD),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (ongoingProjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'No ongoing projects yet. Add a project to get started!',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget menuItem(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget taskItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            color: Color(0xFF64748B),
            size: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}