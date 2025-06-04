import 'package:cronograma/data/models/turma_model.dart' show Turma;

class TurmaComNomes {
  final int? idturma;
  final String turma;
  final int? idcurso;
  final String nomecurso; // Novo campo
  final int idturno;
  final int idinstrutor;
  final String nomeinstrutor; // Novo campo
  final int? idunidadecurricular;
  final String turno;

  TurmaComNomes(
      {this.idturma,
      required this.turma,
      this.idcurso,
      required this.nomecurso,
      required this.idturno,
      required this.idinstrutor,
      required this.nomeinstrutor,
      this.idunidadecurricular,
      required this.turno});

  factory TurmaComNomes.fromMap(Map<String, dynamic> map) {
    return TurmaComNomes(
      idturma: Turma.safeParseInt(map['idturma']),
      turma: map['turma']?.toString().trim() ?? '[Sem nome]',
      idcurso: Turma.safeParseInt(map['idcurso']),
      nomecurso: map['nomecurso']?.toString().trim() ?? '[Sem nome]',
      idturno: Turma.safeParseInt(map['idturno']) ?? 1,
      idinstrutor: Turma.safeParseInt(map['idinstrutor']) ?? 0,
      nomeinstrutor: map['nomeinstrutor']?.toString().trim() ?? '[Sem nome]',
      idunidadecurricular: Turma.safeParseInt(map['idunidadecurricular']),
      turno: map['turno']?.toString().trim() ?? '[Sem Turno]',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idturma': idturma,
      'turma': turma,
      'idcurso': idcurso,
      'nomecurso': nomecurso,
      'idturno': idturno,
      'idinstrutor': idinstrutor,
      'nomeinstrutor': nomeinstrutor,
      'turno': turno,
      if (idunidadecurricular != null)
        'idunidadecurricular': idunidadecurricular,
    };
  }
}
