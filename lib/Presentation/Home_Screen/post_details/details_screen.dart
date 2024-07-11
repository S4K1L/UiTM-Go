import 'package:flutter/material.dart';
import '../event_model.dart';
import 'components/carousel_images.dart';
import 'components/custom_app_bar.dart';
import 'components/menu_details.dart';


class DetailsScreen extends StatefulWidget {
  final EventModel event;

  const DetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Stack(
            children: [
              CarouselImages(widget.event.moreImagesUrl),
              CustomAppBar(),
            ],
          ),
          //Categories(),
          Expanded(child: MenuDetails(widget.event)),
        ],
      ),
    );
  }
}
