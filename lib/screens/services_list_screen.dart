import 'package:flutter/material.dart';
import '../controllers/service_controller.dart';
import '../models/service.dart';

/// Tela que exibe uma lista de serviços com rolagem infinita
class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late final ServiceController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = ServiceController();
    _scrollController = ScrollController();

    // Carrega a primeira página ao inicializar
    _controller.loadFirstPage();

    // Adiciona listener ao ScrollController para detectar quando chegar perto do final
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Detecta quando o usuário chega perto do final da lista
  void _onScroll() {
    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    if (isNearBottom) {
      _controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços com Rolagem Infinita'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          // Estado: Carregamento inicial
          if (_controller.isLoading && _controller.listOfServices.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado: Lista vazia
          if (_controller.listOfServices.isEmpty &&
              !_controller.isLoading &&
              _controller.errorMessage == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum serviço cadastrado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum serviço disponível no momento',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Estado: Erro ao carregar inicialmente
          if (_controller.errorMessage != null &&
              _controller.listOfServices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _controller.errorMessage ?? 'Erro desconhecido',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _controller.retryLoadingPage(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // Estado: Lista com itens e/ou carregando mais
          return ListView.builder(
            controller: _scrollController,
            itemCount: _controller.listOfServices.length +
                (_controller.isLoading ? 1 : 0) +
                (!_controller.hasMoreItems && _controller.listOfServices.isNotEmpty
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              // Renderiza os serviços
              if (index < _controller.listOfServices.length) {
                final service = _controller.listOfServices[index];
                return _ServiceTile(service: service);
              }

              // Renderiza indicador de carregamento adicional
              if (_controller.isLoading &&
                  index == _controller.listOfServices.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Carregando mais serviços...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              // Renderiza mensagem de fim da lista
              if (!_controller.hasMoreItems &&
                  index == _controller.listOfServices.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Todos os serviços foram carregados',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      // Renderiza mensagem de erro ao carregar mais itens (no final)
      floatingActionButton:
          _controller.errorMessage != null && _controller.listOfServices.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _controller.retryLoadingPage(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                )
              : null,
    );
  }
}

/// Widget que renderiza cada serviço na lista
class _ServiceTile extends StatelessWidget {
  final Service service;

  const _ServiceTile({required this.service});

  /// Mapeia o nome do ícone para o IconData correspondente
  IconData _getIcon(String iconName) {
    final icons = {
      'settings': Icons.settings,
      'build': Icons.build,
      'speed': Icons.speed,
      'directions_bike': Icons.directions_bike,
      'clean_hands': Icons.clean_hands,
      'format_paint': Icons.format_paint,
    };
    return icons[iconName] ?? Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(
            _getIcon(service.icon),
            color: Colors.teal.shade900,
          ),
        ),
        title: Text(
          service.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${service.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
