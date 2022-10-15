// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'dart:convert';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'drawer_header.dart';
import 'apikey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AnimatedSplashScreen(
          backgroundColor: Color.fromARGB(255, 165, 189, 255),
          duration: 2000,
          splashIconSize: 200,
          splash: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.sunny,
                size: 80,
                color: Colors.greenAccent,
              ),
              Text(
                'आकाश',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              )
            ],
          ),
          nextScreen: MyHomePage(
            title: 'आकाश',
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String location = 'Null, Press Button';
  // ignore: non_constant_identifier_names
  String Address = 'search';

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // यह चेक कर रहा हु मैं की लोकैशन एनबलेड है की न |
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //लोकैशन सर्विस अगर इनैबल न हो तो आगे न जा और यूजर से रीक्वेस्ट कर की लोकैशन इनैबल करे |
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //अगर पुकने पर भी मन कर दे , हो सकता है आदमी को एहसास न हो की जरूरी है |तो हमे फ्यूचर से एरर शो कर डिंगए की तूने पर्मिशन न दी है |
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // अगर पर्मिशन बिल्कुल मन कर ड्यू है तो उसको शो करेंगे |.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    // यह जब चलेगा जब हमेरे पास पर्मिशन होगी या मिल जाएगी |
    // यह पे हम लोकैशन को एक्सेस करंगे|
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  var x = {
    'name': '0',
    'weather': '0',
    'temperature': '0',
    'tempfeel': '0',
    'clouds': '0',
    'speed': '0',
    'icon': '01d',
    'visibility': '0',
    'pressure': '0',
    'humidity': '0'
  };
  GoogleTranslator translator = GoogleTranslator();
  Future<void> getAddressFromLatLong(Position position) async {
    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&lang=hi&units=metric&appid=${key}'));
    var jsonData = jsonDecode(response.body);
    x['name'] = jsonData['name'].toString();
    x['weather'] = jsonData['weather'][0]['description'].toString();
    x['icon'] = jsonData['weather'][0]['icon'].toString();
    x['temperature'] = jsonData['main']['temp'].toString();
    x['tempfeel'] = jsonData['main']['feels_like'].toString();
    x['clouds'] = jsonData['clouds']['all'].toString();
    x['speed'] = jsonData['wind']['speed'].toString();
    x['visibility'] = jsonData['visibility'].toString();
    x['pressure'] = jsonData['main']['pressure'].toString();
    x['humidity'] = jsonData['main']['humidity'].toString();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    ' ${place.subLocality}, ${place.locality}';
    translator.translate(' ${place.subLocality}, ${place.locality}', from: 'en', to: 'hi').then((s) {
      Address = s.toString();
    });
    setState(() {});
  }

  iconmaker() {
    String url;
    url = 'http://openweathermap.org/img/wn/${x['icon']}@2x.png';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(Address == 'search' ? widget.title : Address)),
      ),
      body: Container(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(iconmaker()),
                  SizedBox(height: 10),
                  Text(
                    '${x['tempfeel'].toString()}°C',
                    style: TextStyle(fontSize: 50),
                  ),
                  Text(x['weather'].toString(), style: TextStyle(fontSize: 30))
                ],
              ),
            ]),
            const SizedBox(
              height: 80,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.cloud,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${x['clouds'].toString()}%',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.wind,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${x['speed'].toString()} m/h',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.thermometer,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${x['temperature'].toString()}°C',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.fog,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          x['visibility'] == '10000' ? 'स्पष्ट' : '${x['visibility'].toString()} meters',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.barometer,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${x['pressure'].toString()} hPa',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Icon(
                          WeatherIcons.humidity,
                          size: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${x['humidity'].toString()}%',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Position position = await _getGeoLocationPosition();
          location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
          getAddressFromLatLong(position);
        },
        tooltip: 'Search',
        child: const Icon(Icons.refresh),
      ),
      drawer: Drawer(
          child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              MyDrawerHeader(),
              MyDrawerList(),
            ],
          ),
        ),
      )),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          menuItem(),
        ],
      ),
    );
  }

  Widget menuItem() {
    return Material(
      child: InkWell(
        onTap: () {
          print('Helo');
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(children: [
            Expanded(
                child: Icon(
              Icons.cloud_circle_sharp,
              size: 35,
              color: Colors.red,
            )),
            Expanded(
              flex: 3,
              child: Text(
                'साप्ताहिक मौसम पूर्वानुमान',
                style: TextStyle(color: Color.fromARGB(66, 0, 0, 0), fontSize: 20),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
