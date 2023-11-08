import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/atividade.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/telas/atividades.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _imagemUsuario = "";

  DateTime today = DateTime.now();
  Map<DateTime, List<Atividades>> events = {};
  _onDaySelected(DateTime day, DateTime fosusedDay) {
    setState(() {
      today = day;
    });
  }

  Future<List<Atividade>> _recuperarAtividades() async {
    String usuarioLogadoId = _auth.currentUser!.uid;
    final atividadeRef = _firestore.collection("atividades");
    QuerySnapshot querySnapshot = await atividadeRef.get();
    await atividadeRef.where('idResponsavel', isEqualTo: usuarioLogadoId).get();
    List<Atividade> listaAtividades = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      String idUsuario = item["idUsuario"];
      String idResponsavel = item["idResponsavel"];
      String data = item["data"];
      String hora = item["hora"];
      String descricao = item["descricao"];
      String latitude = item["latitude"];
      String longitude = item["longitude"];
      bool aceita = item["aceita"] == "Sim" ? true : false;

      String idFoto =
          usuarioLogadoId == idResponsavel ? idUsuario : idResponsavel;

      await _recuperarImagemUsuario(idFoto);

      Atividade atividade = Atividade(
          idUsuario: idUsuario,
          idResponsavel: idResponsavel,
          data: data,
          hora: hora,
          descricao: descricao,
          latitude: latitude,
          longitude: longitude,
          aceita: aceita);
      listaAtividades.add(atividade);
    }

    return listaAtividades;
  }

  Future<void> _recuperarImagemUsuario(String idUsuario) async {
    try {
      // Construa o caminho da imagem com base no ID do usuário
      String imagePath = 'imagens/perfil/$idUsuario.jpg';

      // Referência ao arquivo no Storage
      Reference ref = _storage.ref().child(imagePath);

      // Recupere a URL do arquivo
      String imageUrl = await ref.getDownloadURL();

      // Exiba a imagem
      _imagemUsuario = imageUrl;
    } catch (e) {
      print('Erro ao recuperar imagem: $e');
    }
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width * 0.40;
    final alturaCalendario = MediaQuery.of(context).size.height * 0.50;
    final alturaAtividade = MediaQuery.of(context).size.height * 0.20;

    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    bool criaAtividade = usuarioLogado!.perfil == "Professor";

    return Scaffold(
      appBar: barraSuperior(usuarioLogado),
      backgroundColor: PaletaCores.corFundo,
      body: Column(children: [
        Text("Calendário de Atividades"),
        SizedBox(height: 20),
        Container(
          height: alturaCalendario,
          child: TableCalendar(
            locale: "pt_BR",
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            focusedDay: today,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2024, 12, 31),
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (day) => isSameDay(day, today),
          ),
        ),
        SizedBox(height: 20),
        listaAtividades(alturaAtividade),
      ]),
      floatingActionButton: Visibility(
        visible: criaAtividade,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/lista_responsaveis",
                arguments: null);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget listaAtividades(double alturaAtividade) {
    return SingleChildScrollView(
      child: Container(
        height: alturaAtividade,
        child: FutureBuilder<List<Atividade>>(
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
                    return Center(
                        child: Text("Erro ao carregar as atividades!"));
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
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration:
                                  BoxDecoration(color: Color(0xfffaf3f3)),
                              child: ListTile(
                                onTap: () {
                                  Navigator.pushNamed(context, "/atividade",
                                      arguments: atividade);
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: CachedNetworkImageProvider(
                                      _imagemUsuario),
                                ),
                                title: Text(
                                  "Tarefa para o dia: " + atividade.data,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Center(child: Text("Nenhuma atividade encontrada!"));
                  }
              }
            }),
      ),
    );
  }
}
