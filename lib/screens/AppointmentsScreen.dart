import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> dates = List.generate(7, (index) {
    DateTime date = DateTime.now().add(Duration(days: index));
    return {
      'day': "${date.day}/${date.month}",
      'weekday': [
        "Dim",
        "Lun",
        "Mar",
        "Mer",
        "Jeu",
        "Ven",
        "Sam"
      ][date.weekday % 7],
      'fullDate': date,
    };
  });

  String selectedDate = "";

  List<Map<String, String>> appointments = [
    {
      "date": "4/3",
      "name": "Jean Dupont",
      "time": "10:00",
      "photo": "assets/doctor1.jpg"
    },
    {
      "date": "3/3",
      "name": "Alice Moreau",
      "time": "8:00",
      "photo": "assets/doctor2.jpg"
    },
    {
      "date": "3/3",
      "name": "Philippe Martin",
      "time": "9:00",
      "photo": "assets/doctor3.jpg"
    },
    {
      "date": "2/3",
      "name": "Rayene Sssai",
      "time": "12:00",
      "photo": "assets/doctor3.jpg"
    },
    {
      "date": "4/3",
      "name": "Philippe Martin",
      "time": "11:00",
      "photo": "assets/doctor3.jpg"
    },
  ];

  void removeAppointment(int index) {
    setState(() {
      appointments.removeAt(index);
    });
  }

  void addAppointment(String name, String date, String time) {
    setState(() {
      appointments.add({
        "date": date,
        "name": name,
        "time": time,
        "photo": "assets/default.jpg"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Calendrier",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final isSelected = selectedDate == date['day'];
                      final isToday =
                          date['fullDate'].day == DateTime.now().day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date['day'];
                          });
                        },
                        child: Container(
                          width: 65,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E88E5)
                                : isToday
                                    ? const Color(0xFFE3F2FD)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1E88E5)
                                  : const Color(0xFFE0E0E0),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF1E88E5)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date['weekday'],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                date['day'].split('/')[0],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF2C3E50),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              itemCount:
                  appointments.where((a) => a['date'] == selectedDate).length,
              itemBuilder: (context, index) {
                final filteredAppointments = appointments
                    .where((a) => a['date'] == selectedDate)
                    .toList();
                final appointment = filteredAppointments[index];

                return Dismissible(
                  key: Key(appointment['name']!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 28),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      appointments.remove(appointment);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[300]!,
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1E88E5),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  AssetImage(appointment['photo']!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment['name']!,
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Color(0xFF1E88E5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      appointment['time']!,
                                      style: const TextStyle(
                                        color: Color(0xFF1E88E5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAppointment =
              await Navigator.pushNamed(context, '/createRdv');
          if (newAppointment != null && newAppointment is Map<String, String>) {
            addAppointment(newAppointment['name']!, newAppointment['date']!,
                newAppointment['time']!);
          }
        },
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}
