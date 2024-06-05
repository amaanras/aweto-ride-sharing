import 'package:aweto_user_app/authentication/signup_screen.dart';
import 'package:aweto_user_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../methods/common_methods.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController EmailTextEditingController = TextEditingController();
  TextEditingController PasswordTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {

    String email = EmailTextEditingController.text;
    String password = PasswordTextEditingController.text.trim();

    if(!email.contains("@"))
    {
      cMethods.displaySnackBar("invalid email!", context);
    }
    else if(!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
    {
      cMethods.displaySnackBar("Your password must contain at least one special character", context);
      return;
    }
    else if(password.length < 6)
    {
      cMethods.displaySnackBar("your password must contain 6 or more characters", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText:"Login into your account..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: EmailTextEditingController.text.trim(),
          password: PasswordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null)
    {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      await userRef.once().then((snap)
      {
        if(snap.snapshot.value != null)
        {
          if((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("Your account has been blocked", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Not a valid user", context);
        }

      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset(
                  "assets/images/logo2.png"
              ),
              const Text(
                "Login as User",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //TextFields + button

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    TextField(

                      controller: EmailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),

                    ),

                    const SizedBox(height: 22,),

                    TextField(

                      controller: PasswordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),

                    ),

                    const SizedBox(height: 30,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding:const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text(
                          "Login"
                      ),
                    )

                  ],
                ) ,
              ),

              const SizedBox(height: 12,),

              TextButton(
                onPressed:()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                },
                child: const Text(
                  "Don\'t have an Account? Register Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

              )

            ],
          ),
        ),
      ),
    );;
  }
}
