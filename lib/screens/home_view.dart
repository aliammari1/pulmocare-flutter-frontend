import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/screens/profile_view.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';
import 'patients_view.dart';
import '../widgets/chat_dialog.dart';
import '../services/chat_viewmodel.dart';
import 'news_view.dart';
import '../widgets/Drawer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  final List<Widget> _pages = [
    const NewsView(),
    PatientsView(),
    ProfileView(),
  ];

  final List<String> _titles = ['News', 'Patients', 'Profile'];

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for the FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Fetch profile data when home view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchProfile();
    });
  }
  
  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _openAIAssistant() {
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Animate the button press
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ChatViewModel(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const ChatDialog(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(), // Changed from drawer to endDrawer
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null, // Remove the leading property
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 30,
                ),
                onPressed: () {
                  // Add haptic feedback for menu button
                  HapticFeedback.lightImpact();
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.turquoise),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: AppTheme.turquoise,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withAlpha((0.2 * 255).toInt()),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.turquoise,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            onTap: (index) {
              // Add haptic feedback when changing tabs
              HapticFeedback.selectionClick();
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                activeIcon: Icon(Icons.newspaper),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Patients',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_fabAnimationController.value * 0.1),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.turquoise.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _openAIAssistant,
                backgroundColor: AppTheme.turquoise,
                elevation: 4,
                child: const Icon(
                  Icons.medical_services_outlined, 
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
