import 'package:flutter/material.dart';

class ItemElectrodomesticoBorrable extends StatelessWidget {
  const ItemElectrodomesticoBorrable({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      children: <ExpansionPanel>[
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            isExpanded = false;
            return const ListTile(
            // leading: item.iconpic,
            title: Text(
              "First",
              textAlign: TextAlign.left,
              style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
              ),
            ));
          },
      body: const Text("school"),
      isExpanded: false,
        )
      ],
    );
  }
}
