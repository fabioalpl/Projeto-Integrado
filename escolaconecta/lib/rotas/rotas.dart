import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/telas/chat.dart';
import 'package:escolaconecta/telas/home.dart';
import 'package:escolaconecta/telas/login.dart';
import 'package:escolaconecta/telas/mensagens.dart';
import 'package:flutter/material.dart';

class Rotas {
  static Route<dynamic> gerarRota(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case "/login":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case "/home":
        return MaterialPageRoute(
          builder: (_) => Home(),
        );
      case "/chat":
        return MaterialPageRoute(
          builder: (_) => Chat(),
        );
      case "/mensagens":
        return MaterialPageRoute(builder: (_) => Mensagens(args as Usuario));
      case "/atividades":
        return MaterialPageRoute(
          builder: (_) => Chat(),
        );
    }

    return _erroRota();
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
