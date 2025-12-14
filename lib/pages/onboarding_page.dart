import 'package:flutter/material.dart';
import 'package:productivity_app/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _usernameController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyConfigured();
  }

  Future<void> _checkIfAlreadyConfigured() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('github_username');
    if (username != null && username.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();
    final token = _tokenController.text.trim();
    
    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('github_username', username);
    if (token.isNotEmpty) {
      await prefs.setString('github_token', token);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Connect your GitHub",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your GitHub username to fetch your projects.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "GitHub Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: "Personal Access Token (Optional)",
                hintText: "ghp_...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                helperText: "Required for private repositories",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUsername,
              child: const Text("Continue"),
            ),
            TextButton(
              onPressed: () async {
                 // Skip logic: save empty or specific marker?
                 // Let's just go to MainPage, user can set it up later in Projects tab (if we implement that)
                 // For now, let's force it or just go.
                 Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainPage()),
                 );
              },
              child: const Text("Skip for now"),
            ),
          ],
        ),
      ),
    );
  }
}
