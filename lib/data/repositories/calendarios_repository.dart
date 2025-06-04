import 'package:cronograma/core/supabase_helper.dart';
import '../models/calendarios_model.dart';

class CalendariosRepository {
  // Inserir novo calendário
  Future<void> insertCalendario(Calendarios calendario) async {
    try {
      final data = {
        ...calendario.toMap(),
        'data_inicio': calendario.dataInicio,
        'data_fim': calendario.dataFim,
      };

      await SupabaseHelper.client.from('Calendarios').insert(data);
    } catch (e) {
      throw Exception('Erro ao inserir calendário: $e');
    }
  }

  // Obter todos os calendários
  Future<List<Calendarios>> getCalendarios() async {
    try {
      final response = await SupabaseHelper.client
          .from('Calendarios')
          .select()
          .order('data_inicio');
      return (response as List).map((map) {
        return Calendarios.fromMap(map as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar calendários: $e');
    }
  }

  // Atualizar calendário existente
  Future<void> updateCalendario(Calendarios calendario) async {
    try {
      final data = {
        ...calendario.toMap(),
        'data_inicio': calendario.dataInicio,
        'data_fim': calendario.dataFim,
      };

      await SupabaseHelper.client
          .from('Calendarios')
          .update(data)
          .eq('idcalendarios', calendario.idcalendarios as Object);
    } catch (e) {
      throw Exception('Erro ao atualizar calendário: $e');
    }
  }

  // Deletar calendário
  Future<void> deleteCalendario(int id) async {
    try {
      await SupabaseHelper.client
          .from('Calendarios')
          .delete()
          .eq('idcalendarios', id);
    } catch (e) {
      throw Exception('Erro ao deletar calendário: $e');
    }
  }

  // Buscar calendários por turma
  Future<List<Calendarios>> getCalendariosPorTurma(int idTurma) async {
    try {
      final response = await SupabaseHelper.client
          .from('Calendarios')
          .select()
          .eq('idturma', idTurma)
          .order('data_inicio');

      return (response as List).map((map) {
        return Calendarios.fromMap(map as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar calendários por turma: $e');
    }
  }
}
