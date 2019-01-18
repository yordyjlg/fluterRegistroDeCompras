import 'package:flutter/material.dart';

class SecondFragment extends StatelessWidget {
  List<Widget> actions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this would produce 2 rows.
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: List.generate(100, (index) {
        return Center(
          child: Text(
            'Item $index',
            style: Theme.of(context).textTheme.headline,
          ),
        );
      }),
    );
  }

}