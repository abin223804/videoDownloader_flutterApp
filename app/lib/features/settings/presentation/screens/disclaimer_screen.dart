import 'package:flutter/material.dart';
import '../../../downloader/presentation/screens/home_screen.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                'Terms & Conditions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'MediaSaver Pro is designed for downloading publicly available, non-copyrighted content. \n\n'
                'Users are solely responsible for ensuring they have the legal right to download and use any media. '
                'Downloading copyrighted material without permission is strictly prohibited.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text('I Agree & Understand'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
