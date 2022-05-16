// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'dart:async';

import 'package:buildgreen/screens/main_screen.dart';
import 'package:buildgreen/widgets/back_button.dart';
import 'package:buildgreen/widgets/build_green_form_background.dart';
import 'package:buildgreen/widgets/general_buttom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:buildgreen/widgets/input_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// ignore: library_prefixes
import 'package:buildgreen/constants.dart' as Constants;

import '../arguments/user_type_argument.dart';

class SignUpScreen extends StatefulWidget {
  static const route = '/register';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  TextEditingController licenseController = TextEditingController();

  String? _character = "client";
  bool _usernameCorrect = true;
  bool _emailCorrect = true;

  String isAdmin() {
    if (_character == "client") {
      return "False";
    } else if (_character == "prop_admin") {
      return "True";
    } else {
      return "False";
    }
  }

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  Future<void> createAccount() async {
    EasyLoading.show(status: 'Creating account...');
    final response = await http.post(
      Uri.parse(Constants.API_ROUTE + '/signup/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'username': nameController.text,
          'first_name': nameController.text,
          'last_name': apellidoController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'is_admin': isAdmin(),
          'license_num': licenseController.text,
        },
      ),
    );
    EasyLoading.dismiss();
    debugPrint(response.body);

    final responseJson = jsonDecode(response.body);
    if (responseJson['user_info'] != null) {
      EasyLoading.show(status: 'Logging in...');
      final response =
          await http.post(Uri.parse(Constants.API_ROUTE + '/login/'), body: {
        'username': nameController.text,
        'password': passwordController.text,
      });
      debugPrint(response.body);

      final responseJson = jsonDecode(response.body);
      var isAdmin =responseJson['user_info']['is_admin'].toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('_user_token', responseJson['token']);
      EasyLoading.dismiss();
      Navigator.pushNamed(
          context, MainScreen.route, arguments: UserTypeArgument(isAdmin));
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('¡Error!'),
          content: const Text('Algunas credenciales eran incorrectas'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      if (responseJson['username'] != null) {
        setState(() {
          _usernameCorrect = false;
        });
      }

      if (responseJson['email'] != null) {
        setState(() {
          _emailCorrect = false;
        });
      }
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.green;
    }
    return Colors.white;
  }

  bool formCorrect() {
    return EmailValidator.validate(emailController.text.toString()) &&
        checkRepeated() &&
        nameController.text != "" &&
        apellidoController.text != "";
  }

  bool checkRepeated() {
    if (passwordController2.text == "") return true;
    if (passwordController.text == passwordController2.text) return true;
    return EmailValidator.validate(emailController.text.toString());
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Stack(
        children: [
          // background colors start
          BackgroundForm(
            screenHeight: screenHeight,
            backColor: const Color.fromARGB(255, 27, 119, 58),
          ),
          // background colors end
          // form start
          Container(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.topLeft,
                        child: Row(children: [
                          const CustomBackButton(),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text(
                              "Sign Up",
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                          ),
                        ]),
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: InputForm(
                                controller: nameController,
                                autoValidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (value) {
                                  _usernameCorrect = true;
                                },
                                validationFunction: (value) {
                                  if (value.toString().isEmpty) {
                                    return "Enter some text";
                                  }
                                  if (!_usernameCorrect) {
                                    return "Username ya usado";
                                  }
                                  return null;
                                },
                                hintLabel: 'Nombre'),
                          ),
                          Flexible(
                            child: InputForm(
                              controller: apellidoController,
                              hintLabel: "Apellidos",
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validationFunction: (value) {
                                if (value.toString().isEmpty) {
                                  return "Enter some text";
                                }
                                if (!_usernameCorrect) {
                                  return "Username ya usado";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: InputForm(
                          controller: emailController,
                          hintLabel: "Email",
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            _emailCorrect = true;
                          },
                          validationFunction: (value) {
                            if (!EmailValidator.validate(value.toString())) {
                              return "Incorrect e-mail";
                            }
                            if (!_emailCorrect) {
                              return "e-mail ya en uso";
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_character == "prop_admin")
                        Flexible(
                          child: InputForm(
                            controller: licenseController,
                            hintLabel: "Licencia",
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                      Flexible(
                        child: InputForm(
                          controller: passwordController,
                          hintLabel: "Password",
                          obscureText: true,
                          autoValidateMode: AutovalidateMode.always,
                          validationFunction: (value) {
                            if (value.toString() != passwordController2.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                        ),
                      ),
                      Flexible(
                        child: InputForm(
                          controller: passwordController2,
                          hintLabel: "Confirm Password",
                          obscureText: true,
                          autoValidateMode: AutovalidateMode.always,
                          validationFunction: (value) {
                            if (value.toString() != passwordController.text) {
                              return "Passwords don't match";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      ListTile(
                        title: Text('Cliente',
                            style: Theme.of(context).textTheme.bodyText1),
                        leading: Radio<String>(
                          value: "client",
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          groupValue: _character,
                          onChanged: (String? value) {
                            setState(() {
                              _character = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Administrador de propiedades',
                            style: Theme.of(context).textTheme.bodyText1),
                        leading: Radio<String>(
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: "prop_admin",
                          groupValue: _character,
                          onChanged: (String? value) {
                            setState(() {
                              _character = value;
                            });
                          },
                        ),
                      ),
                      //const Padding(padding: EdgeInsets.all(5)),
                      
                    ],
                  ),
                  GeneralButton(
                        title: "Crear Cuenta",
                        action: (formCorrect()) ? createAccount : () {},
                        textColor:
                            (formCorrect()) ? Colors.white : Colors.white24,
                      ),
                ],
              ),
            ),
          )
          // form end
        ],
      ),
    );
  }
}
