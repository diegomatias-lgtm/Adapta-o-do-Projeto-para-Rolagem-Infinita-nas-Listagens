import 'package:flutter/material.dart';
import 'screens/services_list_screen.dart';

void main() {
  runApp(const BikeWorkshopApp());
}

class BikeWorkshopApp extends StatelessWidget {
  const BikeWorkshopApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Responsiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const BikeWorkshopHome(),
    );
  }
}

class BikeWorkshopHome extends StatefulWidget {
  const BikeWorkshopHome({super.key});

  @override
  State<BikeWorkshopHome> createState() => _BikeWorkshopHomeState();
}

class _BikeWorkshopHomeState extends State<BikeWorkshopHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina de Bicicletas'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (width >= 1000) {
                  return const DesktopBikeWorkshop();
                }
                if (width >= 600) {
                  return const TabletBikeWorkshop();
                }
                return const MobileBikeWorkshop();
              },
            )
          : const ServicesListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Serviços',
          ),
        ],
      ),
    );
  }
}

class MobileBikeWorkshop extends StatelessWidget {
  const MobileBikeWorkshop({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeroSection(showImage: false),
          const _SectionTitle('Serviços rápidos para sua bike'),
          const _ServiceCards(columns: 1),
          const _SectionTitle('Por que nos escolher?'),
          const _FeatureList(),
          const _SectionTitle('Converse com nossa equipe'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Agendar revisão'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class TabletBikeWorkshop extends StatelessWidget {
  const TabletBikeWorkshop({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _HeroSection(showImage: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _SectionTitle('Serviços rápidos para sua bike'),
                _ServiceCards(columns: 2),
                _SectionTitle('Por que nos escolher?'),
                _FeatureList(),
                _ContactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopBikeWorkshop extends StatelessWidget {
  const DesktopBikeWorkshop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _HeroSection(showImage: true),
                  SizedBox(height: 24),
                  _SectionTitle('Serviços rápidos para sua bike'),
                  _ServiceCards(columns: 2),
                  SizedBox(height: 24),
                  _SectionTitle('Por que nos escolher?'),
                  _FeatureList(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.all(32),
            child: const _ContactCard(),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool showImage;
  const _HeroSection({required this.showImage});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleStyle = TextStyle(
      fontSize: width >= 1000
          ? 44
          : width >= 600
          ? 36
          : 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      height: 1.1,
    );
    final bodyStyle = TextStyle(
      fontSize: width >= 1000 ? 18 : 16,
      color: Colors.white70,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff00695C), Color(0xff004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Oficina Responsiva de Bicicletas', style: titleStyle),
          const SizedBox(height: 16),
          Text(
            'Ajuste de marchas, revisão completa e atendimento ágil para ciclistas de todos os tamanhos. Layout responsivo para seu celular, tablet e desktop.',
            style: bodyStyle,
          ),
          const SizedBox(height: 24),
          Wrap(
            runSpacing: 12,
            spacing: 12,
            children: const [
              _StatLabel('10+ anos', 'de experiência'),
              _StatLabel('24h', 'entrega de orçamento'),
              _StatLabel('100% seguro', 'peças originais'),
            ],
          ),
          if (showImage) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  'https://images.pexels.com/photos/276517/pexels-photo-276517.jpeg?auto=compress&cs=tinysrgb&w=1080',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String value;
  final String label;

  const _StatLabel(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 20, right: 20),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ServiceCards extends StatelessWidget {
  final int columns;
  const _ServiceCards({required this.columns});

  @override
  Widget build(BuildContext context) {
    final services = const [
      _ServiceInfo(
        icon: Icons.settings,
        title: 'Ajuste de marchas',
        description: 'Troca de cabos, regulagem e desempenho perfeito.',
      ),
      _ServiceInfo(
        icon: Icons.build,
        title: 'Revisão completa',
        description: 'Inspeção geral, limpeza e manutenção de rotina.',
      ),
      _ServiceInfo(
        icon: Icons.speed,
        title: 'Freios e suspensão',
        description: 'Freios ajustados, pastilhas substituídas e segurança.',
      ),
      _ServiceInfo(
        icon: Icons.directions_bike,
        title: 'Pneus e rodas',
        description: 'Calibragem, troca de pneus e alinhamento.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        runSpacing: 16,
        spacing: 16,
        alignment: WrapAlignment.center,
        children: services
            .map(
              (service) => SizedBox(
                width: columns == 1 ? double.infinity : 340,
                child: _ServiceCard(info: service),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ServiceInfo {
  final IconData icon;
  final String title;
  final String description;
  const _ServiceInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceInfo info;
  const _ServiceCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.shade100,
              child: Icon(info.icon, color: Colors.teal.shade900),
            ),
            const SizedBox(height: 16),
            Text(
              info.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              info.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Orçamento transparente sem surpresas.',
      'Peças originais ou homologadas.',
      'Equipe experiente para bicicletas de passeio e estrada.',
      'Qualidade e atendimento rápido, mesmo em agendas cheias.',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agende sua revisão',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Atendemos bicicletas urbanas, de estrada e mountain bikes com peças de qualidade.',
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.teal),
                SizedBox(width: 10),
                Expanded(child: Text('Rua da Bicicleta, 123 - Centro')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.access_time, color: Colors.teal),
                SizedBox(width: 10),
                Expanded(child: Text('Segunda a sábado: 8h - 18h')),
              ],
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message),
              label: const Text('Fale conosco'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
