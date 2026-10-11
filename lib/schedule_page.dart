import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_task_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> tasks = [];

  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime.now();

  final List<String> months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  final List<String> weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final result = await DatabaseHelper.instance.getTasks();

    if (!mounted) return;

    setState(() {
      tasks = result;
    });
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<Map<String, dynamic>> tasksForDate(DateTime date) {
    return tasks.where((task) {
      final value = task['dueDate'];

      if (value == null) return false;

      final dateValue = DateTime.tryParse(value.toString());

      return dateValue != null && sameDay(dateValue, date);
    }).toList();
  }

  void changeMonth(int amount) {
    setState(() {
      focusedMonth = DateTime(
        focusedMonth.year,
        focusedMonth.month + amount,
        1,
      );

      selectedDate = focusedMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;

    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;

    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    final selectedTasks = tasksForDate(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadTasks,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => changeMonth(-1),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF246BFD),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${months[focusedMonth.month - 1]} ${focusedMonth.year}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                focusedMonth = DateTime.now();
                                selectedDate = DateTime.now();
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF246BFD),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => changeMonth(1),
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF246BFD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: weekdays.map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Color(0xFF246BFD),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCells,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      final dayNumber = index - firstWeekday + 2;

                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox.shrink();
                      }

                      final date = DateTime(
                        focusedMonth.year,
                        focusedMonth.month,
                        dayNumber,
                      );

                      final isSelected = sameDay(date, selectedDate);
                      final isToday = sameDay(date, DateTime.now());
                      final hasTasks = tasksForDate(date).isNotEmpty;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isToday && !isSelected
                                    ? Border.all(color: Colors.blue)
                                    : null,
                              ),
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: hasTasks
                                    ? Colors.orange
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (selectedTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 42,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No tasks scheduled for this date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...selectedTasks.map((task) {
                final isCompleted =
                    task['completed'] == 1 || task['completed'] == true;

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: const Color(0x33246BFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskPage(task: task),
                        ),
                      );

                      if (result != null) {
                        await loadTasks();
                      }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF246BFD),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
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
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Task?'),
                                content: const Text(
                                  'Are you sure you want to delete this task?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, true);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await DatabaseHelper.instance.deleteTask(task['id']);
                              await loadTasks();
                            }
                          },
                        ),
                      ],
                    ),
                    leading: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.event_note,
                      color: isCompleted ? Colors.green : Colors.blue,
                    ),
                    title: Text(
                      task['title']?.toString() ?? 'Untitled Task',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (task['priority'] ?? 'Medium') == 'High'
                                ? Colors.red.withValues(alpha: 0.12)
                                : (task['priority'] ?? 'Medium') == 'Low'
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${task['priority'] ?? 'Medium'} Priority',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (task['priority'] ?? 'Medium') == 'High'
                                  ? Colors.red
                                  : (task['priority'] ?? 'Medium') == 'Low'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        if ((task['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(task['description'].toString()),
                        ],
                      ],
                    ),
                    isThreeLine:
                    (task['description'] ?? '').toString().isNotEmpty,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}