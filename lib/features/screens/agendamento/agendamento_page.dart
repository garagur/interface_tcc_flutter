import 'package:flutter/material.dart';
import 'package:tcc_yoji/features/screens/agendamento/agendamento_controller.dart';
import 'package:tcc_yoji/features/screens/agendamento/widgets/itens_bottom_sheet.dart';
import 'package:tcc_yoji/features/screens/agendamento/widgets/selected_item_card.dart';

class AgendamentoPage extends StatefulWidget {
  final String token;
  final String matricula;
  final VoidCallback onSair;

  const AgendamentoPage({
    super.key,
    required this.token,
    required this.matricula,
    required this.onSair,
  });

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  late AgendamentoController _ctrl;

  static const _azul = Color(0xFF2196F3);
  static const _azulDark = Color(0xFF1976D2);
  static const _azul50 = Color(0xFFE3F2FD);
  static const _azulLight = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    _ctrl = AgendamentoController(
      token: widget.token,
      matricula: widget.matricula,
    );
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _ctrl.carregarLista());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ctrl.dataAgendamento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) _ctrl.setData(picked);
  }

  Future<void> _pickHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _ctrl.horaInicio,
    );
    if (picked != null) _ctrl.setHoraInicio(picked);
  }

  Future<void> _pickHoraFim() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _ctrl.horaFim,
    );
    if (picked != null) _ctrl.setHoraFim(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            const SizedBox(height: 16),
            _buildItensSection(),
            const SizedBox(height: 24),
            _buildFeedback(),
            _buildActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Portal de Agendamento',
            style: TextStyle(
              color: _azul,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Novo Agendamento',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _azul),
          onPressed: widget.onSair,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month, color: _azul, size: 22),
                SizedBox(width: 8),
                Text(
                  'Dados do Agendamento',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _azul,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTappableField(
              label: 'Data',
              value: _formatDate(_ctrl.dataAgendamento),
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTappableField(
                    label: 'Hora início',
                    value: _formatTime(_ctrl.horaInicio),
                    icon: Icons.access_time,
                    onTap: _pickHoraInicio,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTappableField(
                    label: 'Hora fim',
                    value: _formatTime(_ctrl.horaFim),
                    icon: Icons.access_time_filled,
                    onTap: _pickHoraFim,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildObsField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _azul),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observação',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: _ctrl.setObs,
          decoration: InputDecoration(
            hintText: 'Ex: Aula de reposição',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _azul),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItensSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, color: _azul, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Itens Selecionados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _azul,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _azul50,
                    border: Border.all(color: _azulLight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_ctrl.itensSelecionados.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _azulDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_ctrl.itensSelecionados.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _azul50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        color: Color(0xFF90CAF9), size: 28),
                    SizedBox(height: 6),
                    Text(
                      'Nenhum item adicionado ainda.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_ctrl.itensSelecionados.map(
                (item) => SelectedItemCard(
                  item: item,
                  onRemover: () => _ctrl.removerItem(item.id, item.tipo),
                ),
              )),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _ctrl.carregandoLista
                    ? null
                    : () => ItensBottomSheet.show(context, _ctrl),
                icon: _ctrl.carregandoLista
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add, size: 18),
                label: Text(
                  _ctrl.carregandoLista
                      ? 'Carregando itens...'
                      : 'Selecionar Itens',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _azul,
                  side: const BorderSide(color: _azul),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    if (_ctrl.erro.isEmpty && _ctrl.sucesso.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _ctrl.erro.isNotEmpty
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _ctrl.erro.isNotEmpty
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              size: 18,
              color: _ctrl.erro.isNotEmpty
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _ctrl.erro.isNotEmpty ? _ctrl.erro : _ctrl.sucesso,
                style: TextStyle(
                  fontSize: 13,
                  color: _ctrl.erro.isNotEmpty
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _ctrl.resetForm,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Limpar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _ctrl.carregando ? null : _ctrl.salvarAgendamento,
            icon: _ctrl.carregando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, size: 18),
            label: Text(
                _ctrl.carregando ? 'Salvando...' : 'Confirmar Agendamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _azul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}