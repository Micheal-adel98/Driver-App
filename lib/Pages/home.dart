import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutterapp/Pages/chat.dart';
import 'package:flutterapp/Pages/direction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutterapp/Pages/Myaccount.dart';
import 'package:flutterapp/ui/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_offline/flutter_offline.dart';


const double CAMERA_ZOOM = 10;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 40;
const LatLng SOURCE_LOCATION = LatLng(26.8206, 30.8025);
const LatLng DEST_LOCATION = LatLng(30.1728, 31.5361);

class Home extends StatefulWidget {
  Home({Key key, this.uid,this.myValue,@required this.latitude,@required this.longitude})
      : super(key: key); //update this to include the uid in the constructor

  final String uid;
  final String myValue;
  final double longitude;
  final double latitude;




  StreamSubscription subscription;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var name='';
  var email='';
  var line='';
  var status='' ;
  bool checkValue = false;
  String _networkStatus2 = '';
  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> subscription;
  Location _location;
  String _mapStyle;
 SharedPreferences sharedPreferences;
  Set<Marker> _markers = Set<Marker>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;

  LocationData destinationLocation;

  Location location;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

  getPref()async{
     sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = sharedPreferences.getString("username");
      passwordController.text = sharedPreferences.getString("password");
    });

  }
  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    points.add(LatLng(currentLocation.latitude, currentLocation.longitude));
    points.add(LatLng(30.1189, 31.3400));
    points.add(LatLng(30.1188, 31.3403));
    points.add(LatLng(30.118368, 31.340483));
    points.add(LatLng(30.112001, 31.345172));
    points.add(LatLng(30.111435, 31.345365));
    points.add(LatLng(30.111036, 31.345494));
    points.add(LatLng(30.110934, 31.345901));
    points.add(LatLng(30.111314, 31.346202));
    points.add(LatLng(30.118458, 31.356590));
    points.add(LatLng(30.116633, 31.364226));
    points.add(LatLng(30.115779, 31.365986));
    points.add(LatLng(30.116058, 31.366790));
    points.add(LatLng(30.116559, 31.367241));
    points.add(LatLng(30.117097, 31.367488));
    points.add(LatLng(30.117988, 31.368325));
    points.add(LatLng(30.136325, 31.392356));
    points.add(LatLng(30.140371, 31.400531));
    points.add(LatLng(30.142254, 31.401239));
    points.add(LatLng(30.165268, 31.484467));
    points.add(LatLng(30.174135, 31.554917));
    points.add(LatLng(30.174649, 31.554955));
    points.add(LatLng(30.1723, 31.5362));
    points.add(LatLng(30.1728, 31.5361));

    return points;
  }

  void _add() {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: false,
      color: Colors.black,
      width: 5,
      points: _createPoints(),

    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }


  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

// Method to convert the connectivity to a string value
  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'Mobile';

        break;
      case ConnectivityResult.wifi:
        status = 'Wi-Fi';

        break;
      case ConnectivityResult.none:
        status = 'None';

        break;
      default:
        status = 'None';

        break;
    }
    return status;
  }

  FirebaseDatabase _database = FirebaseDatabase.instance;

  final FirebaseMessaging _messaging = FirebaseMessaging();

  saveDeviceToken() async {
    await _messaging.getToken().then((token) {
      Firestore.instance
          .collection('pushtokens')
          .document(widget.uid)
          .setData({'devtoken': token
      }
      );
    });
  }

  Future<dynamic> getData() async {

    final DocumentReference document =   Firestore.instance.collection("Drivers").document(widget.uid);

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        name =snapshot.data['name'];
        email =snapshot.data['email'];
        line = snapshot.data['Line_Number'];
        status = snapshot.data['Status'];

      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    location = new Location();
     polylinePoints = PolylinePoints();
     saveDeviceToken();





      updatePinOnMap();

    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it

      currentLocation = cLoc;
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();




    print('userToken:' + widget.uid);

  _location = Location();
  widget.subscription =
      _location.onLocationChanged().listen((locData) async {
        widget.subscription.pause();
        await _database.reference().child('Drivers').child(widget.uid).
        update({
          'Latitude': locData.latitude,
          'Longitude': locData.longitude,
          'Name': name,
          'line_num': line,
          'Statuss': status
        });

        await Firestore.instance
            .collection('TrackDriver')
            .document(widget.uid)
            .setData({'lat': locData.latitude,
          'lng': locData.longitude,
          'Line_Number': line,
          'Name': name,

        });

        widget.subscription.resume();
        checkConnectivity2();

        //checkConnectivity2();

      });


  }

  void setSourceAndDestinationIcons() async {
    getBytesFromAsset('assets/images/Bus_c-512.png', 140).then((v) {
      sourceIcon = BitmapDescriptor.fromBytes(v);
      setState(() {});
    });

    getBytesFromAsset('assets/images/future.jpg', 120).then((v) {
      destinationIcon = BitmapDescriptor.fromBytes(v);
      setState(() {});
    });
  }

  void setInitialLocation() async {

    currentLocation = await location.getLocation();

    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  Completer<GoogleMapController> _controller = Completer();


  void checkConnectivity2() {
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          var conn = getConnectionValue(result);
          setState(() {
            _networkStatus2 = conn;
            //print(_networkStatus2);
            //lastUpdateStatus();
          });
        });
  }

  @override
  Widget build(BuildContext context) {

    lastUpdateStatus();

    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: SOURCE_LOCATION,

    );
    if (currentLocation != null) {
      // getDurationAndDistanceAndDrawLine();
      _add();
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude,
              currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white60,
        centerTitle: true,
        title: Text('Future Academy'),
        actions: <Widget>[
           Center(
            child: Text(
              "Exit"
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            onPressed: () async{
              SystemNavigator.pop();
              await Firestore.instance
        .collection('Drivers')
        .document(widget.uid)
        .updateData({'Status': 'Offline'});
              await _database.reference().child('Drivers').child(widget.uid).
              set({
                'Name': name,
                'Statuss':'Offline'
              });

            },
          )
        ],
      ),
      body: Builder(
          builder: (BuildContext context) {
            return OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity, Widget child) {
                final bool connected =
                    connectivity != ConnectivityResult.none;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      height: 32.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color:
                        connected ? Colors.white10 : Color(0xFFEE4400),
                        child: connected
                            ? Row(
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            Text(
                              "OFFLINE",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            SizedBox(
                              width: 12.0,
                              height: 12.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),

                          ],

                        ),

                      ),
                    ),
                      Positioned(
                      child: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(

                    backgroundColor: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Direction(uid: widget.uid)));
                    },



                    child: Image.asset('assets/images/power.png'),

                  ),

                  ],
                )
                )
                )
                      )]

                );
              },

              child: GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                polylines: Set<Polyline>.of(_mapPolylines.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(_mapStyle);
                  showPinsOnMap();
                  updatePinOnMap();
                  getPref();
                },

              ),


            );
          }),





      drawer: Drawer(
        child: ListView(padding: const EdgeInsets.all(0),

            children: <Widget>[
          //Container(),

          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/images/future.jpg"),


            ),
            accountName: Text(

              name,
              style: TextStyle(fontSize: 20),
            ),
            accountEmail: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  email,
                  style: TextStyle(fontSize: 15),
                )),
            /* decoration: BoxDecoration(color:Colors.blueGrey),*/
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyAccount(uid: widget.uid)));
            },
            child: ListTile(
                title: Text("My account"),
                leading: Icon(Icons.person)
            ),
          ),
          InkWell(
            onTap: () {

              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text)
                  .then((currentUser) =>


                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>

                                 Chat(

                                      uid: currentUser.user
                                  ))));



            },
            child: ListTile(
                title: Text("Chat admin"),
                leading: Icon(Icons.chat)
            ),
          ),

          InkWell(
            onTap: () {
              launch('tel:01221732299');
            },
            child: ListTile(
                title: Text("Contact Us"),
                leading: Icon(Icons.call)
            ),
          ),

          Divider(),
          InkWell(
            onTap: () async {


              SharedPreferences prefs = await SharedPreferences.getInstance();

              checkValue = prefs.getBool("check");
              if (checkValue != null) {
                if (checkValue == true) {
                  prefs.remove("password");
                }
              } else {
                checkValue = false;
                prefs.clear();
              }
              var status = prefs.getBool('isLoggedIn') ?? false;
              print(status);
              runApp(MaterialApp(home: status == false ? SignInPage() : Home(),debugShowCheckedModeBanner: false));
              await Firestore.instance
                  .collection('Drivers')
                  .document(widget.uid)
                  .updateData({'Status': 'Offline'});
              await _database.reference().child('Drivers').child(widget.uid).
              set({
                'Name': name,
                'Statuss':'Offline',
              });
               FirebaseAuth.instance.signOut().then((currentUser) =>
                  Firestore.instance
                      .collection("Drivers")
                      .document(widget.uid)
                      .get()
                      .then((DocumentSnapshot result) =>

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) =>
                              SignInPage()), (Route<dynamic> route) => false)));
            },
            child: ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.exit_to_app)
            ),
          )
        ]),
      ),



    );
  }



//update location to firebase
  Future<void> lastUpdateStatus() async {
    if (_networkStatus2 == "Wi-Fi") {
      await Firestore.instance
          .collection('Drivers')
          .document(widget.uid)
          .updateData({'Status': 'Online'});
    }
    if (_networkStatus2 == "Mobile") {
      await Firestore.instance
          .collection('Drivers')
          .document(widget.uid)
          .updateData({'Status': 'Online'});
    }else{
      await Firestore.instance
          .collection('Drivers')
          .document(widget.uid)
          .updateData({'Status': 'Online'});
    }
  }


  void showPinsOnMap() {


    var destPosition = LatLng(destinationLocation.latitude,
        destinationLocation.longitude);

    _markers.add(Marker(
        infoWindow: InfoWindow(title: 'Stopped here'),
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon
    ));



  }

  void updatePinOnMap() async {

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude,
          currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {

      _markers.removeWhere(
              (m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(

          markerId: MarkerId('sourcePin'),
          position: LatLng(currentLocation.latitude,
              currentLocation.longitude), // updated position
          icon: sourceIcon,
      ));

    });
  }
}
