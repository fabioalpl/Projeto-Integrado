import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/atividade.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/provider/conversa_provider.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Atividades extends StatefulWidget {
  final Atividade? atividade;
  String? idResponsavel;

  Atividades(this.atividade, this.idResponsavel, {Key? key}) : super(key: key);

  @override
  State<Atividades> createState() => _AtividadesState();
}

class _AtividadesState extends State<Atividades> {
  final TextEditingController _controllerData = TextEditingController();
  final TextEditingController _controllerHora = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  final TextEditingController _controllerEndereco = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  late String _latitude;
  late String _longitude;

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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  _selectPositionToLocation(BuildContext context) async {
    var position = await _determinePosition();

    _latitude = position.latitude.toString();
    _longitude = position.longitude.toString();

    //_controllerEndereco.text =
    List<Placemark> newPlace =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placeMark = newPlace[0];
    String? name = placeMark.name;
    String? subLocality = placeMark.subLocality;
    String? locality = placeMark.locality;
    String? administrativeArea = placeMark.administrativeArea;
    String? postalCode = placeMark.postalCode;
    String? country = placeMark.country;
    String? street = placeMark.street;
    String address =
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
    print(address);

    _controllerEndereco.text =
        "${street}, ${name}, ${subLocality}, ${administrativeArea}";
  }

  _selectLocationToPosition(BuildContext context) async {
    if (_controllerEndereco.text.isNotEmpty) {
      List<Location> locations =
          await locationFromAddress(_controllerEndereco.text);

      _latitude = locations.first.latitude.toString();
      _longitude = locations.first.longitude.toString();
    }
  }

  inicializaCampos() async {
    if (widget.atividade != null) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      List<String> partesHora = widget.atividade!.hora.split(':');
      int hora = int.parse(partesHora[0]);
      int minuto = int.parse(partesHora[1].substring(0, 2));

      TimeOfDay horaConvertida = TimeOfDay(hour: hora, minute: minuto);

      _selectedDate = format.parse(widget.atividade!.data);
      _selectedTime = horaConvertida;
      _controllerData.text = widget.atividade!.data;
      _controllerHora.text = widget.atividade!.hora;
      _controllerDescricao.text = widget.atividade!.descricao;

      _controllerEndereco.text = await _recuperaEndereco(
          widget.atividade!.latitude, widget.atividade!.longitude);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<String> _recuperaEndereco(String latitude, String longitude) async {
    List<Placemark> newPlace = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude));
    Placemark placeMark = newPlace[0];
    String? name = placeMark.name;
    String? subLocality = placeMark.subLocality;
    String? administrativeArea = placeMark.administrativeArea;
    String? street = placeMark.street;
    String address =
        "${street}, ${name}, ${subLocality}, ${administrativeArea}";

    return address;
  }

  _salvarAtividadeAtual(String idUsuario) {
    String dataAtividade = _controllerData.text;
    String horaAtividade = _controllerHora.text;
    String descricao = _controllerDescricao.text;
    bool aceita = false;

    Atividade atividade = Atividade(idUsuario, widget.idResponsavel!,
        dataAtividade, horaAtividade, descricao, _latitude, _longitude, aceita);

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

    AlertDialog(
      title: Text("Tarefa criada!"),
    );
  }

  @override
  void initState() {
    inicializaCampos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Usuario? usuarioLogado = context.watch<ConversaProvider>().usuarioLogado;
    bool isPerfilEducador = usuarioLogado!.perfil == "Educador";
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  usuarioLogado!.perfil + ": " + usuarioLogado!.nome,
                  style: TextStyle(
                    fontSize: 20.0, // Defina o tamanho da fonte desejado
                    color: Colors.white, // Define a cor do texto como branca
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
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
                    child: TextField(
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
                    child: TextField(
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
          SizedBox(height: 20.0),
          Container(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectPositionToLocation(context);
                    },
                    child: Icon(Icons.near_me),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _controllerEndereco,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Informe um endereço',
                      ),
                    ),
                  ),
                ],
              ),
              width: 348,
              height: 100,
              decoration: BoxDecoration(color: Color(0xfffaf3f3))),
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
          ),
        ],
      ),
    );
  }
}
