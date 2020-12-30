
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/enum/connectivity_status.dart';

import 'package:provider/provider.dart';

/*class NetworkSensitive extends StatelessWidget {
  //final Widget child;
  //final double opacity;
  final String uid;

  NetworkSensitive(this.uid
    
    
  );

  @override
  Widget build(BuildContext context) {
    // Get our connection status from the provider
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.WiFi) {
       update(uid);
    }

    if (connectionStatus == ConnectivityStatus.Cellular) {
      update(uid);
      
    }

    if (connectionStatus == ConnectivityStatus.Offline) {
      update(uid);
      
    }
  }
}
Future update(id)async{
 return await Firestore.instance
          .collection('Drivers')
          .document(id)
          .updateData({'status':'online'
                      
        });
}
Future update2(id)async{
 return await Firestore.instance
          .collection('Drivers')
          .document(id)
          .updateData({'status':'online'
                      
        });
}*/


/*class NetworkSensitive extends StatelessWidget {
  final Widget child;
  //final String uid;

  NetworkSensitive(String uid, BuildContext context, {
    this.child,
    }
  );
  @override
  Widget build(BuildContext context) {
    // Get our connection status from the provider
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.WiFi) {
       update(uid);
      return child;
    }

    if (connectionStatus == ConnectivityStatus.Cellular) {
       update(uid);
      return  child;
    }

    if (connectionStatus == ConnectivityStatus.Offline) {
       update(uid);
      return  child;
    }
  
  }
}
Future update(id)async{
 return await Firestore.instance
          .collection('Drivers')
          .document(id)
          .updateData({'status':'online'
                      
        });
}
Future update2(id)async{
 return await Firestore.instance
          .collection('Drivers')
          .document(id)
          .updateData({'status':'online'
                      
        });*/
