import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final Usuario? usuario;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Home(this.usuario, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: Center(
        child: usuario != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Seja Bem vindo: " +
                        usuario!.nome +
                        " - " +
                        usuario!.perfil,
                    style: TextStyle(
                      fontSize: 20.0, // Defina o tamanho da fonte desejado
                      color: Colors.white, // Define a cor do texto como branca
                    ),
                  ),
                  SizedBox(height: 20),
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
                      Navigator.pushReplacementNamed(context, "/atividades");
                    },
                    child: Image.asset(
                        'lib/imagens/atividades.png'), // Substitua pelo caminho da segunda imagem
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("O login falhou, favor realize o login novamente!"),
                  IconButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      icon: Icon(Icons.logout)),
                ],
              ),
      ),
    );
  }
}
