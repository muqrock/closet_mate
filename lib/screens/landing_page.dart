import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Softened RadialGradient for a more welcoming look
          gradient: RadialGradient(
            center: Alignment.topCenter, // Start gradient more from the top
            radius: 1.5, // Increased radius for a wider spread
            colors: [
              Color(0xFFFFDE59), // Yellow
              Color(0xFFFF914D), // Orange
            ],
            stops: [0.0, 0.9], // Control the spread of colors
          ),
        ),
        child: SafeArea(
          // Ensures content is within safe boundaries
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Vertically center content
            children: [
              // Spacer to push content down slightly, or adjust initial SizedBox
              const Spacer(flex: 2),

              // Logo with some breathing room
              Image.asset(
                'assets/closetmate.jpg',
                height: 150, // Slightly increased height for prominence
                fit: BoxFit.contain, // Ensures the entire image is visible
              ),
              const SizedBox(height: 30), // Increased spacing after logo
              // App Title
              Text(
                'Closet Mate',
                style: TextStyle(
                  fontSize: 42, // Larger font size for impact
                  fontWeight:
                      FontWeight.w800, // Heavier weight for title prominence
                  color:
                      Colors.white, // White text for contrast against gradient
                  // Assuming 'Montserrat' is configured in ThemeData in main.dart
                  // fontFamily: 'Montserrat',
                  shadows: [
                    // Subtle text shadow for depth
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), // Spacing between title and tagline
              // Tagline
              Text(
                'Your digital wardrobe companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, // Slightly larger for readability
                  color: Colors.white.withOpacity(
                    0.9,
                  ), // Softer white for tagline
                  // fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400, // Normal weight for readability
                ),
              ),

              const Spacer(flex: 3), // Pushes buttons further down
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFE95C20,
                        ), // ✅ Updated color
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      icon: const Icon(Icons.app_registration),
                      label: const Text('Register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // sharper to contrast login
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1), // Minor space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for consistent label styling, if needed elsewhere
  // Widget _buildLabel(String text) => Padding(
  //       padding: const EdgeInsets.only(bottom: 6),
  //       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  //     );
}
