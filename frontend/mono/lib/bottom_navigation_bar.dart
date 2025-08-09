import 'package:flutter/material.dart';

import 'package:mono/playlist/playlists/playlists.dart';

import 'home.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    super.key,
    required this.currentPage,
  });

  final AppPage currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () {
            if (currentPage == AppPage.home) {
              return;
            }
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
            );
          }, icon: Icon(Icons.home)),
          IconButton(
            onPressed: () {
              if (currentPage == AppPage.playlists) {
                return;
              }
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => Playlists()),
                    (route) => false,
              );
            },
            icon: Icon(Icons.library_music),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}