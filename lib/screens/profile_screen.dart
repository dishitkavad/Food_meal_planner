
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final AuthService _authService = AuthService();
final UserService _userService = UserService();

String _name = 'Loading...';
String _email = '';
bool _isLoading = true;
bool _isUpdating = false;

@override
void initState() {
super.initState();
_loadProfile();
}

Future<void> _loadProfile() async {
final user = _authService.currentUser;

if (user == null) {
if (!mounted) return;

setState(() {
_name = 'No user logged in';
_isLoading = false;
});

return;
}

try {
final profile = await _userService.getUserProfile(user.uid);

if (!mounted) return;

if (profile.exists) {
final data = profile.data();

setState(() {
_name = data?['name'] ?? 'No name';
_email = data?['email'] ?? user.email ?? '';
_isLoading = false;
});
} else {
setState(() {
_name = 'No name';
_email = user.email ?? '';
_isLoading = false;
});
}
} catch (e) {
if (!mounted) return;

setState(() {
_name = 'Unable to load profile';
_email = user.email ?? '';
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Profile loading error: $e'),
),
);
}
}

Future<void> _editName() async {
final controller = TextEditingController(text: _name);

final newName = await showDialog<String>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Edit Name'),
content: TextField(
controller: controller,
autofocus: true,
textCapitalization: TextCapitalization.words,
decoration: const InputDecoration(
labelText: 'Name',
hintText: 'Enter your name',
border: OutlineInputBorder(),
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
final name = controller.text.trim();

if (name.isNotEmpty) {
Navigator.pop(dialogContext, name);
}
},
child: const Text('Save'),
),
],
);
},
);

controller.dispose();

if (newName == null || newName.trim().isEmpty) {
return;
}

final user = _authService.currentUser;

if (user == null) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Please login again.'),
),
);

return;
}

if (newName.trim() == _name) {
return;
}

setState(() {
_isUpdating = true;
});

try {
await _userService.updateUserProfile(
uid: user.uid,
name: newName.trim(),
);

if (!mounted) return;

setState(() {
_name = newName.trim();
_isUpdating = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Name updated successfully!'),
),
);
} catch (e) {
if (!mounted) return;

setState(() {
_isUpdating = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Could not update name:\n$e'),
duration: const Duration(seconds: 5),
),
);
}
}

Future<void> _logout() async {
await _authService.logout();

if (!mounted) return;

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => const LoginScreen(),
),
(route) => false,
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Profile'),
),
body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
children: [
const CircleAvatar(
radius: 50,
child: Icon(
Icons.person,
size: 55,
),
),

const SizedBox(height: 20),

Text(
_name,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
_email,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 35),

Card(
child: ListTile(
leading: const Icon(Icons.person),
title: const Text('Name'),
subtitle: Text(_name),
trailing: _isUpdating
? const SizedBox(
width: 24,
height: 24,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : IconButton(
icon: const Icon(Icons.edit),
onPressed: _editName,
),
),
),

const SizedBox(height: 12),

Card(
child: ListTile(
leading: const Icon(Icons.email),
title: const Text('Email'),
subtitle: Text(_email),
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton.icon(
onPressed: _logout,
icon: const Icon(Icons.logout),
label: const Text(
'Logout',
style: TextStyle(fontSize: 16),
),
),
),
],
),
),
);
}
}

