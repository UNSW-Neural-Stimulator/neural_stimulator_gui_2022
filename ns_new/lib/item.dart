import 'package:flutter/material.dart';


class Item {
  Item({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

final items = <Item>[
  Item(
    title: 'Item 1',
    subtitle: 'This is the first item.',
  ),
];