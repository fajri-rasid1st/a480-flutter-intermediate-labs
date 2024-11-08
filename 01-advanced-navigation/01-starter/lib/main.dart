import 'package:declarative_navigation/screen/quotes_list_screen.dart';
import 'package:flutter/material.dart';

import 'model/quote.dart';

void main() {
  runApp(const QuotesApp());
}

class QuotesApp extends StatefulWidget {
  const QuotesApp({Key? key}) : super(key: key);

  @override
  State<QuotesApp> createState() => _QuotesAppState();
}

class _QuotesAppState extends State<QuotesApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes App',
      home: Navigator(
        pages: [
          MaterialPage(
            key: const ValueKey("QuotesListPage"),
            child: QuotesListScreen(
              quotes: quotes,
            ),
          ),
        ],
        onPopPage: (route, result) {},
      ),
    );
  }
}
