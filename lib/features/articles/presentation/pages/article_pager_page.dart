import 'package:conectasoc/features/articles/domain/entities/entities.dart';
import 'package:conectasoc/features/articles/domain/usecases/usecases.dart';
import 'package:conectasoc/features/articles/presentation/pages/article_detail_page.dart';
import 'package:conectasoc/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  late final PrefetchArticlesUseCase _prefetchUseCase;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.articles.indexWhere((a) => a.id == widget.initialArticleId);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
    _prefetchUseCase = sl<PrefetchArticlesUseCase>();
    _triggerPrefetch();
  }

  void _triggerPrefetch() {
    final ids = <String>[];
    const window = 4; // Precargar 4 adelante y 4 atrás

    // Adelante
    for (int i = 1; i <= window; i++) {
      if (_currentIndex + i < widget.articles.length) {
        ids.add(widget.articles[_currentIndex + i].id);
      }
    }

    // Atrás
    for (int i = 1; i <= window; i++) {
      if (_currentIndex - i >= 0) {
        ids.add(widget.articles[_currentIndex - i].id);
      }
    }

    if (ids.isNotEmpty) {
      _prefetchUseCase(ids);
    }
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
            _triggerPrefetch();
          },
          itemBuilder: (context, index) {
            final article = widget.articles[index];
            return ArticleDetailPage(
              articleId: article.id,
              // Le pasamos una forma de volver con el ID actual
              onBackOverride: () {
                context.pop(widget.articles[_currentIndex].id);
              },
            );
          },
        ),
      ),
    );
  }
}
