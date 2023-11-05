import 'package:escolaconecta/telas/atividades.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime today = DateTime.now();
  Map<DateTime, List<Atividades>> events = {};
  _onDaySelected(DateTime day, DateTime fosusedDay) {
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaCores.corFundo,
      body: content(),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.pushReplacementNamed(context, "/atividade");
      }),
    );
  }

  Widget content() {
    return Column(children: [
      Text("Calendário de Atividades"),
      SizedBox(height: 20),
      Container(
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
      )
    ]);
  }
}
