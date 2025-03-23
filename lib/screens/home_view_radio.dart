import 'package:flutter/material.dart';
import 'package:medapp/services/notification_provider.dart';
import 'package:medapp/screens/AppointmentsScreen.dart';
import 'package:medapp/screens/ArchiveScreen.dart';
import 'package:medapp/screens/RapportScreen.dart';
import 'package:medapp/screens/homeScreen.dart';
import 'package:medapp/screens/profile_radio.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../services/auth_radio_view_model.dart';

class HomeViewRadio extends StatefulWidget {
  const HomeViewRadio({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeViewRadio> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ArchiveScreen(),
    RapportScreen(),
    AppointmentsScreen(),
    ProfileRadioView()
  ];

  @override
  void initState() {
    super.initState();
    // Fetch profile data when home view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthRadioViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true, // Show drawer icon
        title: Text(
          "Pulmocare",
          style: TextStyle(
            color: Colors.lightBlue, // Bleu caractéristique de Facebook
            fontSize: 28, // Taille plus grande
            fontWeight: FontWeight.w900, // Très bold comme le logo Facebook
            fontFamily: 'SanFrancisco', // Optionnel : Police proche de Facebook
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                      TextButton(
                        child: const Text('Yes, Logout'),
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await context.read<AuthRadioViewModel>().logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedItemColor: Colors.lightBlue,
                unselectedItemColor: Colors.grey.shade400,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                iconSize: 24,
                onTap: (index) {
                  // Si l'utilisateur clique sur l'onglet Rapports, effacer les notifications
                  if (index == 1) {
                    notificationProvider.clearRapportNotifications();
                  }
                  // Handle center action button
                  else if (index == 2) {
                    // Navigate to RapportScreen for adding new reports
                    Navigator.pushNamed(context, '/rapportScreen');
                    return; // Don't update the current index
                  }
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.assignment_outlined),
                        if (notificationProvider.rapportNotificationCount > 0)
                          Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  '${notificationProvider.rapportNotificationCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.assignment),
                        if (notificationProvider.rapportNotificationCount > 0)
                          Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  '${notificationProvider.rapportNotificationCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: 'Rapports',
                  ),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle,
                          color: Colors.lightBlue, size: 50),
                      label: ""),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.event_outlined),
                    activeIcon: Icon(Icons.event),
                    label: 'RDV',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Account',
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension on Function() {
  // ignore: unused_element
  read() {}
}
