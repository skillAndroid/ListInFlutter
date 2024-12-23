import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;

  const MainWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/events')) return 1;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    Future.microtask(() {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/events');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Events"),
    );
  }
}
