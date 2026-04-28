import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'equipment_registration_screen.dart';
import 'user_registration_screen.dart';
import 'schedule_detail_screen.dart';
import 'schedules_by_item_screen.dart';

class HomeScreen extends StatelessWidget {
  final String matricula;

  const HomeScreen({super.key, required this.matricula});

  // Dados fictícios para simular agendamentos da API
  final List<Map<String, String>> agendamentos = const [
    {
      'nome': 'João Silva',
      'item': 'Sala 101',
      'dataInicio': '28/04/2025 08:00',
      'dataFim': '28/04/2025 10:00',
    },
    {
      'nome': 'Maria Souza',
      'item': 'Projetor HD',
      'dataInicio': '28/04/2025 09:00',
      'dataFim': '28/04/2025 11:00',
    },
    {
      'nome': 'Carlos Lima',
      'item': 'Sala de Reunião',
      'dataInicio': '29/04/2025 14:00',
      'dataFim': '29/04/2025 16:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },

    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
    {
      'nome': 'Ana Paula',
      'item': 'Notebook Dell',
      'dataInicio': '30/04/2025 07:00',
      'dataFim': '30/04/2025 12:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seu Portal de Agendamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Matrícula: $matricula',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Botão de Agendamentos destacado
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(matricula: matricula),
                  ),
                );
              },
              icon: const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.blue,
              ),
              label: const Text(
                'Agendamentos',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Menu de navegação
          Container(
            width: double.infinity,
            color: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Meus\nAgendamentos',
                  color: Colors.blue.shade200,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScheduleScreen(matricula: matricula),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.add_location,
                  title: 'Cadastrar\nSala',
                  color: Colors.purple.shade200,
                  onTap: () {},
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.playlist_add,
                  title: 'Cadastrar\nEquipamento',
                  color: Colors.red.shade200,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EquipmentRegistrationScreen(matricula: matricula),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.person_add,
                  title: 'Cadastrar\nUsuário',
                  color: Colors.teal.shade200,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserRegistrationScreen(matricula: matricula),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Título da tabela
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Agendamentos Recentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    '${agendamentos.length} registros',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabela
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Cabeçalho da tabela
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        _TableHeaderCell(text: 'Nome', flex: 2),
                        _TableHeaderCell(text: 'Item', flex: 2),
                        _TableHeaderCell(text: 'Início', flex: 2),
                        _TableHeaderCell(text: 'Fim', flex: 2),
                        _TableHeaderCell(text: 'Ações', flex: 1),
                      ],
                    ),
                  ),
                  // Linhas da tabela
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade100),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: agendamentos.length,
                          itemBuilder: (context, index) {
                            final item = agendamentos[index];
                            final isEven = index % 2 == 0;
                            return Container(
                              color: isEven
                                  ? Colors.white
                                  : Colors.blue.shade50,
                              child: Row(
                                children: [
                                  _TableDataCell(
                                    text: item['nome']!,
                                    flex: 2,
                                    icon: Icons.person_outline,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 6,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          // Filtrar agendamentos do item
                                          final agendamentosDoItem =
                                              agendamentos
                                                  .where(
                                                    (a) =>
                                                        a['item'] ==
                                                        item['item'],
                                                  )
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SchedulesByItemScreen(
                                                    itemNome: item['item']!,
                                                    agendamentos:
                                                        agendamentosDoItem,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 14,
                                              color: Colors.blue.shade400,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['item']!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  _TableDataCell(
                                    text: item['dataInicio']!,
                                    flex: 2,
                                    isDate: true,
                                  ),
                                  _TableDataCell(
                                    text: item['dataFim']!,
                                    flex: 2,
                                    isDate: true,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 4,
                                      ),
                                      child: Tooltip(
                                        message: 'Detalhes',
                                        child: IconButton(
                                          iconSize: 18,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Colors.blue.shade600,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ScheduleDetailScreen(
                                                      nome: item['nome']!,
                                                      item: item['item']!,
                                                      dataInicio:
                                                          item['dataInicio']!,
                                                      dataFim: item['dataFim']!,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão Agendar
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScheduleScreen(matricula: matricula),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  'Novo Agendamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _TableHeaderCell({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TableDataCell extends StatelessWidget {
  final String text;
  final int flex;
  final IconData? icon;
  final bool isDate;

  const _TableDataCell({
    required this.text,
    required this.flex,
    this.icon,
    this.isDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 14, color: Colors.blue.shade400),
            if (isDate)
              Icon(Icons.access_time, size: 14, color: Colors.blue.shade400),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade800,
                fontWeight: isDate ? FontWeight.normal : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
