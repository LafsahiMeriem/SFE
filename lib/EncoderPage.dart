import 'package:flutter/material.dart';

class EncodePage extends StatelessWidget {
  const EncodePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encoder'),
      ),
      body: const Center(
        child: Text('Encoder Page'),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: Container(
            height: 60, // Set the height of the BottomAppBar
            child: EncoderBottomBar(),
          ),
        ),
      ),
    );
  }
}

class EncoderBottomBar extends StatelessWidget {
  const EncoderBottomBar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBottomBarItem(
          icon: Icons.search,
          label: 'Chercher',
          onPressed: () {
            // Add logic for search action
          },
        ),
        _buildBottomBarItem(
          icon: Icons.qr_code,
          label: 'Encoder',
          onPressed: () {
            // Add logic for encoding action
          },
        ),
        _buildBottomBarItem(
          icon: Icons.qr_code_outlined,
          label: 'Non-Encoder',
          onPressed: () {
            // Add logic for non-encoding action
          },
        ),
      ],
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12), // Adjust the font size as needed
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EncodePage(),
  ));
}
