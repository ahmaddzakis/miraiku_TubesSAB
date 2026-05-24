import 'package:flutter/material.dart';
import 'widget_login_form.dart';

class ScreenLogin extends StatelessWidget {
  const ScreenLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul / Branding Aplikasi
              Text(
                'Miraiku',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),

              // Memanggil komponen Form terpisah
              WidgetLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}