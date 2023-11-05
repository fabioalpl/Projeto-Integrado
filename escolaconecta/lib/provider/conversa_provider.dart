import 'package:escolaconecta/modelos/usuario.dart';
import 'package:flutter/material.dart';

class ConversaProvider with ChangeNotifier {
  Usuario? _usuariologado;

  Usuario? get usuarioLogado => _usuariologado;

  set usuarioLogado(Usuario? usuario) {
    _usuariologado = usuario;
    notifyListeners();
  }
}
