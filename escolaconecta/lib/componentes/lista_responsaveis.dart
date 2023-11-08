import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/atividade.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListaResponsaveis extends StatefulWidget {
  const ListaResponsaveis({super.key});

  @override
  State<ListaResponsaveis> createState() => _ListaResponsaveisState();
}

class _ListaResponsaveisState extends State<ListaResponsaveis> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _idUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    final usuarioRef = _firestore.collection("usuarios");
    QuerySnapshot querySnapshot =
        await usuarioRef.where('perfil', isEqualTo: "Responsável").get();
    List<Usuario> listaUsuarios = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      String idUsuario = item["idUsuario"];

      String email = item["email"];
      String nome = item["nome"];
      String perfil = item["perfil"];
      String urlImagem = item["urlImagem"];

      Usuario usuario =
          Usuario(idUsuario, nome, email, urlImagem: urlImagem, perfil: perfil);
      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  _recuperarDadosUsuarioLogado() async {
    User? usuarioAtual = await _auth.currentUser;
    if (usuarioAtual != null) {
      _idUsuarioLogado = usuarioAtual.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuarioLogado();
  }

  AppBar barraSuperior(Usuario usuarioLogado) {
    return AppBar(
      backgroundColor: PaletaCores.corFundo,
      actions: [
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
        SizedBox(
          width: 3.0,
        ),
        IconButton(
            onPressed: () async {
              //await _auth.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
            icon: Icon(Icons.logout)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width * 0.40;
    final alturaCalendario = MediaQuery.of(context).size.height * 0.80;
    final alturaAtividade = MediaQuery.of(context).size.height * 0.50;

    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    bool criaAtividade = usuarioLogado!.perfil == "Professor";

    return Scaffold(
      appBar: barraSuperior(usuarioLogado),
      backgroundColor: PaletaCores.corFundo,
      body: Container(
        height: alturaCalendario,
        child: Column(
          children: [
            Text(
              "Atribua um responsável a atividade",
              style: TextStyle(
                fontSize: 20.0, // Defina o tamanho da fonte desejado
                color: Colors.white, // Define a cor do texto como branca
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: alturaAtividade,
                child: FutureBuilder<List<Usuario>>(
                    future: _recuperarContatos(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                            child: Column(
                              children: [
                                Text("Carregando responsaveis"),
                                CircularProgressIndicator()
                              ],
                            ),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Erro ao carregar os dados!"));
                          } else {
                            List<Usuario>? listaUsuarios = snapshot.data;
                            if (listaUsuarios != null) {
                              return ListView.separated(
                                separatorBuilder: (context, indice) {
                                  return Divider(
                                    color: Colors.grey,
                                    thickness: 0.2,
                                  );
                                },
                                itemCount: listaUsuarios.length,
                                itemBuilder: (context, indice) {
                                  Usuario usuario = listaUsuarios[indice];
                                  Atividade atividade = Atividade(
                                      idResponsavel: usuario.idUsuario);
                                  return ListTile(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/atividade",
                                        arguments: atividade,
                                      );
                                    },
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              usuario.urlImagem),
                                    ),
                                    title: Text(
                                      usuario.nome,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    contentPadding: EdgeInsets.all(8),
                                  );
                                },
                              );
                            }

                            return Center(
                                child: Text("Nenhum responsavel encontrado!"));
                          }
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
