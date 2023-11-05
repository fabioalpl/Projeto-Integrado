import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: Center(
        child: usuarioLogado != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Seja Bem vindo: " +
                      usuarioLogado.nome +
                      " " +
                      usuarioLogado.perfil),
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
                  Text("Por favor realize o login novamente!"),
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
