import 'package:flutter/material.dart';
import '../../../../Themes/styles.dart';
import '../../../Home_Screen/event_model.dart';

class WishListMenuDetails extends StatefulWidget {
  final EventModel event;

  const WishListMenuDetails(this.event, {super.key});

  @override
  _WishListMenuDetailsState createState() => _WishListMenuDetailsState();
}

class _WishListMenuDetailsState extends State<WishListMenuDetails> {
  @override
  Widget build(BuildContext context) {
    final menu = widget.event;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.black,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: appPadding, right: appPadding, bottom: appPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.eventName,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Location: ${menu.location},',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            menu.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        menu.eventDescription,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          height: 1.5,
                        ),
                        maxLines: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
