// Импортируем пакет Flutter для создания пользовательского интерфейса
import 'package:flutter/material.dart';

// Импортируем пакет http для выполнения HTTP-запросов
import 'package:http/http.dart' as http;

// Импортируем пакет dart:convert для работы с JSON
import 'dart:convert';

// Точка входа в приложение
void main() {
  // Запускаем приложение с виджетом MyApp
  runApp(const MyApp());
}

// Класс MyApp, который является корневым виджетом приложения
class MyApp extends StatelessWidget {
  // Конструктор класса MyApp
  const MyApp({super.key});

  // Переопределяем метод build для создания пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    // Возвращаем виджет MaterialApp, который является основой для материального дизайна
    return const MaterialApp(
      // Заголовок приложения
      title: 'Случайные цитаты',
      home: QuoteScreen(),
    );
  }
}

// Класс QuoteScreen, который является экраном с цитатами
class QuoteScreen extends StatefulWidget {
  // Конструктор класса QuoteScreen
  const QuoteScreen({super.key});

  // Переопределяем метод createState для создания состояния виджета
  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

// Класс _QuoteScreenState, который управляет состоянием виджета QuoteScreen
class _QuoteScreenState extends State<QuoteScreen> {
  // Переменная для хранения текста цитаты
  String _quote = 'Нажмите кнопку для получения случайной цитаты';

  // Переменная для хранения имени автора цитаты
  String _author = '';

  // Переменная для хранения состояния загрузки
  bool _isLoading = false;

  // Переопределяем метод build для создания пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    // Возвращаем виджет Scaffold, который является основой для экрана
    return Scaffold(
      // Панель приложения
      appBar: AppBar(
        // Заголовок панели приложения
        title: const Text('Случайные цитаты'),
      ),
      // Основное содержимое экрана
      body: Center(
        // Отступы вокруг содержимого
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Если идет загрузка, показываем индикатор загрузки
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  // Выравнивание содержимого по центру
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Список виджетов в колонке
                  children: [
                    // Виджет для отображения текста цитаты
                    Text(
                      _quote,
                      // Стиль текста
                      style: const TextStyle(fontSize: 35),
                      // Выравнивание текста по центру
                      textAlign: TextAlign.center,
                    ),
                    // Отступ между цитатой и именем автора
                    const SizedBox(height: 50),
                    // Виджет для отображения имени автора
                    Text(
                      _author,
                      // Стиль текста
                      style: const TextStyle(
                          fontSize: 25, fontStyle: FontStyle.italic),
                      // Выравнивание текста по центру
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
      // Плавающая кнопка для получения новой цитаты
      floatingActionButton: FloatingActionButton(
        // Обработчик нажатия на кнопку
        onPressed: _fetchQuote,
        // Подсказка для кнопки
        tooltip: 'Получить цитату',
        // Иконка на кнопке
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Метод для перевода текста с одного языка на другой
  Future<String> _translateText(
      String text, String sourceLang, String targetLang) async {
    // Выполняем HTTP-запрос для перевода текста
    final response = await http.get(
      Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=$text'),
    );

    // Если запрос успешен, парсим ответ и возвращаем переведенный текст
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0][0][0];
    } else {} // Если запрос неуспешен, выбрасываем исключение
    throw Exception('Failed to translate text');
  }

  // Метод для получения случайной цитаты
  Future<void> _fetchQuote() async {
    // Устанавливаем состояние загрузки в true
    setState(() {
      _isLoading = true;
    });

    try {
      // Выполняем HTTP-запрос для получения случайной цитаты
      final response =
          await http.get(Uri.parse('https://zenquotes.io/api/random'));

      // Если запрос успешен, парсим ответ и обновляем состояние
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String quote = data[0]['q'];
        final String author = data[0]['a'];

        // Переводим цитату и имя автора на русский язык
        final String translatedQuote = await _translateText(quote, 'en', 'ru');
        final String translatedAuthor =
            await _translateText(author, 'en', 'ru');

        // Обновляем состояние с переведенной цитатой и именем автора
        setState(() {
          _quote = translatedQuote;
          _author = translatedAuthor;
        });
      } else {
        // Если запрос неуспешен, обновляем состояние с сообщением об ошибке
        setState(() {
          _quote = 'Ошибка при получении цитаты';
        });
      }
    } catch (e) {
      // Если произошла ошибка, обновляем состояние с сообщением об ошибке
      setState(() {
        _quote = 'Ошибка: $e';
      });
    } finally {
      // Устанавливаем состояние загрузки в false
      setState(() {
        _isLoading = false;
      });
    }
  }
}
