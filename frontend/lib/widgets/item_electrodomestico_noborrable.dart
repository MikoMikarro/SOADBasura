import 'package:flutter/material.dart';

class ItemElectrodomesticoNoBorrable extends StatelessWidget {
  const ItemElectrodomesticoNoBorrable({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 10, left: 50, right: 50),
      height: 80.0,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: Text(title),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
        ],
      ),
    );
  }
}
