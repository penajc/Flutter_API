import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_api/models/Gif.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Gif>>? _listadoGifs;

  Future<List<Gif>> _getGifs() async {
    final response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=eScJ58c8uJGL0QjVB0Rh8kcKVf9HxJ3n&limit=25&rating=g'));

    List<Gif> gifs = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        gifs.add(Gif(item["title"], item["images"]["downsized"]["url"]));
      }

      return gifs;
    } else {
      throw Exception('Falló la Conexion a los Datos');
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoGifs = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trending Giphys',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Trending Giphys'),
        ),
        body: FutureBuilder(
          future: _listadoGifs,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return GridView.count(
                crossAxisCount: 2,
                children: _listGifs(snapshot.data),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text('No data');
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _listGifs(List<Gif> data) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(Card(
          child: Column(
        children: [
          Expanded(child: Image.network(gif.url, fit: BoxFit.fill)),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(gif.name),
          // )
        ],
      )));
    }
    return gifs;
  }
}
