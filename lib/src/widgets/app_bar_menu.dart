import 'package:flutter/material.dart';

import '../style.dart';

class AppBarMenu<T> extends StatelessWidget {
  const AppBarMenu({
    Key? key,
    required this.itemBuilder,
    this.onSelected,
  }) : super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;

  final PopupMenuItemSelected<T>? onSelected;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(AppStyle.hSpacingHalf),
      child: PopupMenuButton<T>(
        onSelected: onSelected,
        itemBuilder: itemBuilder,
      ),
    );
}
