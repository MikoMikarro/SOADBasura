// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:math';

import 'package:buildgreen/widgets/back_button.dart';
import 'package:buildgreen/widgets/general_background.dart';
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:buildgreen/screens/sim_lista.dart';
import 'package:buildgreen/screens/lista_electrodomesticos.dart' as lec;

import 'package:animated_flip_counter/animated_flip_counter.dart';

BoxDecoration panelDecoracion(){
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    boxShadow: const [BoxShadow(
      color: Colors.black45, 
      blurRadius: 5,
      offset: Offset(3, 3),
      ),
    ],
  );
}

TextStyle animatorTextStyle( double variable){
  return TextStyle(
    fontWeight: FontWeight.bold, fontSize: 30,
    color: variable == 0 ? Colors.black : ( variable < 0 ? Colors.red: Colors.green),
  );
}

Future<String> switchAppliance(Item oldAppliance, Item newAppliance) async{
  if (oldAppliance != newAppliance){
    await deleteAppliance(oldAppliance);
    return await lec.addAppliance(newAppliance);
  }
  return "";
}
class CompareApplianceScreen extends StatefulWidget {
  final Item startObject; 
  
  const CompareApplianceScreen(
    {
      Key? key,
      required this.startObject,
    }
  ) :super(key: key);

  @override
  State<CompareApplianceScreen> createState() {
    return _CompareApplianceScreenState();
    }
}

class _CompareApplianceScreenState extends State<CompareApplianceScreen> {

  var startIndex = -1;

  List<Item> allObjects = [];

  Item? newItem;

  String? newId;

  _CompareApplianceScreenState() {
    lec.generateItems().then((val) => setState(() {
          allObjects = val;
          startIndex = Random().nextInt(allObjects.length);
        },
      ),
    );
  }

  bool isSame(){
    final leftItem = newItem??widget.startObject;
    final rightItem = (startIndex!=-1) ? allObjects[startIndex] : widget.startObject;  
    
    return (leftItem.id == rightItem.id);
  }
  
  @override
  Widget build(BuildContext context) {
    var targetItem = newItem??widget.startObject;
    var ahorroPrecio = double.parse(targetItem.price) - (startIndex != -1 ? double.parse(allObjects[startIndex].price): 0);

    var ahorroConsumo = double.parse(targetItem.cons) - (startIndex != -1 ? double.parse(allObjects[startIndex].cons): 0);

    TextStyle? headline2 = Theme.of(context).textTheme.headline5;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const GeneralBackground(),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    children:  [
                      CustomBackButton(returnValue: (newId != null) ? newId : widget.startObject.id),
                      const Padding(padding: EdgeInsets.all(10)),
                      Text(
                        "Cambio",
                        style: Theme.of(context).textTheme.headline2,
                        )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  // Both appliances
                  Expanded(
                    flex:  2,
                    child: Row(
                      children:  [
                        // First item 
                        Expanded( 
                          child: Container(
                            decoration: panelDecoracion(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                applianceDetail(newItem??widget.startObject),
                              ]
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(5)),

                        Expanded( 
                          child: Container(
                            decoration: panelDecoracion(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(3,3,),
                                                blurRadius: 5.0,
                                              )
                                            ],
                                            color: Colors.green,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                bottomLeft: Radius.circular(20.0)),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.arrow_back_rounded,),
                                            color: Colors.white,
                                            onPressed: (){
                                              setState(() {
                                                startIndex -= 1;
                                                if (startIndex < 0){
                                                  startIndex = allObjects.length-1;
                                                }
                                                }
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(3,3,),
                                                blurRadius: 5.0,
                                              )
                                            ],
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomRight: Radius.circular(20.0)),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.arrow_forward_rounded),
                                            color: Colors.white,
                                            onPressed: ()=>{setState(()=>{startIndex = (startIndex + 1) % allObjects.length })},
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Expanded(
                                  child: startIndex != -1 ? applianceDetail(allObjects[startIndex]) : Container(),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration:  BoxDecoration(
                                          boxShadow:  const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(3,3,),
                                              blurRadius: 5.0,
                                            )
                                          ],
                                          color: (isSame())? Colors.green:Colors.grey,
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        ),
                                        child: TextButton( 
                                          
                                          child: Text("CHOOSE", style: Theme.of(context).textTheme.bodyLarge,),
                                          onPressed: () async {
                                            setState(() {
                                              newItem = allObjects[startIndex];
                                            });
                                            newId = await switchAppliance(newItem??widget.startObject,  allObjects[startIndex]);
                                            setState(() {
                                              newItem = allObjects[startIndex];
                                              newItem?.id = newId??"";
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    ]
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: panelDecoracion(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          comparadorAhorro( headline2, 
                            ahorroPrecio, 
                            "Ahorro precio",
                            "€"
                          ),
                          const VerticalDivider(
                            color: Color.fromARGB(83, 85, 135, 87),
                            indent: 10,
                            endIndent: 10,

                            thickness: 3,
                          ),
                          comparadorAhorro(
                            headline2, 
                            ahorroConsumo, 
                            "Ahorro consumo",
                            "kw"),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}


Widget comparadorAhorro(TextStyle? titleStyle, double variable, String title, String suffix,) {
  return Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Padding(padding: EdgeInsets.all(1)),
        Text(title, style: titleStyle ),
        Flex(direction: Axis.vertical,
          children: [
            AnimatedFlipCounter(
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds:500
              ),
              value: variable,
              thousandSeparator: '.',
              decimalSeparator: ',',
              fractionDigits: 1, 
              textStyle: animatorTextStyle( variable ),
            ),
          Text(suffix, style: animatorTextStyle(variable),
          )
        ],
      ),
      const Padding(padding: EdgeInsets.all(1)),  
      ],
    ),
  );
}
Column applianceDetail(Item appliance){
  return Column(
      children: [
        // ICON + Subtitles
        Flex(
          direction: Axis.vertical,
          children: [
            const FittedBox(
              fit: BoxFit.fitHeight,
              child: Image(
                image: AssetImage("assets/images/electrodomestico.png"),
              ),
            ),
            const Padding(padding: EdgeInsets.all(5)),

            // BRAND AND NAME
            Text(appliance.brand),
            Text(appliance.headerValue),
          ],
        ),
        // POWER CONSUMPTION
        Flex(
          direction: Axis.vertical,
          children: [
            const FittedBox(
              child:Text("Price",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              fit: BoxFit.fitHeight,
            ),
            Text(appliance.price),
            const Padding(padding: EdgeInsets.all(5)),
            const FittedBox(
              child:Text("Power [KW]",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              fit: BoxFit.fitHeight,
            ),
            Text(appliance.cons)
          ],
        ),
      ],
    );
}

