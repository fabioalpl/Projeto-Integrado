import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/atividade.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Atividades extends StatefulWidget {
  final Atividade? atividade;

  Atividades({this.atividade});

  @override
  State<Atividades> createState() => _AtividadesState();
}

class _AtividadesState extends State<Atividades> {
  final TextEditingController _controllerData = TextEditingController();
  final TextEditingController _controllerHora = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controllerData.text = _dateFormat.format(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _controllerHora.text = _selectedTime.format(context);
      });
    }
  }

  _salvarAtividadeAtual(String idUsuario) {
    String dataAtividade = _controllerData.text;
    String horaAtividade = _controllerHora.text;
    String descricao = _controllerDescricao.text;
    bool aceita = true;

    Atividade atividade =
        Atividade(idUsuario, dataAtividade, horaAtividade, descricao, aceita);

    _salvarAtividade(atividade);
  }

  _salvarAtividade(Atividade atividade) {
    if (widget.atividade != null) {
      _firestore
          .collection("atividades")
          .doc(atividade.idUsuario)
          .update(atividade.toMap());
    } else {
      _firestore
          .collection("atividades")
          .doc(atividade.idUsuario)
          .set(atividade.toMap());
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.atividade != null) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      List<String> partesHora = widget.atividade!.hora.split(':');
      int hora = int.parse(partesHora[0]);
      int minuto = int.parse(partesHora[1]);

      TimeOfDay horaConvertida = TimeOfDay(hour: hora, minute: minuto);

      _selectedDate = format.parse(widget.atividade!.data);
      _selectedTime = horaConvertida;
      _controllerDescricao.text = widget.atividade!.descricao;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    bool isPerfilEducador = usuarioLogado!.perfil == "Educador";
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 348,
              height: 329,
              decoration: BoxDecoration(color: Color(0xfffaf3f3)),
              child: Column(
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        _selectTime(context);
                      },
                      child: Icon(Icons.access_time),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        controller: _controllerHora,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Selecione uma hora',
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: TextFormField(
                        controller: _controllerData,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Selecione uma data',
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 10.0),
                  Container(
                      child: TextField(
                        maxLines: 7, // Este é o número de linhas visíveis
                        controller: _controllerDescricao,
                        decoration: InputDecoration(
                          labelText: 'Descrição:',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                      width: 304,
                      height: 202,
                      decoration: BoxDecoration(color: Colors.white)),
                  SizedBox(height: 10.0),
                  Row(
                    children: [],
                  )
                ],
              ),
            ),
            SizedBox(height: 50.0),
            Visibility(
              visible: isPerfilEducador,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _salvarAtividadeAtual(usuarioLogado!.idUsuario);
                    },
                    child: Text('Confirmar'),
                  ),
                  SizedBox(width: 16.0), // Adiciona um espaço entre os botões
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/atividades");
                    },
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
