import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter/services.dart'; // For clipboard functionality

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWAPI Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.blueGrey.shade900, fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: FilmDetailsPage(),
    );
  }
}

class FilmDetailsPage extends StatefulWidget {
  @override
  _FilmDetailsPageState createState() => _FilmDetailsPageState();
}

class _FilmDetailsPageState extends State {
  String _filmTitle = '';
  bool _isLoading = false;
  String _error = '';

  Future fetchFilmDetails(int filmId) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final response = await http.get(Uri.parse('https://swapi.dev/api/films/$filmId/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _filmTitle = data['title'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Failed to load film details';
        _isLoading = false;
      });
    }
  }

  // Function to copy film title to clipboard
  void copyToClipboard() {
    if (_filmTitle.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _filmTitle));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard: $_filmTitle')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star Wars Film Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => fetchFilmDetails(1), // Fetch details for Film 1
              child: Text('Fetch Film 1 Details'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator(),
            if (_filmTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Film Title: $_filmTitle',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: copyToClipboard,
                      child: Text('Copy Film Title'),
                    ),
                  ],
                ),
              ),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
