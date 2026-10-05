import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open the box for tasks
  await Hive.openBox('taskBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF17191D),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFFFFB33B),
          surface: Color(0xFF24272D),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF17191D),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF9500),
          foregroundColor: Color(0xFF17191D),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF24272D),
          hintStyle: const TextStyle(color: Color(0xFF777C85)),
          labelStyle: const TextStyle(color: Color(0xFFB6BAC2)),
          prefixIconColor: const Color(0xFFFF9500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF30343A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFFF9500), width: 1.5),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Box get taskBox => Hive.box('taskBox');

  String formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int countToday(Box box) {
    int total = 0;

    final now = DateTime.now();

    for (final task in box.values) {
      if (task is Map) {
        final date = DateTime.tryParse(task['date']?.toString() ?? '');

        if (date != null &&
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          total++;
        }
      }
    }

    return total;
  }

  void openAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormPage()),
    );
  }

  void openEditPage(
    BuildContext context,
    dynamic taskKey,
    Map<String, dynamic> task,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(taskKey: taskKey, task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: taskBox.listenable(),
          builder: (context, Box box, child) {
            final keys = box.keys.toList().reversed.toList();
            final todayCount = countToday(box);

            return Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF17191D),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TaskFlow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Plan your day. Get things done.',
                              style: TextStyle(
                                color: Color(0xFF92969F),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24272D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: Color(0xFFFF9500),
                        ),
                      ),
                    ],
                  ),
                ),

                // SUMMARY CARD
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA000), Color(0xFFFF7A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9500).withOpacity(0.22),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFF251A0A)),
                            SizedBox(width: 6),
                            Text(
                              'TODAY',
                              style: TextStyle(
                                color: Color(0xFF392200),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Stay productive',
                          style: TextStyle(
                            color: Color(0xFF17191D),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          box.isEmpty
                              ? 'Start by creating your first task.'
                              : 'You have ${box.length} ${box.length == 1 ? 'task' : 'tasks'} saved locally.',
                          style: const TextStyle(
                            color: Color(0xFF5D3700),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(
                                number: box.length.toString(),
                                label: 'Total Tasks',
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 38,
                              color: Colors.black12,
                            ),

                            Expanded(
                              child: _SummaryItem(
                                number: todayCount.toString(),
                                label: 'Due Today',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // SECTION TITLE
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'MY TASKS',
                          style: TextStyle(
                            color: Color(0xFF92969F),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),

                      Text(
                        '${box.length} total',
                        style: const TextStyle(
                          color: Color(0xFFFF9500),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // TASK LIST
                Expanded(
                  child: box.isEmpty
                      ? _EmptyView(
                          onAdd: () {
                            openAddPage(context);
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 110),
                          itemCount: keys.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            final key = keys[index];

                            final storedTask = box.get(key);

                            if (storedTask is! Map) {
                              return const SizedBox.shrink();
                            }

                            final task = Map<String, dynamic>.from(storedTask);

                            final title = task['title']?.toString() ?? '';

                            final date = task['date']?.toString() ?? '';

                            return Dismissible(
                              key: ValueKey(key),

                              direction: DismissDirection.endToStart,

                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4D45),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              onDismissed: (direction) async {
                                // DELETE
                                await box.delete(key);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Task deleted'),
                                    ),
                                  );
                                }
                              },

                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),

                                onTap: () {
                                  openEditPage(context, key, task);
                                },

                                child: Container(
                                  padding: const EdgeInsets.all(17),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF24272D),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFF30343A),
                                    ),
                                  ),

                                  child: Row(
                                    children: [
                                      // ORANGE ICON
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFB020),
                                              Color(0xFFFF7A00),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            17,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.assignment_turned_in_outlined,
                                          color: Color(0xFF221709),
                                        ),
                                      ),

                                      const SizedBox(width: 15),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 7),

                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: Color(0xFFFF9500),
                                                  size: 15,
                                                ),

                                                const SizedBox(width: 6),

                                                Text(
                                                  formatDate(date),
                                                  style: const TextStyle(
                                                    color: Color(0xFF92969F),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF30343A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                          color: Color(0xFFFF9500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          openAddPage(context);
        },
        icon: const Icon(Icons.add_rounded, size: 25),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// SUMMARY ITEM
class _SummaryItem extends StatelessWidget {
  final String number;
  final String label;

  const _SummaryItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Color(0xFF17191D),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF5D3700), fontSize: 11),
        ),
      ],
    );
  }
}

// EMPTY SCREEN
class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFF24272D),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF30343A)),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 44,
                color: Color(0xFFFF9500),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No tasks yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Create your first task and it will be saved locally using Hive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF92969F),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                foregroundColor: const Color(0xFF17191D),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ADD / EDIT TASK SCREEN
class TaskFormPage extends StatefulWidget {
  final dynamic taskKey;
  final Map<String, dynamic>? task;

  const TaskFormPage({super.key, this.taskKey, this.task});

  @override
  State<TaskFormPage> createState() {
    return _TaskFormPageState();
  }
}

class _TaskFormPageState extends State<TaskFormPage> {
  final TextEditingController titleController = TextEditingController();

  DateTime? selectedDate;

  bool get isEditing {
    return widget.taskKey != null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text = widget.task!['title']?.toString() ?? '';

      selectedDate = DateTime.tryParse(widget.task!['date']?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    titleController.dispose();

    super.dispose();
  }

  String formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> chooseDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();

    // VALIDATION
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title.')),
      );

      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a task date.')),
      );

      return;
    }

    final box = Hive.box('taskBox');

    final taskData = {'title': title, 'date': selectedDate!.toIso8601String()};

    if (isEditing) {
      // UPDATE
      await box.put(widget.taskKey, taskData);
    } else {
      // CREATE
      await box.add(taskData);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 22, 18),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF24272D),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Task' : 'New Task',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Update your task details'
                              : 'Add something to your plan',
                          style: const TextStyle(
                            color: Color(0xFF92969F),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.bolt_rounded, color: Color(0xFFFF9500)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ORANGE HERO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA000), Color(0xFFFF7A00)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_task_rounded,
                              color: const Color(0xFF17191D),
                              size: 29,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing
                                      ? 'Make some changes'
                                      : 'Create something new',
                                  style: const TextStyle(
                                    color: Color(0xFF17191D),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEditing
                                      ? 'Edit the information below.'
                                      : 'Enter the task details below.',
                                  style: const TextStyle(
                                    color: Color(0xFF5D3700),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'TASK TITLE',
                      style: TextStyle(
                        color: Color(0xFF92969F),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 9),

                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Example: Finish laboratory activity',
                        prefixIcon: Icon(Icons.assignment_outlined),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'TASK DATE',
                      style: TextStyle(
                        color: Color(0xFF92969F),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 9),

                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: chooseDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24272D),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF30343A)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF30291E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_outlined,
                                color: Color(0xFFFF9500),
                                size: 20,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Choose a date'
                                    : formatDate(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? const Color(0xFF777C85)
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFFF9500),
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9500),
                          foregroundColor: const Color(0xFF17191D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: Icon(
                          isEditing
                              ? Icons.save_rounded
                              : Icons.add_task_rounded,
                        ),
                        label: Text(
                          isEditing ? 'Save Changes' : 'Create Task',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Center(
                      child: Text(
                        'Your tasks are stored locally using Hive.',
                        style: TextStyle(
                          color: Color(0xFF777C85),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
