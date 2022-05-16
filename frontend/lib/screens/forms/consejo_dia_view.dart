// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:buildgreen/arguments/advice_detail_argument.dart';
import 'package:buildgreen/classes/advice.dart';
import 'package:buildgreen/widgets/general_background.dart';
import 'package:flutter/material.dart';
import 'package:buildgreen/screens/appliance_compare_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;
class ConsejoDetalle extends StatefulWidget {

  static const route = '/advice_detail';

  const ConsejoDetalle({ Key? key }) : super(key: key);

  @override
  State<ConsejoDetalle> createState() => _ConsejoDetalleState();
}

class _ConsejoDetalleState extends State<ConsejoDetalle> {
  int value = 0;

  BorderRadius bRadius(String position, double radius){
    if (position == "left"){
      return BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius)
      );
    }

    else if (position == "right"){
      return BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius)
      );
    }

    else if (position == "middle"){
      return BorderRadius.zero;
    }

    return BorderRadius.circular(radius);

  }

  // ignore: non_constant_identifier_names
  Widget CustomRadioButton(String text, int index, String position) {
    return Expanded(
      child: OutlinedButton(

        onPressed: () {
          setState(() {
            value = index;
          });
        },
        child: Text(
          text,
          style: const TextStyle(
            color:Colors.black,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            (value == index) ? Colors.green : Colors.white10),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: bRadius(position, 10))),
        ),
      ),
    );
  }

  Future<void> _completarChallange(Advice item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await http.post(Uri.parse(Constants.API_ROUTE+'/advices_user/'),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              "Token " + prefs.getString('_user_token'),
        },
        body: <String, String>{
          "advice": item.id,
          "completed": "True",
          "time": (value == 3) ? "0" : item.timeOptions[value].toString().split(" ")[0],
        },
      );
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AdviceDetailArgument;
    Advice advice = args.advice;

    return Scaffold(
      body: Stack(
        children: [
          const GeneralBackground(),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: panelDecoracion(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment:  CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            
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
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0)),
                              ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  iconSize: 40,
                                  onPressed: ()=>Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: Colors.white,
                                ),
                                
                                Expanded(
                                  child: Text(advice.title,
                                    style: Theme.of(context).textTheme.displayLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              ]
                            ),
                          ),
                        )
                      ],
                    ),
                    
                    // IMAGE
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: AspectRatio(
                        aspectRatio: 16/9,
                        child: Container(
                          decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(3,3,),
                                    blurRadius: 5.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const Image(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/images/consejito.jpg"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // HTML
                    Expanded(
                      flex: 100,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SingleChildScrollView(
                            child: Html(
                              data: advice.description,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: const Text("Next remainder:"),
                    ),
                    // NEXT TIME 
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: <Widget>[
                          CustomRadioButton(advice.timeOptions[0].toString()+" days", 0, "left"),
                          CustomRadioButton(advice.timeOptions[1].toString()+" days", 1, "middle"),
                          CustomRadioButton(advice.timeOptions[2].toString()+" days", 2, "middle"),
                          CustomRadioButton("Never", 3, "right")
                        ],
                      ),
                    ),
                    
                    // Buy buttom
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: ElevatedButton(
                        onPressed: (){_completarChallange(advice);},
                        child: Text("COMPLETAR RETO:"+ advice.xps.toString() +"xp"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                      ),
                    ),
                  ],
                )
              ),
            )
          ),
        ]
      )
    );
  }
}