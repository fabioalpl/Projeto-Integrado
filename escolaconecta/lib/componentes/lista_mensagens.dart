import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/conversa.dart';
import 'package:escolaconecta/modelos/mensagem.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:flutter/material.dart';

class ListaMensagens extends StatefulWidget {
  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  const ListaMensagens({
    Key? key,
    required this.usuarioRemetente,
    required this.usuarioDestinatario,
  }) : super(key: key);

  @override
  _ListaMensagensState createState() => _ListaMensagensState();
}

class _ListaMensagensState extends State<ListaMensagens> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _controllerMensagem = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;

  StreamController _streamController =
      StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMensagens;

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      String idUsuarioRemetente = _usuarioRemetente.idUsuario;
      Mensagem mensagem = Mensagem(
          idUsuarioRemetente, textoMensagem, Timestamp.now().toString());

      //Salvar mensagem para remetente
      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;
      _salvarMensagem(idUsuarioRemetente, idUsuarioDestinatario, mensagem);
      Conversa conversaRemetente = Conversa(
        idUsuarioRemetente,
        idUsuarioDestinatario,
        mensagem.texto,
        _usuarioDestinatario.nome,
        _usuarioDestinatario.email,
        _usuarioDestinatario.urlImagem,
      );
      _salvarConversa(conversaRemetente);

      //Salvar mensagem para o destinatário
      _salvarMensagem(idUsuarioDestinatario, idUsuarioRemetente, mensagem);
      Conversa conversaDestinatario = Conversa(
        idUsuarioDestinatario,
        idUsuarioRemetente,
        mensagem.texto,
        _usuarioRemetente.nome,
        _usuarioRemetente.email,
        _usuarioRemetente.urlImagem,
      );
      _salvarConversa(conversaDestinatario);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem mensagem) {
    _firestore
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());

    _controllerMensagem.clear();
  }

  _salvarConversa(Conversa conversa) {
    _firestore
        .collection("conversas")
        .doc(conversa.idRemetente)
        .collection("ultimas_mensagens")
        .doc(conversa.idDestinatario)
        .set(conversa.toMap());
  }

  _recuperarDadosInicias() {
    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;

    _adicionarListenersMensagens();
  }

  _adicionarListenersMensagens() {
    final stream = _firestore
        .collection("mensagens")
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy("data", descending: false)
        .snapshots();

    _streamMensagens = stream.listen((dados) {
      _streamController.add(dados);
      Timer(
          Duration(
            seconds: 1,
          ), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _streamMensagens.cancel();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosInicias();
  }

  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;

    return Container(
      width: largura,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("lib/imagens/bg.png"),
        fit: BoxFit.cover,
      )),
      child: Column(
        children: [
          //Listagem de mensagens
          StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text("Carregando dados"),
                          CircularProgressIndicator()
                        ],
                      ),
                    ),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro ao carregar os dados!"));
                  } else {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    List<DocumentSnapshot> listaMensagens =
                        querySnapshot.docs.toList();

                    return Expanded(
                        child: ListView.builder(
                      controller: _scrollController,
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (
                        context,
                        indice,
                      ) {
                        DocumentSnapshot mensagem = listaMensagens[indice];

                        Alignment alinhamento = Alignment.bottomLeft;
                        Color cor = Colors.white;

                        if (_usuarioRemetente.idUsuario ==
                            mensagem["idUsuario"]) {
                          alinhamento = Alignment.bottomRight;
                          cor = Color(0xffd2ffa5);
                        }

                        Size largura = MediaQuery.of(context).size * 0.8;

                        return Align(
                          alignment: alinhamento,
                          child: Container(
                            constraints: BoxConstraints.loose(largura),
                            decoration: BoxDecoration(
                              color: cor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.all(6),
                            child: Text(mensagem["texto"]),
                          ),
                        );
                      },
                    ));
                  }
              }
            },
          ),

          //Caixa de texto
          Container(
            padding: EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                //Caixa de texto arredondada
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40)),
                  child: Row(
                    children: [
                      Icon(Icons.insert_emoticon),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                          child: TextField(
                        controller: _controllerMensagem,
                        decoration: InputDecoration(
                            hintText: "Digite uma mensagem",
                            border: InputBorder.none),
                      )),
                      Icon(Icons.attach_file),
                      Icon(Icons.camera_alt),
                    ],
                  ),
                )),

                //Botao Enviar
                FloatingActionButton(
                    backgroundColor: PaletaCores.corFundo,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    mini: true,
                    onPressed: () {
                      _enviarMensagem();
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}
