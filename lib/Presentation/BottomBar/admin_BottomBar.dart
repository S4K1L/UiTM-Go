import 'package:flutter/material.dart';
import '../Admin_Panel/Account_Manage/account_manage.dart';
import '../Admin_Panel/Event_Manage/event_manage.dart';
import '../Create_Events/create_events.dart';
import '../Home_Screen/home_Screen.dart';



class AdminBottomBar extends StatefulWidget {
  const AdminBottomBar({super.key});

  @override
  State<AdminBottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<AdminBottomBar> {
  int index_color = 0;
  List Screen = [HomeScreen(),CreateEvents(),EventManage(),AccountManage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Screen[index_color],
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 0;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 30,
                    color: index_color == 0 ? Colors.amber[300] : Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 1;
                    });
                  },
                  child: Icon(
                    Icons.widgets_sharp,
                    size: 30,
                    color: index_color == 1 ? Colors.amber[300] : Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 2;
                    });
                  },
                  child: Icon(
                    Icons.event_repeat_sharp,
                    size: 30,
                    color: index_color == 2 ? Colors.amber[300] : Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 3;
                    });
                  },
                  child: Icon(
                    Icons.manage_accounts,
                    size: 30,
                    color: index_color == 3 ? Colors.amber[300] : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}