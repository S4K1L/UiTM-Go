import 'package:flutter/material.dart';

import '../../Themes/const.dart';
import 'event_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Column(
          children: [
            Text('Event',style: TextStyle(color: Colors.white),),
            Divider(color: Colors.white,),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Expanded(
            child: EventPost(),
          ),
        ],
      ),
    );
  }
}
