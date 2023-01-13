import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Coin> futureCoin;

  Future<Coin> fetchCoin() async {
    final response = await http.get(Uri.parse(
        'https://api.coinstats.app/public/v1/coins?skip=0&limit=5&currency=USD'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final coins = jsonDecode(response.body);

      return Coin.fromJson(coins['coins'][0]);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCoin = fetchCoin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Coin>(
          future: futureCoin,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              print(snapshot.data!.icon);
              print(snapshot.data!.name);
              print(snapshot.data!.price);

              return Row(
                children: [
                  Image.network(
                    snapshot.data!.icon,
                    width: 35,
                    height: 35,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    snapshot.data!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\$ ${snapshot.data!.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Coin {
  final String icon;
  final String name;
  final double price;

  const Coin({
    required this.icon,
    required this.name,
    required this.price,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      icon: json['icon'],
      name: json['name'],
      price: json['price'],
    );
  }
}
