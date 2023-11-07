import 'package:escolaconecta/componentes/lista_contatos.dart';
import 'package:escolaconecta/componentes/lista_conversas.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Escolar"),
          backgroundColor: PaletaCores.corFundo,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            SizedBox(
              width: 3.0,
            ),
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    "/home",
                    arguments: usuarioLogado,
                  );
                },
                icon: Icon(Icons.home)),
            SizedBox(
              width: 3.0,
            ),
            IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, "/login");
                },
                icon: Icon(Icons.logout)),
          ],
          bottom: TabBar(
            indicatorColor: Colors.black,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Conversas",
              ),
              Tab(
                text: "Contatos",
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              /*Center(
                child: Text("Conversas"),
              ),*/
              /*Center(
                child: Text("Contatos"),
              ),*/
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListaConversas(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListaContatos(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
