import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendarAulasPage extends StatefulWidget {
  final List<DateTime> selectedDays;
  final Map<String, Map<String, dynamic>> periodoConfig;

  const AgendarAulasPage({
    super.key,
    required this.selectedDays,
    required this.periodoConfig,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AgendarAulasPageState createState() => _AgendarAulasPageState();
}

class _AgendarAulasPageState extends State<AgendarAulasPage> {
  String _periodo = 'Manhã';
  int _horasAula = 1;
  int? _selectedTurmaId;
  int? _selectedUcId;
  bool _isLoading = false;

  List<Map<String, dynamic>> _turmas = [];
  List<Map<String, dynamic>> _ucs = [];
  List<Map<String, dynamic>> _ucsFiltradas = [];
  final Map<int, int> _cargaHorariaUc = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;

      final turmasResponse = await client.from('Turma').select();
      final ucsResponse = await client.from('unidades_curriculares').select();

      final cargaHorariaMap = <int, int>{};
      for (var uc in ucsResponse) {
        cargaHorariaMap[uc['iduc'] as int] = (uc['cargahoraria'] ?? 0) as int;
      }

      if (mounted) {
        setState(() {
          _turmas = List<Map<String, dynamic>>.from(turmasResponse);
          _ucs = List<Map<String, dynamic>>.from(ucsResponse);
          _ucsFiltradas = [];
          _cargaHorariaUc.addAll(cargaHorariaMap);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _podeSalvar() {
    return _selectedTurmaId != null && _selectedUcId != null && _horasAula > 0;
  }

  Future<void> _salvarAulas() async {
    if (!_podeSalvar()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final cargaTotalNecessaria = _horasAula * widget.selectedDays.length;

      if ((_cargaHorariaUc[_selectedUcId] ?? 0) < cargaTotalNecessaria) {
        throw Exception('Carga horária insuficiente para esta UC');
      }

      final inserts = widget.selectedDays.map((dia) {
        return {
          'iduc': _selectedUcId,
          'idturma': _selectedTurmaId,
          'data': DateFormat('yyyy-MM-dd').format(dia),
          'horario': widget.periodoConfig[_periodo]!['horario'],
          'status': 'Agendada',
          'horas': _horasAula,
        };
      }).toList();

      final insertResponse = await client.from('Aulas').insert(inserts);
      if (insertResponse.error != null) throw insertResponse.error!;

      final novaCarga =
          (_cargaHorariaUc[_selectedUcId] ?? 0) - cargaTotalNecessaria;

      final updateResponse = await client
          .from('unidades_curriculares')
          .update({'cargahoraria': novaCarga}).eq('iduc', _selectedUcId!);

      if (updateResponse.error != null) throw updateResponse.error!;

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar aulas: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Aulas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Turma'),
                    value: _selectedTurmaId,
                    items: _turmas.map((turma) {
                      return DropdownMenuItem<int>(
                        value: turma['idturma'],
                        child: Text(turma['nome']),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final client = Supabase.instance.client;
                      final response = await client
                          .from('Turma')
                          .select()
                          .eq('idturma', value)
                          .single();
                      if (mounted) {
                        setState(() {
                          _selectedTurmaId = value;
                          _selectedUcId = null;
                          _ucsFiltradas = _ucs
                              .where(
                                  (uc) => uc['idcurso'] == response['idcurso'])
                              .toList();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration:
                        const InputDecoration(labelText: 'Unidade Curricular'),
                    value: _selectedUcId,
                    items: _ucsFiltradas.map((uc) {
                      return DropdownMenuItem<int>(
                        value: uc['iduc'],
                        child: Text(uc['nome']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedUcId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Período'),
                    value: _periodo,
                    items: widget.periodoConfig.keys.map((periodo) {
                      return DropdownMenuItem<String>(
                        value: periodo,
                        child: Text(periodo),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _periodo = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Horas por aula'),
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _horasAula = int.tryParse(value) ?? 1,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _podeSalvar() ? _salvarAulas : null,
                    child: const Text('Agendar'),
                  ),
                ],
              ),
            ),
    );
  }
}
