import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:medapp/utils/DioClient.dart';
import '../models/news_item.dart';

class NewsViewModel extends ChangeNotifier {
  final List<String> specialties = [
    'Cardiologie',
    'Dermatologie',
    'Endocrinologie',
    'Gastro-entérologie',
    'Neurologie',
    'Oncologie',
    'Pédiatrie',
    'Psychiatrie',
  ];

  String _selectedSpecialty = 'Cardiologie';
  List<NewsItem> _news = [];
  bool _isLoading = false;

  String get selectedSpecialty => _selectedSpecialty;
  List<NewsItem> get news => _news;
  bool get isLoading => _isLoading;

  final Dio dio = DioHttpClient().dio;

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Updated URL structure to match the website
      final specialty = _selectedSpecialty.toLowerCase().replaceAll('é', 'e');
      final url = 'https://www.univadis.fr/news/$specialty';

      final response = await dio.get(url,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
          },
        ),
      );

      if (response.statusCode == 200) {
        final document = parser.parse(response.data);
        // Updated selectors to match website structure
        final articles = document.querySelectorAll('.news-card, .article-card');

        _news = articles
            .map((article) {
              final titleElement = article.querySelector('h2, h3');
              final title = titleElement?.text.trim() ?? '';

              final linkElement = article.querySelector('a[href*="/news/"]');
              final link = linkElement?.attributes['href'] ?? '';

              final imageElement = article.querySelector('img');
              final imageUrl = imageElement?.attributes['src'] ?? '';

              final descElement = article.querySelector('p');
              final description = descElement?.text.trim() ?? '';

              final dateElement = article.querySelector('.date, time');
              final date = dateElement?.text.trim() ?? '';

              return NewsItem(
                title: title,
                description: description,
                imageUrl: imageUrl.startsWith('http')
                    ? imageUrl
                    : 'https://www.univadis.fr$imageUrl',
                date: date,
                link: link.startsWith('http')
                    ? link
                    : 'https://www.univadis.fr$link',
              );
            })
            .where((item) => item.title.isNotEmpty)
            .toList();

        print('Fetched ${_news.length} articles for $_selectedSpecialty');
        print('URL accessed: $url');
      } else {
        print('Failed to fetch news: ${response.statusCode}');
        print('URL attempted: $url');
      }
    } catch (e) {
      print('Error fetching news: $e');
      _news = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSpecialty(String specialty) {
    _selectedSpecialty = specialty;
    fetchNews(); // This will trigger the fetch with the new specialty
  }
}
