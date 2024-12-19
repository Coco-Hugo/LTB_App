import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // AppBar size

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff181818),
      // title: Image.asset(
      //   'assets/brand/ltb_logo_transparent.png', // Replace with your image asset path
      //   height: 50, // Adjust height as needed
      // ),
      centerTitle: true, // Center the image in the AppBar
    );
  }
}
