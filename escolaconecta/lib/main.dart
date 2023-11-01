import 'package:escolaconecta/rotas/rotas.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: PaletaCores.corFundo,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.grey,
  ).copyWith(secondary: Color.fromARGB(255, 204, 133, 231)),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyDh82ruXaXn7UI6aRDkeu_Ddw-jLwvu45g",
      appId: "1:241448274072:android:7dec31bb944c1f777628ed",
      messagingSenderId: "241448274072",
      projectId: "escolaconecta-745b5",
      storageBucket: "escolaconecta-745b5.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: Login(),
      theme: temaPadrao,
      initialRoute: "/",
      onGenerateRoute: Rotas.gerarRota,
    );
  }
}
