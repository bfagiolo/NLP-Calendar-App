import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'enter_task_card.dart';
import 'utils/category_icons.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'services/database_helper.dart';
import 'registration_page.dart';

const String userId = "brandon_fagiolo";
Map<String, List<Map<String, dynamic>>> globalTasksByDate = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NLP Calendar App',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isHovered = false;
  String? usernameError;
  String? passwordError;
  String? loginError;

  Future<void> _handleLogin() async {
    // Reset errors
    setState(() {
      usernameError = null;
      passwordError = null;
      loginError = null;
    });


    bool hasError = false;
    if (usernameController.text.trim().isEmpty) {
      setState(() => usernameError = 'Username is required');
      hasError = true;
    }
    if (passwordController.text.isEmpty) {
      setState(() => passwordError = 'Password is required');
      hasError = true;
    }

    final user = await DatabaseHelper.instance.verifyUser(
      usernameController.text.trim(),
      passwordController.text,
    );

      if (user!=null) {

        try {
          final tasks = await DatabaseHelper.instance.getAllTasks(user['username']);
          globalTasksByDate.clear();  // clear the existing tasks
          globalTasksByDate.addAll(tasks);  // add specific user's tasks
        } catch (e) {
          print('Error loading tasks: $e');
        }
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage(firstName: user['firstName'], userId: user['username'])),
        );
      } else {
        // to show error message in SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed. Please check your username and password.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );

        passwordController.clear();
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SIGN IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: usernameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Username',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  if (usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        usernameError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        passwordError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              if (loginError != null)
                Text(
                  loginError!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 32),
              InkWell(
                onHover: (hover) {
                  setState(() => isHovered = hover);
                },
                onTap: () async {
                  await _handleLogin();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isHovered ? Colors.white : Color(0xFFB8860B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrationPage()),
                  );
                },
                child: Text(
                  'Create account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// AppBar builder for navigation which is constant for all 3 pages
PreferredSizeWidget buildAppBar(BuildContext context, int currentIndex, String? firstName, String userId) {
  return AppBar(
    backgroundColor: Colors.black,
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.home, color: currentIndex == 0 ? Colors.orange : Colors.white),
          onPressed: () {
            if (currentIndex != 0) Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardPage(firstName: firstName, userId: userId)));
          },
        ),
        IconButton(
          icon: Icon(Icons.calendar_today, color: currentIndex == 1 ? Colors.orange : Colors.white),
          onPressed: () {
            if (currentIndex != 1) Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarPage(firstName: firstName, userId: userId)));
          },
        ),
        IconButton(
          icon: Icon(Icons.bar_chart, color: currentIndex == 2 ? Colors.orange : Colors.white),
          onPressed: () {
            if (currentIndex != 2) Navigator.push(context, MaterialPageRoute(builder: (_) => GraphPage(firstName: firstName, userId: userId)));
          },
        ),
      ],
    ),
  );
}

// Dashboard Page
class DashboardPage extends StatefulWidget {
  final String? firstName;
  final String userId;

  // firstName an optional named parameter
  const DashboardPage({
    this.firstName,
    required this.userId,  // userId required
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now().toLocal(); // initialized with current time
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // to cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now().toLocal(); // needs to update the current time every second
      });
    });
  }


  final List<Color> colors = [
    Colors.red.shade300,
    Colors.green.shade300,
    Colors.purple.shade300,
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey = today.toIso8601String().split('T')[0];
    final tasks = globalTasksByDate[todayKey] ?? [];

    // to sort tasks in the same way as CalendarPage
    tasks.sort((a, b) {
      final timeA = _parseTime(a['time']);
      final timeB = _parseTime(b['time']);

      // to compare times directly
      final comparisonResult = timeA.compareTo(timeB);
      print("Comparing $timeA and $timeB: $comparisonResult");
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context, 0, widget.firstName, widget.userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE').format(_currentTime), // e.g., "Tuesday"
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM\nd, y').format(_currentTime).toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('h:mm\na').format(_currentTime).toUpperCase(),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Glad to see you,\n${widget.firstName}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 16),
            Text("Today's Agenda",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Text(
                  "You are totally free today",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final color = colors[Random().nextInt(colors.length)];
                  return Card(
                    color: color,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        task['title']!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: Text(
                        task['time']!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  to Reuse the _parseTime function from CalendarPage
  DateTime _parseTime(String? timeString) {
    final now = DateTime.now();

    if (timeString == null || timeString.isEmpty) {
      // Default to midnight for invalid or missing time
      return DateTime(now.year, now.month, now.day, 0, 0);
    }


    final regex = RegExp(r'^(\d{1,2})(:\d{2})?\s?(AM|PM|am|pm)?$');
    final match = regex.firstMatch(timeString);

    if (match == null) {
      // if the format is invalid, default to midnight
      print("Invalid time format: $timeString");
      return DateTime(now.year, now.month, now.day, 0, 0);
    }

    // to extract hours, minutes, and period (AM/PM)
    int hour = int.tryParse(match.group(1)!) ?? 0;
    int minute = int.tryParse(match.group(2)?.substring(1) ?? '0') ?? 0;
    String period = (match.group(3) ?? '').toLowerCase();

    // use 24-hour format
    if (period == 'pm' && hour != 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;

    final parsedTime = DateTime(now.year, now.month, now.day, hour, minute);
    print("Parsed time for $timeString: $parsedTime");
    return parsedTime;
  }

}




class CalendarPage extends StatefulWidget {
  final String? firstName;
  final String userId;

  const CalendarPage({
    this.firstName,
    required this.userId,
  });
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedTaskIndex;

  void _addTask(Map<String, dynamic> task) {
    final date = task['date'];
    if (globalTasksByDate[date] == null) {
      globalTasksByDate[date] = [];
    }

    setState(() {
      globalTasksByDate[date]!.add(task);
    });
  }


  List<Map<String, dynamic>> _getTasksForDate(String date) {
    final tasks = List<Map<String, dynamic>>.from(globalTasksByDate[date] ?? []);

    print("Before Sorting: $tasks");

    tasks.sort((a, b) {
      final timeA = _parseTime(a['time']);
      final timeB = _parseTime(b['time']);


      final comparisonResult = timeA.compareTo(timeB);
      print("Comparing $timeA and $timeB: $comparisonResult");
      return timeA.compareTo(timeB);
    });


    print("After Sorting: $tasks"); // done

    return tasks; //
  }


  DateTime _parseTime(String? timeString) {
    final now = DateTime.now();

    if (timeString == null || timeString.isEmpty) {

      return DateTime(now.year, now.month, now.day, 0, 0);
    }


    final regex = RegExp(r'^(\d{1,2})(:\d{2})?\s?(AM|PM|am|pm)?$');
    final match = regex.firstMatch(timeString);

    if (match == null) {

      print("Invalid time format: $timeString");
      return DateTime(now.year, now.month, now.day, 0, 0);
    }

    // Extract hours, minutes, and period (AM/PM)
    int hour = int.tryParse(match.group(1)!) ?? 0;
    int minute = int.tryParse(match.group(2)?.substring(1) ?? '0') ?? 0;
    String period = (match.group(3) ?? '').toLowerCase();

    // to convert to 24-hour format
    if (period == 'pm' && hour != 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;

    final parsedTime = DateTime(now.year, now.month, now.day, hour, minute);
    print("Parsed time for $timeString: $parsedTime");
    return parsedTime;
  }






  void _openEnterTaskCard() {
    showDialog(
      context: context,
      builder: (context) {
        return EnterTaskCard(onTaskAdded: _addTask, userId: widget.userId,);
      },
    );
  }

  // Update the existing _deleteTask method in _CalendarPageState
  void _deleteTask(String date, int index) async {
    try {
      // to Get my task before removing it from the map
      final task = globalTasksByDate[date]![index];

      // to Delete from database
      await DatabaseHelper.instance.deleteTask(
          date,
          task['title'],
          task['time'],
          task['userId']
      );


      setState(() {
        globalTasksByDate[date]?.removeAt(index);
        if (globalTasksByDate[date]?.isEmpty ?? false) {
          globalTasksByDate.remove(date);
        }
      });
    } catch (e) {
      print('Error deleting task: $e');
      // error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? _focusedDay;
    final formattedDate = _selectedDay != null
        ? DateFormat('MMM d, y').format(_selectedDay!) // Format date as "Dec 5, 2024"
        : "Select a date";

    final tasksForSelectedDate =
    _getTasksForDate(selectedDate.toIso8601String().split('T')[0]);
    final taskDateKey = selectedDate.toIso8601String().split('T')[0];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context, 1, widget.firstName, widget.userId), // Use the shared AppBar builder
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white60),
                weekendStyle: TextStyle(color: Colors.white60),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "What's the Plan, ${widget.firstName}?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate, // Use the formatted date
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${tasksForSelectedDate.length} Tasks",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: tasksForSelectedDate.isEmpty
                  ? Center(
                child: Text(
                  "No tasks for this date.",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: tasksForSelectedDate.length,
                itemBuilder: (context, index) {
                  final task = tasksForSelectedDate[index];
                  final category = task['category'] ?? "other"; // Default to "other"
                  final icon = categoryIcons[category.toLowerCase()] ?? Icons.miscellaneous_services;
                  final isSelected = _selectedTaskIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTaskIndex = isSelected ? null : index; // Toggle selection
                      });
                    },
                    onLongPress: () {
                      _deleteTask(taskDateKey, index); // deletes task on long press
                    },
                    child: Card(
                      color: isSelected ? Colors.orange.shade700 : Colors.grey.shade900,
                      child: ListTile(
                        leading: Icon(icon, color: Colors.white),
                        title: Text(
                          task['title'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          task['time'],
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEnterTaskCard,
        backgroundColor: Colors.orange.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}








class GraphPage extends StatelessWidget {
  final String? firstName;
  final String userId;  // Add userId

  GraphPage({
    this.firstName,
    required this.userId,  // Make userId required
  });


  final Map<String, Color> taskColors = {
    'entertainment': Colors.purple.shade300,
    'school': Colors.indigo.shade300,
    'exercise': Colors.green.shade300,
    'shopping': Colors.yellow.shade700,
    'food': Colors.red.shade300,
    'travel': Colors.orange.shade300,
    'work': Colors.blue.shade300,
    'health': Colors.teal.shade300,
    'religion': Colors.deepPurple.shade300,
    'chore': Colors.grey,
    'other': Colors.white70,
  };


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    Map<String, int> taskCounts = {};
    globalTasksByDate.forEach((dateKey, tasks) {
      final date = DateTime.parse(dateKey);
      if (date.month == currentMonth && date.year == currentYear) {
        for (var task in tasks) {
          final category = (task['category'] ?? 'other').toString().toLowerCase();
          taskCounts[category] = (taskCounts[category] ?? 0) + 1;
        }
      }
    });

    if (taskCounts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: buildAppBar(context, 2, firstName, userId),
        body: Center(
          child: Text(
            "No tasks this month",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

    final totalTasks = taskCounts.values.fold(0, (sum, count) => sum + count);

    final sortedEntries = taskCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final barGroups = sortedEntries.map((entry) {
      final category = entry.key;
      final count = entry.value;
      final color = taskColors[category] ?? Colors.grey;
      return BarChartGroupData(
        x: sortedEntries.indexOf(entry),
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: count.toDouble(),
            color: color,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context, 2, firstName, userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text(
              '$totalTasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tasks assigned this month',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            Flexible(
              flex: 3, // 3/4 of the available height
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: (barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 2),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toString(),
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        getTitlesWidget: (value, meta) {
                          final category = sortedEntries[value.toInt()].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              category,
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          );
                        },// Set to true if needed
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            SizedBox(height: 16),
            Flexible(
              flex: 1, // 1/4 of the available height
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: sortedEntries.map((entry) {
                  final category = entry.key;
                  final color = taskColors[category] ?? Colors.grey;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


