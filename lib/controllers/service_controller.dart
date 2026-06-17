import 'package:flutter/foundation.dart';
import '../models/service.dart';

/// Controller responsável por gerenciar a paginação e rolagem infinita da lista de serviços
class ServiceController extends ChangeNotifier {
  // Estado da listagem
  final List<Service> _listOfServices = [];
  bool _isLoading = false;
  bool _hasMoreItems = true;
  String? _errorMessage;
  int _currentPage = 0;
  final int _limit = 10; // Quantidade de itens por página

  // Flag para evitar carregamentos duplicados
  bool _isLoadingInProgress = false;

  // Getters
  List<Service> get listOfServices => _listOfServices;
  bool get isLoading => _isLoading;
  bool get hasMoreItems => _hasMoreItems;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get limit => _limit;

  /// Carrega a primeira página e reseta o estado
  Future<void> loadFirstPage() async {
    // Se já está carregando, não faz nada
    if (_isLoading || _isLoadingInProgress) {
      return;
    }

    _isLoading = true;
    _isLoadingInProgress = true;
    _errorMessage = null;
    _currentPage = 0;
    _listOfServices.clear();
    notifyListeners();

    try {
      await _fetchServices(0);
      _isLoadingInProgress = false;
    } catch (e) {
      _errorMessage = 'Erro ao carregar serviços: $e';
      _isLoadingInProgress = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a próxima página e adiciona os itens à lista existente
  Future<void> loadNextPage() async {
    // Evita carregamentos duplicados e carrega quando não há mais itens
    if (_isLoading || !_hasMoreItems || _isLoadingInProgress) {
      return;
    }

    _isLoading = true;
    _isLoadingInProgress = true;
    _errorMessage = null;
    _currentPage++;
    notifyListeners();

    try {
      await _fetchServices(_currentPage);
      _isLoadingInProgress = false;
    } catch (e) {
      _errorMessage = 'Erro ao carregar mais serviços: $e';
      _currentPage--; // Reverte o incremento da página em caso de erro
      _isLoadingInProgress = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tenta novamente carregar após um erro
  Future<void> retryLoadingPage() async {
    _errorMessage = null;
    if (_listOfServices.isEmpty) {
      // Se não há itens carregados ainda, carrega a primeira página
      await loadFirstPage();
    } else {
      // Se há itens, carrega a próxima página
      await loadNextPage();
    }
  }

  /// Simula uma busca à API com delay
  /// 
  /// Este método simula uma chamada a um repositório ou API real.
  /// Em um projeto real, isso seria uma chamada HTTP para um backend.
  Future<void> _fetchServices(int page) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 800));

    // Simula a lista completa de serviços
    final allServices = _generateMockServices();

    // Calcula offset baseado na página
    final offset = page * _limit;

    // Valida se não passamos do total de itens
    if (offset >= allServices.length) {
      _hasMoreItems = false;
      return;
    }

    // Extrai apenas os itens da página atual
    final endIndex = (offset + _limit).clamp(0, allServices.length);
    final pageServices = allServices.sublist(offset, endIndex);

    // Adiciona os serviços à lista
    _listOfServices.addAll(pageServices);

    // Verifica se há mais itens para carregar
    _hasMoreItems = endIndex < allServices.length;
  }

  /// Gera uma lista simulada de 50 serviços para demonstração
  /// 
  /// Em um projeto real, essa lista viria de uma API ou banco de dados.
  List<Service> _generateMockServices() {
    final services = <Service>[];
    final serviceTemplates = [
      {
        'title': 'Ajuste de marchas',
        'description': 'Troca de cabos, regulagem e desempenho perfeito.',
        'icon': 'settings',
        'price': 45.00,
      },
      {
        'title': 'Revisão completa',
        'description': 'Inspeção geral, limpeza e manutenção de rotina.',
        'icon': 'build',
        'price': 85.00,
      },
      {
        'title': 'Freios e suspensão',
        'description': 'Freios ajustados, pastilhas substituídas e segurança.',
        'icon': 'speed',
        'price': 60.00,
      },
      {
        'title': 'Pneus e rodas',
        'description': 'Calibragem, troca de pneus e alinhamento.',
        'icon': 'directions_bike',
        'price': 50.00,
      },
      {
        'title': 'Limpeza profissional',
        'description': 'Limpeza completa com produtos especializados.',
        'icon': 'clean_hands',
        'price': 35.00,
      },
      {
        'title': 'Pintura e acabamento',
        'description': 'Retoque de pintura e proteção contra ferrugem.',
        'icon': 'format_paint',
        'price': 70.00,
      },
      {
        'title': 'Corrente e coroa',
        'description': 'Limpeza, lubricação ou troca de corrente.',
        'icon': 'settings',
        'price': 40.00,
      },
      {
        'title': 'Selim e guidão',
        'description': 'Ajuste de posição, limpeza ou troca.',
        'icon': 'build',
        'price': 30.00,
      },
    ];

    // Gera 50 serviços alternando entre os templates
    for (int i = 0; i < 50; i++) {
      final template = serviceTemplates[i % serviceTemplates.length];
      services.add(
        Service(
          id: i + 1,
          title: '${template['title']} ${(i ~/ serviceTemplates.length) + 1}',
          description: template['description'] as String,
          price: template['price'] as double,
          icon: template['icon'] as String,
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }

    return services;
  }
}
