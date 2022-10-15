import 'package:flutter/material.dart';

class MyDrawerHeader extends StatefulWidget {
  const MyDrawerHeader({super.key});

  @override
  State<MyDrawerHeader> createState() => _MyDrawerHeaderState();
}

class _MyDrawerHeaderState extends State<MyDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.greenAccent,
      width: double.infinity,
      height: 250,
      padding: EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 70,
            child: Icon(
              Icons.cloud_done,
              color: Color.fromARGB(255, 0, 47, 255),
              size: 55,
            ),
          ),
          Text(
            'आकाश',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
          ),
          Text(
            'नर्मता साइबर मयबेन ',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
          )
        ],
      ),
    );
  }
}
