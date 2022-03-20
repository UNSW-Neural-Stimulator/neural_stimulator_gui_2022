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
    title: 'example_device',
    subtitle: 'This is the first item.',
  ),
];