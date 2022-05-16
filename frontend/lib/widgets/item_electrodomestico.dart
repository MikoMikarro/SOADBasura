import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemElectrodomestico extends StatelessWidget {
  const ItemElectrodomestico({
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
          Expanded(
            child: IconButton(
                onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.atencion),
                        content: Text(AppLocalizations.of(context)!
                            .borrarelectrodomestico),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context,
                                AppLocalizations.of(context)!.cancelar),
                            child: Text(AppLocalizations.of(context)!.cancelar),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(
                                context, AppLocalizations.of(context)!.ok),
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                icon: const Icon(Icons.delete)),
          ),
        ],
      ),
    );
  }
}
