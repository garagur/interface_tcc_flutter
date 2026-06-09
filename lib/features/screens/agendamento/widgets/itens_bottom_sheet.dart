import 'package:flutter/material.dart';
import 'package:tcc_yoji/features/auth/models/item_agendamento.dart';
import 'package:tcc_yoji/features/screens/agendamento/agendamento_controller.dart';

class ItensBottomSheet extends StatefulWidget {
  final AgendamentoController controller;

  const ItensBottomSheet({super.key, required this.controller});

  static void show(BuildContext context, AgendamentoController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItensBottomSheet(controller: controller),
    );
  }

  @override
  State<ItensBottomSheet> createState() => _ItensBottomSheetState();
}

class _ItensBottomSheetState extends State<ItensBottomSheet> {
  static const _azul = Color(0xFF2196F3);
  static const _azul50 = Color(0xFFE3F2FD);
  static const _azulLight = Color(0xFFBBDEFB);

  AgendamentoController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildFilterBar(),
          _buildTableHead(),
          Expanded(child: _buildList()),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: _azul, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Itens Disponíveis',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _azul,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _azul50,
              border: Border.all(color: _azulLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_ctrl.todosItens.length} itens',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          TextField(
            onChanged: _ctrl.setFiltroBusca,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _azul),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _filterBtn('Todos', 'todos'),
              const SizedBox(width: 8),
              _filterBtn('Salas', 'sala'),
              const SizedBox(width: 8),
              _filterBtn('Equipamentos', 'equipamento'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, String tipo) {
    final isActive = _ctrl.filtroTipo == tipo;
    return GestureDetector(
      onTap: () => _ctrl.setFiltroTipo(tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? _azul : const Color(0xFFF8FAFC),
          border: Border.all(color: isActive ? _azul : const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHead() {
    return Container(
      color: _azul,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeadCell('Nome')),
          Expanded(flex: 2, child: _HeadCell('Tipo')),
          Expanded(flex: 1, child: _HeadCell('Ação')),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_ctrl.carregandoLista) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ctrl.itensFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum item encontrado.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }
    return ListView.builder(
      itemCount: _ctrl.itensFiltrados.length,
      itemBuilder: (context, index) =>
          _buildRow(_ctrl.itensFiltrados[index], index),
    );
  }

  Widget _buildRow(ItemAgendamento item, int index) {
    final selecionado = _ctrl.jaSelecionado(item.id, item.tipo);
    final indisponivel = !item.status;

    Color rowColor;
    if (selecionado) {
      rowColor = const Color(0xFFDBEAFE);
    } else if (index.isEven) {
      rowColor = Colors.white;
    } else {
      rowColor = _azul50;
    }

    return Opacity(
      opacity: indisponivel ? 0.45 : 1.0,
      child: Container(
        color: rowColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            // Nome + status badge
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    item.tipo == 'sala' ? Icons.meeting_room : Icons.devices,
                    size: 14,
                    color: const Color(0xFF42A5F5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.status
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.status ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.status
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tipo badge
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.tipo == 'sala'
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tipoLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.tipo == 'sala'
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
            ),
            // Botão ação
            Expanded(
              flex: 1,
              child: Center(
                child: selecionado
                    ? _actionBtn(
                        icon: Icons.remove,
                        color: const Color(0xFFB91C1C),
                        bg: const Color(0xFFFEE2E2),
                        onTap: () => _ctrl.removerItem(item.id, item.tipo),
                      )
                    : _actionBtn(
                        icon: Icons.add,
                        color: const Color(0xFF16A34A),
                        bg: const Color(0xFFDCFCE7),
                        onTap: indisponivel
                            ? null
                            : () => _ctrl.adicionarItem(item),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: onTap == null ? bg.withOpacity(0.4) : bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? color.withOpacity(0.4) : color,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final count = _ctrl.itensSelecionados.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _azul,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            count == 0
                ? 'Fechar'
                : 'Confirmar seleção ($count ${count == 1 ? 'item' : 'itens'})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  final String text;
  const _HeadCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
