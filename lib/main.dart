import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF24272D),
          hintStyle: const TextStyle(color: Color(0xFF777C85), fontSize: 13),
          prefixIconColor: const Color(0xFFFF9500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF30343A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF9500), width: 1.5),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

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

                // SUMMARY
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

                            final description =
                                task['description']?.toString() ?? '';

                            final category = task['category']?.toString() ?? '';

                            final priority = task['priority']?.toString() ?? '';

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
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFB020),
                                              Color(0xFFFF7A00),
                                            ],
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

                                            if (description.isNotEmpty) ...[
                                              const SizedBox(height: 5),
                                              Text(
                                                description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF92969F),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 7),

                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 5,
                                              children: [
                                                _SmallTag(
                                                  icon: Icons
                                                      .calendar_month_outlined,
                                                  text: formatDate(date),
                                                ),
                                                if (category.isNotEmpty)
                                                  _SmallTag(
                                                    icon: Icons.folder_outlined,
                                                    text: category,
                                                  ),
                                                if (priority.isNotEmpty)
                                                  _SmallTag(
                                                    icon: Icons.flag_outlined,
                                                    text: priority,
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

// ============================================================
// SMALL TAG
// ============================================================

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFFF9500)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF92969F), fontSize: 11),
        ),
      ],
    );
  }
}

// ============================================================
// SUMMARY ITEM
// ============================================================

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

// ============================================================
// EMPTY VIEW
// ============================================================

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

// ============================================================
// ADD / EDIT TASK PAGE
// ============================================================

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
  // 7 TASK FIELDS
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController categoryController = TextEditingController();

  final TextEditingController priorityController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  final TextEditingController personController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  DateTime? selectedDate;

  bool get isEditing {
    return widget.taskKey != null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text = widget.task!['title']?.toString() ?? '';

      descriptionController.text =
          widget.task!['description']?.toString() ?? '';

      categoryController.text = widget.task!['category']?.toString() ?? '';

      priorityController.text = widget.task!['priority']?.toString() ?? '';

      locationController.text = widget.task!['location']?.toString() ?? '';

      personController.text = widget.task!['person']?.toString() ?? '';

      notesController.text = widget.task!['notes']?.toString() ?? '';

      selectedDate = DateTime.tryParse(widget.task!['date']?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priorityController.dispose();
    locationController.dispose();
    personController.dispose();
    notesController.dispose();

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

    // ALL 7 FIELDS ARE SAVED TO HIVE
    final taskData = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': categoryController.text.trim(),
      'priority': priorityController.text.trim(),
      'location': locationController.text.trim(),
      'person': personController.text.trim(),
      'notes': notesController.text.trim(),
      'date': selectedDate!.toIso8601String(),
    };

    if (isEditing) {
      await box.put(widget.taskKey, taskData);
    } else {
      await box.add(taskData);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ==========================================================
  // FORM FIELD
  // ==========================================================

  Widget buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB6BAC2),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: maxLines > 1 ? 35 : 0),
              child: Icon(icon),
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION HEADER
  // ==========================================================

  Widget buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF777C85), fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 22, 12),
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

            // ==================================================
            // FORM
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA000), Color(0xFFFF7A00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_task_rounded,
                              color: const Color(0xFF17191D),
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 15),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEditing
                                      ? 'Update the details below.'
                                      : 'Fill in the details below.',
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

                    const SizedBox(height: 28),

                    // ==================================================
                    // BASIC INFORMATION
                    // ==================================================
                    buildSectionHeader(
                      'Basic Information',
                      'Start with the main details of your task.',
                    ),

                    const SizedBox(height: 20),

                    buildField(
                      label: 'TASK TITLE',
                      hint: 'Example: Finish laboratory activity',
                      controller: titleController,
                      icon: Icons.assignment_outlined,
                    ),

                    const SizedBox(height: 18),

                    buildField(
                      label: 'DESCRIPTION',
                      hint: 'Describe what needs to be done',
                      controller: descriptionController,
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 26),

                    // ==================================================
                    // TASK DETAILS CARD
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2126),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF30343A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionHeader(
                            'Task Details',
                            'Add information to help organize your task.',
                          ),

                          const SizedBox(height: 20),

                          buildField(
                            label: 'CATEGORY',
                            hint: 'School, Work, Personal',
                            controller: categoryController,
                            icon: Icons.folder_outlined,
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: 'PRIORITY',
                            hint: 'Low, Medium, High',
                            controller: priorityController,
                            icon: Icons.flag_outlined,
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: 'LOCATION',
                            hint: 'Classroom, Office, Home',
                            controller: locationController,
                            icon: Icons.location_on_outlined,
                          ),

                          const SizedBox(height: 18),

                          buildField(
                            label: 'PERSON / CONTACT',
                            hint: 'Teacher, Client, Group Leader',
                            controller: personController,
                            icon: Icons.person_outline_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ==================================================
                    // DATE
                    // ==================================================
                    buildSectionHeader(
                      'Schedule',
                      'Choose when this task should be done.',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'TASK DATE',
                      style: TextStyle(
                        color: Color(0xFFB6BAC2),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: chooseDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24272D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF30343A)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF30291E),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.calendar_month_outlined,
                                color: Color(0xFFFF9500),
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Due date',
                                    style: TextStyle(
                                      color: Color(0xFF777C85),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    selectedDate == null
                                        ? 'Choose a date'
                                        : formatDate(selectedDate!),
                                    style: TextStyle(
                                      color: selectedDate == null
                                          ? const Color(0xFF92969F)
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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

                    const SizedBox(height: 26),

                    // ==================================================
                    // NOTES
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2126),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF30343A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionHeader(
                            'Additional Notes',
                            'Anything else you want to remember.',
                          ),

                          const SizedBox(height: 15),

                          buildField(
                            label: 'NOTES',
                            hint: 'Add any extra information',
                            controller: notesController,
                            icon: Icons.notes_outlined,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // SAVE BUTTON
                    // ==================================================
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
                            borderRadius: BorderRadius.circular(17),
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

                    const SizedBox(height: 14),

                    const Center(
                      child: Text(
                        'Your task details are stored locally using Hive.',
                        textAlign: TextAlign.center,
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
