import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'arqamm904@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': _subjectController.text,
        'body': '''
Name: ${_nameController.text}
Email: ${_emailController.text}
Message: ${_messageController.text}
''',
      }),
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
      _showSuccessToast();
      _clearFields();
    } else {
      _showErrorDialog();
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "Email sent successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.tealAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to send email.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Keeps the screen from resizing
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.white54)),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF0A0E21),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10,
              color: const Color(0xFF0A0E21), // Card color matches the background
              margin: EdgeInsets.zero, // Remove default margin
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _subjectController,
                      label: 'Subject',
                      icon: Icons.subject,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _messageController,
                      label: 'Message',
                      icon: Icons.message,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty &&
                              _emailController.text.isNotEmpty &&
                              _subjectController.text.isNotEmpty &&
                              _messageController.text.isNotEmpty) {
                            _sendEmail();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 50.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          elevation: 5,
                        ),
                        child: const Text(
                          'Send Email',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Fluttertoast.showToast(
            msg: "Need help? Feel free to contact us!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white70),
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2.0),
        ),
      ),
    );
  }
}
