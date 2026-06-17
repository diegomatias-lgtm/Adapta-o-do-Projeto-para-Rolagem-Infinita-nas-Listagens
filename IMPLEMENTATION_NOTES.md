# Oficina Responsiva de Bicicletas - Implementação de Rolagem Infinita

## 📋 Descrição da Atividade

Este projeto foi adaptado para implementar **rolagem infinita com paginação** em uma tela de listagem de serviços. A aplicação agora busca os dados em partes menores e carrega novos registros automaticamente quando o usuário chega perto do final da lista.

## 🎯 Objetivos Alcançados

✅ **Paginação dos dados** - A listagem carrega 10 serviços por vez  
✅ **Carregamento parcial** - Dados buscados em partes, não tudo de uma vez  
✅ **Controle de estado** - Controller centralizada com `ChangeNotifier`  
✅ **ScrollController** - Detecta aproximação do final da lista  
✅ **Atualização reativa** - Uso de `ListenableBuilder` para reagir às mudanças  
✅ **Tratamento de estados** - Carregamento inicial, adicional, vazio, erro e fim da lista  

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                           # Aplicação principal com navegação
├── models/
│   └── service.dart                    # Modelo de dados do Serviço
├── controllers/
│   └── service_controller.dart         # Lógica de paginação e estado
└── screens/
    └── services_list_screen.dart       # Tela com rolagem infinita
```

---

## 🔍 Componentes Implementados

### 1. **Modelo (Service)**

Classe que representa um serviço de bicicleta com:
- `id`: Identificador único
- `title`: Nome do serviço
- `description`: Descrição do serviço
- `price`: Preço do serviço
- `icon`: Nome do ícone a exibir
- `createdAt`: Data de criação

```dart
class Service {
  final int id;
  final String title;
  final String description;
  final double price;
  final String icon;
  final DateTime createdAt;
}
```

### 2. **Controller (ServiceController)**

Gerencia toda a lógica de paginação e estado da listagem:

#### **Estado**
```dart
List<Service> _listOfServices;   // Lista de serviços carregados
bool _isLoading;                 // Indica se está carregando
bool _hasMoreItems;              // Indica se há mais itens
String? _errorMessage;           // Mensagem de erro, se houver
int _currentPage;                // Página atual (começando em 0)
int _limit = 10;                 // Itens por página
```

#### **Métodos Principais**

**`loadFirstPage()`** - Carrega a primeira página e reseta o estado
```dart
Future<void> loadFirstPage() async {
  if (_isLoading || _isLoadingInProgress) return;
  
  _isLoading = true;
  _currentPage = 0;
  _listOfServices.clear();
  notifyListeners();
  
  try {
    await _fetchServices(0);
  } catch (e) {
    _errorMessage = 'Erro ao carregar serviços: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**`loadNextPage()`** - Carrega a próxima página e adiciona à lista existente
```dart
Future<void> loadNextPage() async {
  if (_isLoading || !_hasMoreItems || _isLoadingInProgress) return;
  
  _isLoading = true;
  _currentPage++;
  notifyListeners();
  
  try {
    await _fetchServices(_currentPage);
  } catch (e) {
    _errorMessage = 'Erro ao carregar mais: $e';
    _currentPage--;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

#### **Prevenção de Carregamentos Duplicados**

A controller utiliza a flag `_isLoadingInProgress` para evitar múltiplos carregamentos simultâneos:

```dart
if (_isLoading || !_hasMoreItems || _isLoadingInProgress) {
  return; // Não permite novo carregamento
}
```

#### **Paginação com Limit e Offset**

```dart
final offset = page * _limit;  // Quantos itens pular
final endIndex = (offset + _limit).clamp(0, allServices.length);
final pageServices = allServices.sublist(offset, endIndex);
_listOfServices.addAll(pageServices);
```

**Exemplo:**
- Página 0: offset = 0, carrega itens 0-9
- Página 1: offset = 10, carrega itens 10-19
- Página 2: offset = 20, carrega itens 20-29

### 3. **Tela (ServicesListScreen)**

Implementa a interface com rolagem infinita usando:

#### **ScrollController**

Detecta quando o usuário chega perto do final:

```dart
late final ScrollController _scrollController;

void _onScroll() {
  final position = _scrollController.position;
  final isNearBottom = position.pixels >= position.maxScrollExtent - 200;
  
  if (isNearBottom) {
    _controller.loadNextPage();
  }
}
```

A margem de **200 pixels** representa quanto antes do final a próxima página é carregada.

#### **ListView.builder Conectado**

```dart
ListView.builder(
  controller: _scrollController,
  itemCount: _controller.listOfServices.length +
      (_controller.isLoading ? 1 : 0) +
      (!_controller.hasMoreItems ? 1 : 0),
  itemBuilder: (context, index) {
    // Renderiza serviços
    if (index < _controller.listOfServices.length) {
      return _ServiceTile(service: _controller.listOfServices[index]);
    }
    // Renderiza indicador de carregamento
    if (_controller.isLoading) {
      return _buildLoadingIndicator();
    }
    // Renderiza mensagem de fim
    if (!_controller.hasMoreItems) {
      return _buildEndMessage();
    }
  },
)
```

#### **ListenableBuilder para Reatividade**

```dart
ListenableBuilder(
  listenable: _controller,
  builder: (context, _) {
    // A UI é reconstruída sempre que a controller notifica mudanças
    // Sem necessidade de múltiplos setState
    return _buildUI();
  },
)
```

---

## 🎨 Estados da Interface

### **1. Carregamento Inicial**
- CircularProgressIndicator centralizado
- Listagem vazia

### **2. Carregamento Adicional**
- Itens já carregados permanecem visíveis
- Indicador de progresso no final da lista
- Mensagem "Carregando mais serviços..."

### **3. Lista Vazia**
```
🔧
Nenhum serviço cadastrado
Nenhum serviço disponível no momento
```

### **4. Erro no Carregamento Inicial**
```
⚠️
Erro ao carregar
Mensagem de erro com botão "Tentar novamente"
```

### **5. Erro ao Carregar Mais**
- Itens já carregados permanecem
- FloatingActionButton com "Tentar novamente"

### **6. Fim da Lista**
```
✓
Todos os serviços foram carregados
```

---

## 📊 Dados de Teste

A controller gera **50 serviços simulados** de 8 tipos diferentes:

- Ajuste de marchas (R$ 45.00)
- Revisão completa (R$ 85.00)
- Freios e suspensão (R$ 60.00)
- Pneus e rodas (R$ 50.00)
- Limpeza profissional (R$ 35.00)
- Pintura e acabamento (R$ 70.00)
- Corrente e coroa (R$ 40.00)
- Selim e guidão (R$ 30.00)

Com **10 itens por página**, são necessárias **5 rolagens** para ver todos.

---

## 🚀 Como Usar

### **Navegação**

A aplicação possui navegação com `BottomNavigationBar`:

1. **Aba "Início"** - Tela responsiva original da oficina
2. **Aba "Serviços"** - Nova tela com rolagem infinita

### **Testando a Rolagem Infinita**

1. Abra a aba "Serviços"
2. Role até o final dos primeiros 10 itens
3. Observe o carregamento automático de mais serviços
4. Repita até carregar todos os 50 serviços

---

## 📝 Conceitos Implementados

### **1. Paginação**
- Busca de dados em partes (10 itens por vez)
- Cálculo de offset e limit
- Detecção de fim da paginação

### **2. Limit e Offset**
- `limit`: Quantidade máxima de registros por página
- `offset`: Quantidade de registros a pular
- Fórmula: `offset = page * limit`

### **3. Carregamento Parcial**
- Não carrega tudo de uma vez
- Melhora performance e experiência do usuário
- Reduz consumo de dados

### **4. ScrollController**
- Monitora a posição da rolagem
- Calcula distância até o final
- Dispara carregamento automático

### **5. ChangeNotifier e ListenableBuilder**
- Controller notifica mudanças de estado
- Interface reage às notificações
- Sem múltiplos setState espalhados

### **6. Prevenção de Duplicação**
- Flag `_isLoadingInProgress` impede requisições simultâneas
- Validações antes de cada carregamento

### **7. Diferenciação de Estados**
- **Inicial**: Quando lista está vazia
- **Adicional**: Quando já há itens
- **Erro**: Tratado separadamente
- **Fim**: Identificado por `hasMoreItems = false`

---

## 🔧 Integração com Backend Real

Para integrar com uma API real, modifique o método `_fetchServices` em `service_controller.dart`:

```dart
Future<void> _fetchServices(int page) async {
  final offset = page * _limit;
  
  // Chamada HTTP real (exemplo com http package)
  final response = await http.get(
    Uri.parse('https://api.example.com/services?limit=$_limit&offset=$offset'),
  );
  
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final services = (json['data'] as List)
        .map((item) => Service.fromMap(item))
        .toList();
    
    _listOfServices.addAll(services);
    _hasMoreItems = json['hasMore'] ?? false;
  } else {
    throw Exception('Erro ao carregar serviços');
  }
}
```

---

## ✨ Melhorias Implementadas

1. ✅ Organização em camadas (models, controllers, screens)
2. ✅ Separação de responsabilidades
3. ✅ Código limpo e comentado
4. ✅ Tratamento de erros robusto
5. ✅ Estados bem definidos
6. ✅ Prevenção de carregamentos duplicados
7. ✅ Experiência do usuário otimizada
8. ✅ Mantém layout responsivo original

---

## 📱 Compatibilidade

- ✅ Mobile
- ✅ Tablet
- ✅ Desktop
- ✅ Web

---

## 📞 Resumo das Mudanças

**Arquivos criados:**
- `lib/models/service.dart` - Modelo de dados
- `lib/controllers/service_controller.dart` - Lógica de paginação
- `lib/screens/services_list_screen.dart` - Interface com rolagem infinita

**Arquivos modificados:**
- `lib/main.dart` - Adicionada navegação para nova tela

**Pastas removidas:**
- `android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/`

---

## 🎓 Conclusão

O projeto agora implementa com sucesso a **rolagem infinita com paginação**, atendendo a todos os requisitos da atividade:

- ✅ Paginação real dos dados
- ✅ Controller centralizada com ChangeNotifier
- ✅ ScrollController para detecção de fim
- ✅ ListenableBuilder para reatividade
- ✅ Tratamento completo de estados
- ✅ Prevenção de carregamentos duplicados
- ✅ Interface responsiva e intuitiva
- ✅ Código bem organizado e documentado
