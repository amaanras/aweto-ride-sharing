import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:aweto_user_app/authentication/login_screen.dart';
import 'package:aweto_user_app/methods/common_methods.dart';
import 'package:aweto_user_app/pages/home_page.dart';
import 'package:aweto_user_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{

  TextEditingController UserphoneTextEditingController = TextEditingController();
  TextEditingController UsernameTextEditingController = TextEditingController();
  TextEditingController EmailTextEditingController = TextEditingController();
  TextEditingController PasswordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signUpFormValidation();    
  }

  signUpFormValidation()
  {
    String username = UsernameTextEditingController.text.trim();
    String phone = UserphoneTextEditingController.text.trim();
    String email = EmailTextEditingController.text;
    String password = PasswordTextEditingController.text.trim();

    if(username.length < 4)
    {
      cMethods.displaySnackBar("your name must be 4 or more characters", context);
    }
    else if(phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone))
    {
      cMethods.displaySnackBar("your phone number must contain 10 digits", context);
    }
    else if(!email.contains("@"))
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
      registerNewUser();
    }
  }
  
  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText:"Registering your account..."),
    );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: EmailTextEditingController.text.trim(),
          password: PasswordTextEditingController.text.trim(),
      ).catchError((errorMsg)
      {
        cMethods.displaySnackBar(errorMsg.toString(), context);
      })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
    {
      "name": UsernameTextEditingController.text.trim(),
      "email": EmailTextEditingController.text.trim(),
      "phone": UserphoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };

    userRef.set(userDataMap);
    Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));

  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png"
              ),
              const Text(
                "Create a User\'s Account",
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

                      controller: UsernameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
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

                      controller: UserphoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Phone",
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
                        "Sign Up"
                      ),
                    )

                  ],
                ) ,
              ),

              const SizedBox(height: 12,),
              
              TextButton(
                onPressed:()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: const Text(
                  "Already Have an Account? Login Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

              )

            ],
          ),
        ),
      ),
    );
  }
}
