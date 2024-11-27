import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../main.dart';

class DriverPage extends StatefulWidget {
  // Modify the constructor to accept the driverId
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _counter = 0;
  // Location and Map Controllers
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  // For dynamic markers
  final Map<int, Marker> _dynamicMarkers = {};
  final Map<int, LatLng> _previousLocations = {};
  final Map<int, DateTime> _driverLastUpdateTime = {}; // Track last update time for each driver
  late Timer _timer;

  final Map<int, List<LatLng>> _predefinedRoutes = {
    1: [
      LatLng(19.13545428237426, 72.90614017839307),
      LatLng(19.13494494619806, 72.9083006977471),
      LatLng(19.13435198568622, 72.91009643671495),
      LatLng(19.133382345064238, 72.91265116307086),
      LatLng(19.132589189046687, 72.91467757197887),
      LatLng(19.131668058985294, 72.91528106901404),
      LatLng(19.131356368689072, 72.91534812427243),
      LatLng(19.130280652568494, 72.91544468379965),
      LatLng(19.129600248998504, 72.91543395494249),
      LatLng(19.128452299194006, 72.91539506292271),
      LatLng(19.126888513750142, 72.91570362682783),
      LatLng(19.12594826308112, 72.91617251302843),
      LatLng(19.125803608661478, 72.9162905319911)
    ],
    2: [
      LatLng(19.13777590157055, 72.91493353245139),
      LatLng(19.137656804879665, 72.91514542694026),
      LatLng(19.13714747550889, 72.91496571895603),
      LatLng(19.136022384151797, 72.91470822689682),
      LatLng(19.135345805241787, 72.91449096796453),
      LatLng(19.13430432443574, 72.91417714952486),
      LatLng(19.133006898774063, 72.91380432247654),
      LatLng(19.13251782745557, 72.91475918883101),
      LatLng(19.13166384973539, 72.91529831282054),
      LatLng(19.13072117483931, 72.9153975545553),
      LatLng(19.13010285827127, 72.9154646097771),
      LatLng(19.12958083509276, 72.91543778769552),
      LatLng(19.128303645264292, 72.91540023677906),
      LatLng(19.126851590068256, 72.91570600858559),
      LatLng(19.125803608661478, 72.9162905319911)
    ],
  };

  final Map<int, List<LatLng>> _snappedRoutes = {};

  LatLng? _currentP;

  late BitmapDescriptor _carIcon;
  late WebSocketChannel _channel;

  final Set<Polyline> _polylines = {};

  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    loadCarIcon().then((_) {
      getLocationUpdates(); // Start location updates
    });

    for (var routeId in _predefinedRoutes.keys) {
      _snapRouteToRoads(_predefinedRoutes[routeId]!, routeId);
    }

    // Create WebSocket connection on app start
    String url = GlobalConfig().url;
    String token = GlobalConfig().token;
    _channel = WebSocketChannel.connect(Uri.parse('ws://$url/ws?token=$token'));

    // Listen for incoming messages
    _channel.stream.listen((message) {
      _handleLocationUpdate(message);
    });

    // Start periodic check to remove expired markers
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _removeExpiredMarkers();
    });
  }

  Future<void> loadCarIcon() async {
    _carIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      // Specify the size of the icon
      'assets/car_icon.png', // Path to your custom icon
    );
  }

  // Check if any driver hasn't sent an update for 5 minutes
  void _removeExpiredMarkers() {
    final currentTime = DateTime.now();
    _driverLastUpdateTime.forEach((driverId, lastUpdate) {
      // If the last update is older than 5 minutes, remove the marker
      if (currentTime.difference(lastUpdate).inMinutes >= 5) {
        setState(() {
          _dynamicMarkers.remove(driverId);
          _previousLocations.remove(driverId);
          _driverLastUpdateTime.remove(driverId);
        });
      }
    });
  }

  // Function to receive data
  void _handleLocationUpdate(String message) {
    print(message);
    final data = jsonDecode(message);
    final LatLng newLocation = LatLng(data['latitude'], data['longitude']);
    final int driverId = data['driverId'];
    final int routeId = data['route'];
    final int seats = data['count'];

    setState(() {
      double heading = 0.0;
      if (_previousLocations.containsKey(driverId)) {
        heading = _calculateHeading(_previousLocations[driverId]!, newLocation);
      }

      _previousLocations[driverId] = newLocation;
      _driverLastUpdateTime[driverId] = DateTime.now();

      _dynamicMarkers[driverId] = Marker(
        markerId: MarkerId(driverId.toString()),
        position: newLocation,
        icon: _carIcon,
        rotation: heading,
        onTap: () {
          _drawRoute(driverId, routeId);
        },
      );
    });
  }

  // Function to send data
  void _sendLocationUpdate() {
    if (_currentP != null && _isTracking) {
      final message = jsonEncode({
        'latitude': _currentP!.latitude,
        'longitude': _currentP!.longitude,
        'route': 1,  // Replace with actual route ID
        'count': _counter,  // Replace with actual route ID
      });
      print(message);
      _channel.sink.add(message);
    }
  }

  // Toggle tracking
  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;

      if (_isTracking) {
        // Start sending location updates every 1 second when tracking starts
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          _sendLocationUpdate();
        });
      } else {
        // Stop sending location updates when tracking stops
        _timer.cancel();
      }
    });
  }

  // Calculate heading between two lat/lng points
  double _calculateHeading(LatLng previous, LatLng current) {
    final deltaLat = current.latitude - previous.latitude;
    final deltaLng = current.longitude - previous.longitude;
    final angle = (atan2(deltaLat, deltaLng) * 180 / pi) + 180;

    return angle;
  }

  // Method to request location permissions and start location tracking
  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Listen to location updates
    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  Future<void> _snapRouteToRoads(List<LatLng> routePoints, int routeId) async {
    // Convert route points to a string of lat, lng pairs
    final routeString = routePoints.map((point) {
      return "${point.latitude},${point.longitude}";
    }).join('|');

    final url = Uri.parse(
      'https://roads.googleapis.com/v1/snapToRoads?path=$routeString&interpolate=true&key=${GlobalConfig().googleKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(response.body);

      // List to store the snapped points
      List<LatLng> snappedPoints = [];
      for (var snappedPoint in data['snappedPoints']) {
        final lat = snappedPoint['location']['latitude'];
        final lng = snappedPoint['location']['longitude'];
        snappedPoints.add(LatLng(lat, lng));
      }
      // Store snapped route in the map
      _snappedRoutes[routeId] = snappedPoints;

    } else {
      throw Exception("Failed to snap route to roads");
    }
  }

  // Move the camera to a given position
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 16,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  void _drawRoute(int driverId, routeId) {
    if (_snappedRoutes.containsKey(routeId)) {
      final route = _snappedRoutes[routeId] ?? [];
      Color routeColor = routeId == 1 ? Colors.blue : Colors.red;

      setState(() {
        // Clear old polylines before adding a new one
        _polylines.clear();

        // Add new polyline
        _polylines.add(
          Polyline(
            polylineId: PolylineId(driverId.toString()),
            points: route,
            color: routeColor,
            width: 2,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer
    _channel.sink.close(); // Close WebSocket connection when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Driver Tracking'), backgroundColor: Colors.pink),
      body: Column(
        children: [
          // Google Map goes here
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(19.1354, 72.9061),
                zoom: 15,
              ),
              markers: Set<Marker>.from(_dynamicMarkers.values),
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
          ),

          // Counter and Buttons at the bottom
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Button
                ElevatedButton(
                  onPressed: _toggleTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set the background color of the button
                  ),
                  child: Text(_isTracking ? 'Stop' : 'Start'),
                ),
                // Add Button (Now comes first)
                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.blue, // Set the color of the icon
                  onPressed: () {
                    setState(() {
                      if (_counter < 10) _counter++; // Increment counter, if < 10
                    });
                  },
                ),
                // Display Counter
                Text(
                  '$_counter',
                  style: TextStyle(fontSize: 24, color: Colors.black), // Set the color of the text
                ),
                // Minus Button (Now comes second)
                IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.red, // Set the color of the icon
                  onPressed: () {
                    setState(() {
                      if (_counter > 0) _counter--; // Decrement counter, if > 0
                    });
                  },
                ),
                // Reset Button
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.orange, // Set the color of the icon
                  onPressed: () {
                    setState(() {
                      _counter = 0; // Reset counter
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}