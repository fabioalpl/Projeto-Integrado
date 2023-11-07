import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/atividade.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ListaAtividades extends StatefulWidget {
  const ListaAtividades({super.key});

  @override
  State<ListaAtividades> createState() => _ListaAtividadesState();
}

class _ListaAtividadesState extends State<ListaAtividades> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late String _idUsuarioLogado;

  Future<List<Atividade>> _recuperarAtividades() async {
    final atividadeRef = _firestore.collection("atividades");
    QuerySnapshot querySnapshot = await atividadeRef.get();
    List<Atividade> listaAtividades = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      String idUsuario = item["idUsuario"];
      if (idUsuario == _idUsuarioLogado) {
        String idResponsavel = item["idResponsavel"];
        String data = item["data"];
        String hora = item["hora"];
        String descricao = item["descricao"];
        String latitude = item["latitude"];
        String longitude = item["longitude"];
        bool aceita = item["aceita"] == "Sim" ? true : false;

        Atividade atividade = Atividade(idUsuario, idResponsavel, data, hora,
            descricao, latitude, longitude, aceita);
        listaAtividades.add(atividade);
      }
    }

    return listaAtividades;
  }

  Future<String> _recuperarImagemUsuario(String idUsuario) async {
    try {
      // Construa o caminho da imagem com base no ID do usuário
      String imagePath = 'imagens/perfil/$idUsuario.jpg';

      // Referência ao arquivo no Storage
      Reference ref = _storage.ref().child(imagePath);

      // Recupere a URL do arquivo
      String imageUrl = await ref.getDownloadURL();

      // Exiba a imagem
      return imageUrl;
    } catch (e) {
      print('Erro ao recuperar imagem: $e');
      return 'Erro ao carregar a imagem';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Atividade>>(
        future: _recuperarAtividades(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando atividades"),
                    CircularProgressIndicator()
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text("Erro ao carregar as atividades!"));
              } else {
                List<Atividade>? listaAtividades = snapshot.data;
                if (listaAtividades != null) {
                  return ListView.separated(
                    separatorBuilder: (context, indice) {
                      return Divider(
                        color: Colors.grey,
                        thickness: 0.2,
                      );
                    },
                    itemCount: listaAtividades.length,
                    itemBuilder: (context, indice) {
                      Atividade atividade = listaAtividades[indice];
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/atividade",
                              arguments: atividade);
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(
                              _recuperarImagemUsuario(atividade.idUsuario)
                                  as String),
                        ),
                        title: Text(
                          atividade.hora,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        contentPadding: EdgeInsets.all(8),
                      );
                    },
                  );
                }

                return Center(child: Text("Nenhuma atividade encontrada!"));
              }
          }
        });
  }
}
