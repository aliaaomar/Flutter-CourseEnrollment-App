import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase using the manual JSON setup you just did
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Course App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER: Checks if you are logged in or not ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // Logged in? Go to Courses.
        }
        return const LoginScreen(); // Not logged in? Go to Login.
      },
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // No navigation needed, AuthWrapper handles it
    } catch (e) {
      setState(() => errorMessage = "Login failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Don't have an account? Register"),
            )
          ],
        ),
      ),
    );
  }
}

// --- 2. REGISTER SCREEN ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> register() async {
    try {
      // 1. Create Auth User
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Store Profile in Firestore (Users Collection)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
      });

      if (mounted) Navigator.pop(context); // Go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Student")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("Register & Save Profile")),
          ],
        ),
      ),
    );
  }
}

// --- 3. HOME SCREEN (Course List) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> enroll(String courseName, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Store enrollment in users -> uid -> enrolled_courses
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('enrollments') // Subcollection for enrollments
          .add({
        'courseName': courseName,
        'enrolledAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enrolled in $courseName!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      // Read courses from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final courses = snapshot.data!.docs;

          if (courses.isEmpty) {
            return const Center(child: Text("No courses available. Add one!"));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var data = courses[index].data() as Map<String, dynamic>;
              String cName = data['courseName'] ?? 'Unnamed Course';
              return Card(
                child: ListTile(
                  title: Text(cName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: ElevatedButton(
                    onPressed: () => enroll(cName, context),
                    child: const Text("Enroll"),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen())),
      ),
    );
  }
}

// --- 4. ADD COURSE SCREEN ---
class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _courseController = TextEditingController();

  Future<void> addCourse() async {
    if (_courseController.text.isEmpty) return;
    
    // Add to 'courses' collection
    await FirebaseFirestore.instance.collection('courses').add({
      'courseName': _courseController.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Course")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _courseController, decoration: const InputDecoration(labelText: "Course Name (e.g. Mobile Computing)")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: addCourse, child: const Text("Save to Database")),
          ],
        ),
      ),
    );
  }
}
