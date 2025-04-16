import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_event.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_state.dart';
import 'package:list_in/features/chats/presentation/pages/chat_room.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  void initState() {
    super.initState();
    // Connect to WebSocket and load rooms when screen opens
    _connectAndLoadRooms();
  }

  Future<void> _connectAndLoadRooms() async {
    final chatBloc = context.read<ChatBloc>();

    final token = AppSession.accessToken;

    if (token != null) {
      chatBloc.add(ChatConnectEvent(token: token));
      // Load rooms after connection
      chatBloc.add(ChatLoadRoomsEvent());
    } else {
      // Handle case where user is not authenticated
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _createNewRoom() {
    showDialog(
      context: context,
      builder: (context) => NewRoomDialog(
        onRoomCreated: (room) {
          // Navigate to the new room
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                roomId: room.id,
                roomName: room.name,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoom,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatConnectingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoadingRoomsState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatRoomsLoadedState) {
            final rooms = state.rooms;

            if (rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No chat rooms available'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createNewRoom,
                      child: const Text('Create New Room'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(ChatLoadRoomsEvent());
              },
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];

                  return ListTile(
                    title: Text(room.name),
                    subtitle: Text('${room.participants.length} participants'),
                    leading: CircleAvatar(
                      child: Text(room.name.substring(0, 1).toUpperCase()),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            roomId: room.id,
                            roomName: room.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Failed to load chat rooms'));
        },
      ),
    );
  }
}

class NewRoomDialog extends StatefulWidget {
  final Function(ChatRoom) onRoomCreated;

  const NewRoomDialog({
    Key? key,
    required this.onRoomCreated,
  }) : super(key: key);

  @override
  _NewRoomDialogState createState() => _NewRoomDialogState();
}

class _NewRoomDialogState extends State<NewRoomDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedUsers = [];
  List<UserProfile> _availableUsers =
      []; // This should be loaded from your user repository
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    // This is a placeholder - you should load users from your API
    setState(() {
      _isLoading = true;
    });

    try {
      // Example implementation - replace with your actual API call
      // final userRepository = sl<UserRepository>();
      // _availableUsers = await userRepository.getUsers();

      // Placeholder data
      _availableUsers = [
        UserProfile(id: '1', name: 'John Doe'),
        UserProfile(id: '2', name: 'Jane Smith'),
        UserProfile(id: '3', name: 'Bob Johnson'),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  void _createRoom() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room name')),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<ChatBloc>().add(ChatCreateRoomEvent(
          name: name,
          participants: _selectedUsers,
        ));

    // Declare a late variable first
    late StreamSubscription blocSubscription;

    // Listen for room creation completion
    blocSubscription = context.read<ChatBloc>().stream.listen((state) {
      if (state is ChatRoomCreatedState) {
        blocSubscription.cancel();
        widget.onRoomCreated(state.room);
        Navigator.of(context).pop();
      } else if (state is ChatErrorState) {
        blocSubscription.cancel();
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Chat Room'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                hintText: 'Enter a name for the chat room',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Participants:'),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = _availableUsers[index];
                        final isSelected = _selectedUsers.contains(user.id);

                        return CheckboxListTile(
                          title: Text(user.name),
                          value: isSelected,
                          onChanged: (value) {
                            _toggleUserSelection(user.id);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createRoom,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

// Simple UserProfile class
class UserProfile {
  final String id;
  final String name;

  UserProfile({
    required this.id,
    required this.name,
  });
}
