import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/componentes/lista_mensagens.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Mensagens extends StatefulWidget {
  final Usuario usuarioDestinatario;

  const Mensagens(this.usuarioDestinatario, {Key? key}) : super(key: key);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  //late Usuario _usuarioRemetente;
  //Usuario _usuarioDestinatario = widget.usuarioDestinatario;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /*_recuperarDadosIniciais() async {
    _usuarioDestinatario = widget.usuarioDestinatario;

    User? usuarioLogado = _auth.currentUser;
    if (usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      _usuarioRemetente = (await _recuperarUsuarioLogado(idUsuario))!;
      /*String? nome = usuarioLogado.displayName ?? "";
      String? email = usuarioLogado.email ?? "";
      String? urlImagem = usuarioLogado.photoURL ?? "";

      _usuarioRemetente = Usuario(idUsuario, nome, email, urlImagem: urlImagem);*/
    }
  }*/

  /*Future<Usuario?> _recuperarUsuarioLogado(String idUsuario) async {
    final usuarioRef = _firestore.collection("usuarios");
    //QuerySnapshot querySnapshot = await usuarioRef.get();
    QuerySnapshot querySnapshot =
        await usuarioRef.where('idUsuario', isEqualTo: idUsuario).get();

    for (DocumentSnapshot item in querySnapshot.docs) {
      String email = item["email"];
      String nome = item["nome"];
      String perfil = item["perfil"];
      String urlImagem = item["urlImagem"];

      return Usuario(idUsuario, nome, email,
          urlImagem: urlImagem, perfil: perfil);
    }
  }*/

  @override
  void initState() {
    super.initState();
    //_recuperarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    Usuario? _usuarioRemetente =
        context.watch<ConversaProvider>().usuarioLogado;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(
                  widget.usuarioDestinatario.urlImagem),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              widget.usuarioDestinatario.nome,
              style: TextStyle(color: Colors.black, fontSize: 16),
            )
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: SafeArea(
        child: ListaMensagens(
          usuarioRemetente: _usuarioRemetente!,
          usuarioDestinatario: widget.usuarioDestinatario,
        ),
      ),
    );
  }
}
