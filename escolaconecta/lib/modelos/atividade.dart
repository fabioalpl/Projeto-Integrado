class Atividade {
  String idUsuario;
  String idResponsavel;
  String data;
  String hora;
  String descricao;
  String latitude;
  String longitude;
  bool aceita;

  Atividade(
    this.idUsuario,
    this.idResponsavel,
    this.data,
    this.hora,
    this.descricao,
    this.latitude,
    this.longitude,
    this.aceita,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "idResponsavel": this.idResponsavel,
      "data": this.data,
      "hora": this.hora,
      "descricao": this.descricao,
      "latitude": this.latitude,
      "longitude": this.longitude,
      "aceita": this.aceita == true ? "Sim" : "Não",
    };

    return map;
  }
}
