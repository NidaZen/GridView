import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryPage(),
    );
  }
}

class CategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Categories'),
      ),
      body: ListView(
        children: [
          CategoryTile(category: 'business'),
          CategoryTile(category: 'entertainment'),
          CategoryTile(category: 'general'),
          CategoryTile(category: 'health'),
          CategoryTile(category: 'science'),
          CategoryTile(category: 'sports'),
          CategoryTile(category: 'technology'),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String category;

  CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsPage(category: category)),
        );
      },
    );
  }
}

class NewsPage extends StatefulWidget {
  final String category;

  NewsPage({required this.category});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late List<News> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final response = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=us&category=${widget.category}&apiKey=ca4a3c14761444918cc36e5dfbae9108'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      setState(() {
        newsList = articles.map((article) => News.fromJson(article)).toList();
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} News'),
      ),
      body: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return NewsTile(news: newsList[index]);
        },
      ),
    );
  }
}

class News {
  final String title;
  final String description;
  final String? imageUrl;

  News({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? '', // Use an empty string if 'title' is null
      description: json['description'] ?? '', // Use an empty string if 'description' is null
      imageUrl: json['urlToImage'] != null ? json['urlToImage'] as String : '', // Use an empty string if 'urlToImage' is null
    );
  }
}

class NewsTile extends StatelessWidget {
  final News news;

  NewsTile({required this.news});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(news.title),
      subtitle: Text(news.description),
      leading: _buildImageWidget(news.imageUrl),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl);
    } else {
      return SizedBox.shrink(); // Hide the image if the URL is empty or null
    }
  }
}
