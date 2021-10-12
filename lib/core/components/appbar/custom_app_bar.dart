import 'package:flutter/material.dart';

class CustomAppBar extends PreferredSize {
  final double height = kToolbarHeight + 36;
  final String? title;

  CustomAppBar({Key? key, required this.title})
      : super(
            key: key,
            preferredSize: Size.fromHeight(kToolbarHeight + 36),
            child: AppBar(
              title: Text("title!"),
            ));

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration,
      height: preferredSize.height,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [_appbarIcon, _appbarText],
        ),
      ),
    );
  }

  BoxDecoration get _boxDecoration => BoxDecoration(
        image: _appbarImage,
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      );

  DecorationImage get _appbarImage => DecorationImage(
      image: AssetImage("assets/banner.png"), fit: BoxFit.cover);

  Expanded get _appbarIcon => Expanded(
        child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down_sharp,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {}),
        flex: 1,
      );

  Expanded get _appbarText => Expanded(
      child: Text(
        title!,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      flex: 4);
}
