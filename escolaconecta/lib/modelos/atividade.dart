class Atividade {
  String idUsuario;
  String data;
  String hora;
  String descricao;
  bool aceita;

  Atividade(
    this.idUsuario,
    this.data,
    this.hora,
    this.descricao,
    this.aceita,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "data": this.data,
      "hora": this.hora,
      "descricao": this.descricao,
      "aceita": this.aceita == true ? "Sim" : "Não",
    };

    return map;
  }
}
