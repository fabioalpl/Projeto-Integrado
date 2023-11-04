class Usuario {
  String idUsuario;
  String nome;
  String email;
  String urlImagem;
  String perfil;

  Usuario(this.idUsuario, this.nome, this.email,
      {this.urlImagem = "", this.perfil = ""});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "nome": this.nome,
      "email": this.email,
      "perfil": this.perfil,
      "urlImagem": this.urlImagem,
    };

    return map;
  }
}
