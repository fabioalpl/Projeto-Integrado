import 'package:flutter/material.dart';

class Usuario {
  String idUsuario;
  String nome;
  String email;

  Usuario(this.idUsuario, this.nome, this.email);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "nome": this.nome,
      "email": this.email,
    };

    return map;
  }
}
