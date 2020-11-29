import 'package:flutter/material.dart';

class CustomAppBar extends PreferredSize {
  final double height = kToolbarHeight + 36;
  final title;

  CustomAppBar({this.title});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/banner.png"), fit: BoxFit.cover),
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      height: preferredSize.height,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              flex: 1,
            ),
            Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                flex: 4)
          ],
        ),
      ),
    );
  }
}

