import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aweto_user_app/authentication/login_screen.dart';
import 'package:aweto_user_app/global/global_var.dart';
import 'package:aweto_user_app/methods/common_methods.dart';
import 'package:aweto_user_app/pages/search_destination_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfUser;

  GlobalKey<ScaffoldState> skey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();

  double searchContainerHeight = 276;
  double bottomMapPadding = 0;

  void updateMapTheme(GoogleMapController controller)
  {
    getJsonFileFromThemes("themes/silver_style.json").then((value)=> setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath)async
  {
    ByteData byteData =  await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller)
  {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation );
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.reverseGeoCodingAddress(currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockSatus();

  }

  getUserInfoAndCheckBlockSatus() async
  {
    DatabaseReference userRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);
    await userRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        if((snap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          cMethods.displaySnackBar("Your account has been blocked", context);
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));

      }

    }
    );
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: skey,
      drawer: Container(
        width: 255,
        color: Colors.black45,
        child: ListView(
          children: [
            //header
            Container(
              color: Colors.black38,
              height: 160,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black
                ), child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 68,
                        ),

                        const SizedBox(width: 16,),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Profile",
                              style: const TextStyle(
                                  color: Colors.white10,

                              ),
                            )
                          ],
                        )
                      ],
              ),
              ),
            ),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 10,),

            //body
            ListTile(
              leading: IconButton(
                onPressed: (){},
                icon: const Icon(Icons.info, color: Colors.grey,),
              ),
              title: const Text("About", style: TextStyle(color: Colors.grey),),
            ),

            GestureDetector(
              onTap: ()
              {
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
              },
              child: ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.logout, color: Colors.grey,),
                ),
                title: const Text("Logout", style: TextStyle(color: Colors.grey),),
              
              ),
            ),

          ],
        ),
      ),

      body: Stack(
        children: [

          GoogleMap(
            padding:  EdgeInsets.only(top: 20, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);

              googleMapCompleterController.complete(controllerGoogleMap);
              setState(() {
                bottomMapPadding = 160;
              });

              getCurrentLiveLocationOfUser();
            },
          ),

          //drawer button
          Positioned(
            top: 42,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                skey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                          
                    )
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: -80,
            child: Container(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  ElevatedButton(
                    onPressed: ()
                    {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => SearchDestinationPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),


                  ElevatedButton(
                    onPressed: ()
                    {

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),


                  ElevatedButton(
                    onPressed: ()
                    {

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                ],
              ),
            ),

          ),
        ],
      )
    );
  }
}
