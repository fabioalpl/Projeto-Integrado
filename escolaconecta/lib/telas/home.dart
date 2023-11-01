import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/chat");
              },
              child: Image.asset(
                  'lib/imagens/chat.png'), // Substitua pelo caminho da primeira imagem
            ),
            SizedBox(height: 20), // Espaço entre as imagens
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Image.asset(
                  'lib/imagens/atividades.png'), // Substitua pelo caminho da segunda imagem
            ),
          ],
        ),
      ),
    );
  }
}
