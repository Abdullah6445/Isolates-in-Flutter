import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ApiCallWithIsolate(),
    );
  }
}

class ApiCallWithIsolate extends StatefulWidget {
  @override
  _ApiCallWithIsolateState createState() => _ApiCallWithIsolateState();
}

class _ApiCallWithIsolateState extends State<ApiCallWithIsolate> {
  String _status = "Press the button to fetch data.";

  // Function to fetch users when button is pressed
  
  Future<void> hittingApi() async {
    final res = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/albums"));
    if(res.statusCode == 200){
      final data = json.decode(res.body);

      print("<<<=================== without isolates ");
      print(data);
      print("===================>>>");

      setState(() {
        _status = "without isolates : \n\n" + data.toString();

      });



    }

  }
  
  
  Future<void> fetchUsers() async {


    final receivePort = ReceivePort(); // Port for receiving data from the isolate


    await Isolate.spawn(fetchUsersInIsolate, receivePort.sendPort);

    // Listen for data from the isolate
    receivePort.listen((data) {

      print("<<<=================== with isolates ");
      print(data);
      print("===================>>>");


      setState(() {
        _status = "with isolates : \n\n" + data.toString();

      });




      receivePort.close(); // Close the port
    });
  }

  // Function that runs in the background isolate


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("API Call Using Isolate"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text(
                _status,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchUsers, // Trigger the API call
                child: Text("Fetch Api Data using isolates"),
              ),
              ElevatedButton(
                onPressed: hittingApi, // Trigger the API call
                child: Text("Fetch Api Data without isolates"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



Future<void> fetchUsersInIsolate(SendPort sendPort) async {
const url = 'https://jsonplaceholder.typicode.com/users';

try {
final response = await http.get(Uri.parse(url));
if (response.statusCode == 200) {
final data = json.decode(response.body);
sendPort.send(data); // Send data back to the main isolate
} else {
sendPort.send("Failed to fetch data. Status code: ${response.statusCode}");
}
} catch (e) {
sendPort.send("Error: $e");
}
}
