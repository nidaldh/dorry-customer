import 'package:dorry/utils/sizes.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class BaseScaffoldWidget extends StatelessWidget {
  final String? title;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final bool showAppBar;

  const BaseScaffoldWidget({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
    this.floatingActionButton,
    this.showBackButton = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: Sizes.textSize_20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
              leading: showBackButton ? BackButton() : null,
              actions: [
                ...actions,
              ],
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
