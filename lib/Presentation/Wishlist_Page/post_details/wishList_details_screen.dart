import 'package:flutter/material.dart';
import '../../Home_Screen/event_model.dart';
import 'components/carousel_images.dart';
import 'components/custom_app_bar.dart';
import 'components/wishList_menu_details.dart';


class WishListDetailsScreen extends StatefulWidget {
  final EventModel menu;

  const WishListDetailsScreen({Key? key, required this.menu}) : super(key: key);

  @override
  _WishListDetailsScreenState createState() => _WishListDetailsScreenState();
}

class _WishListDetailsScreenState extends State<WishListDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Stack(
            children: [
              CarouselImages(widget.menu.moreImagesUrl),
              CustomAppBar(),
            ],
          ),
          //Categories(),
          Expanded(child: WishListMenuDetails(widget.menu)),
        ],
      ),
    );
  }
}
