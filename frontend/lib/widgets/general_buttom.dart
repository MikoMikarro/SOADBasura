import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget{
  const GeneralButton({Key? key, 
    required this.title,
    required this.textColor,
    required this.action,
  }) : super(key: key);

  final String title;
  final Color textColor;
  final Function() action;

  @override 
  Widget build(BuildContext context){
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          
          primary: const Color.fromARGB(255, 158, 195, 112),
          onPrimary: Colors.white.withAlpha(0),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(
            color: textColor,
            width: 3,
          ),
          elevation: 5
        ),
        onPressed: action,
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor,),),
      ),
    );
  }
}