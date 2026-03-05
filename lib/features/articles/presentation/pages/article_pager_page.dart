import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/presentation/pages/article_detail_page.dart';
import 'package:flutter/material.dart';

class ArticlePagerPage extends StatefulWidget {
  final List<ArticleEntity> articles;
  final String initialArticleId;

  const ArticlePagerPage({
    super.key,
    required this.articles,
    required this.initialArticleId,
  });

  @override
  State<ArticlePagerPage> createState() => _ArticlePagerPageState();
}

class _ArticlePagerPageState extends State<ArticlePagerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.articles.indexWhere((a) => a.id == widget.initialArticleId);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // No podemos modificar el result aquí de forma limpia con PopScope si ya está haciendo pop.
          // Pero GoRouter maneja el retorno de navigator.pop(context, result).
        }
      },
      child: Scaffold(
        // Usamos un Stack para poner un botón de volver personalizado si es necesario,
        // o dejamos que el AppBar de ArticleDetailPage lo maneje.
        // Dado que ArticleDetailPage tiene su propio AppBar, el PageView mostrará varios AppBars.
        // Lo ideal sería que el Pager controle el AppBar, pero ArticleDetailPage es auto-contenido.
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.articles.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final article = widget.articles[index];
            return ArticleDetailPage(
              articleId: article.id,
              // Le pasamos una forma de volver con el ID actual
              onBackOverride: () {
                Navigator.of(context).pop(widget.articles[_currentIndex].id);
              },
            );
          },
        ),
      ),
    );
  }
}
