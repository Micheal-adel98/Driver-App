import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

const double CAMERA_ZOOM = 16;

const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(0,0);
const LatLng DEST_LOCATION = LatLng(30.1728, 31.5361);
//const apiKey = "AIzaSyA_x1N3A6LJz8jArx9zmRS0mzn2UVYIy0c";

class Direction extends StatefulWidget {
  static final pageName = '/MyMap';
  Direction({Key key, this.uid})
      : super(key: key); //update this to include the uid in the constructor

  final String uid;


  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Direction> {

  String now =DateTime.now().day.toString()+'-'+DateTime.now().month.toString()+'-'+DateTime.now().year.toString();
  String now2 =DateTime.now().month.toString()+'-'+DateTime.now().year.toString();

  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;

  LocationData destinationLocation;

  Location location;

  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

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
      consumeTapEvents: true,
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
  dynamic name;
  dynamic total;
  dynamic active3;
  Future<dynamic> getName2() async {

    final DocumentReference document =   Firestore.instance.collection("TotalHours").document('$now2 $id');

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        active3 =snapshot.data['activehours'];

        _start2=active3;

      });
    });
  }

  Future<dynamic> getName() async {

    final DocumentReference document =   Firestore.instance.collection("Drivers").document(widget.uid);

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        name =snapshot.data['name'];



      });
    });
  }
  int active;

  dynamic id;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  Future<dynamic> getData() async {
    id=widget.uid;
    final DocumentReference document =   Firestore.instance.collection("DriverHours").document('$now $id');

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        active =snapshot.data['activehours'];

        _start=active;


      });
    });
  }

  Timer _timer;
  dynamic _start=0;

  void startTimer() async{

    const oneSec = const Duration(minutes: 1);

    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) =>
          setState(
                () async {

              _start += 1;

              await Firestore.instance.collection('DriverHours').document('$now $id').setData(
                  {"activehours": _start, 'date': now,'name':name});


            },
          ),
    );



  }

  Timer _timer2;
  dynamic _start2=0;
  void startTimer2() async{

    const oneSec = const Duration(minutes: 1);

    _timer2 = new Timer.periodic(
      oneSec,
          (Timer timer) =>
          setState(
                () async {

              _start2 += 1;

              await Firestore.instance.collection('TotalHours').document('$now2 $id').setData(
                  {"activehours": _start2,'name':name,'date':now});
              /*
              await Firestore.instance.collection('Drivers').document(widget.uid).updateData(
                  {"activehours": _start2});
*/
            },
          ),
    );



  }


  @override
  void initState() {
    super.initState();
    getName();
    getData();
    getName2();

    startTimer();
    startTimer2();
    location = new Location();
    polylinePoints = PolylinePoints();
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {

        showDialog(
          context: context,
          builder: (context) => AlertDialog(

            content: ListTile(
              dense: true,
              title: Text(message['notification']['title'],style: TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold)),
              subtitle: Text(message['notification']['body'],style: TextStyle(fontSize: 21.0)),
            ),
            actions: <Widget>[

              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,

                splashColor: Colors.blueAccent,
                child: Text('Ok',style: TextStyle(fontSize: 15.0)),
                onPressed: () => Navigator.of(context).pop(),

              ),
            ],
          ),
        );
      },

    );
    location.onLocationChanged().listen((LocationData cLoc) {


      currentLocation = cLoc;
      updatePinOnMap();
    });

    setSourceAndDestinationIcons();

    setInitialLocation();
  }
  void setSourceAndDestinationIcons() async {
    getBytesFromAsset('assets/images/Bus_c-512.png', 165).then((v) {
      sourceIcon = BitmapDescriptor.fromBytes(v);
      setState(() {});
    });

    getBytesFromAsset('assets/images/future.jpg', 130).then((v) {
      destinationIcon = BitmapDescriptor.fromBytes(v);

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
  dynamic sum;

  calculateHours(){

  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,

      bearing: CAMERA_BEARING,
      target: SOURCE_LOCATION,

    );
    if (currentLocation != null) {


      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude,
              currentLocation.longitude),
          zoom: CAMERA_ZOOM,

          bearing: CAMERA_BEARING
      );
    }
    return Scaffold(

      body:Builder(
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
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: <Widget>[
                                      FloatingActionButton(

                                        backgroundColor: Colors.red,
                                        onPressed: () async{
                                          _timer.cancel();
                                          _timer2.cancel();
                                          //await Firestore.instance.collection('Drivers').document(widget.uid).updateData({"Hours": sum});

                                          Navigator.pop(context);
                                        },
                                        splashColor: Colors.black,


                                        child: Image.asset('assets/images/private.png'),

                                      ),

                                    ],
                                  )
                              )
                          )
                      )
                    ]

                );
              },

              child: GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                polylines: Set<Polyline>.of(_mapPolylines.values),
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  showPinsOnMap();
                },
              ),
            );


          }),
    );


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
          icon: sourceIcon

      ));

    });
  }
/*
  getDurationAndDistanceAndDrawLine() async {
//src is first point
//des is seconed point

    var api = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
        currentLocation.latitude.toString() +
        "," +
        currentLocation.longitude.toString() +
        "&destination=" +
        30.1728.toString() +
        "," +
        31.5361.toString() +
        "&key=$apiKey";

    http.get(api).then((res) {

      var body = json.decode(res.body);

//print body and you will see all details of it (duration , distance, turn left and right)
      decodeEncodedPolyline(body["routes"][0]["overview_polyline"]["points"]);
    });
  }
  decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
//poly is List of LatLng
    setState(() {
      _polylines = {};
      var p = new Polyline(
          polylineId: PolylineId("route1"),
          points: poly,
          color: Colors.black,
          zIndex: 6,
          geodesic: false,
          width: 6,
          endCap: Cap.squareCap,
          startCap: Cap.roundCap);
      _polylines.add(p);
    });
  }

   */
}