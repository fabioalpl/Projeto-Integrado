import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  bool _cadastroUsuario = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  _validarCampos() async {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        if (_cadastroUsuario) {
          //Cadastro
          if (nome.isNotEmpty && nome.length >= 3) {
            await _auth
                .createUserWithEmailAndPassword(email: email, password: senha)
                .then((auth) {
              //Upload
              String? idUsuario = auth.user?.uid;
              if (idUsuario != null) {
                Usuario usuario = Usuario(idUsuario, nome, email);
              }
              //print("Usuario cadastrado: $idUsuario");
            });
          } else {
            print("Nome inválido, digite ao menos 3 caracteres");
          }
        } else {
          //Login
          await _auth
              .signInWithEmailAndPassword(email: email, password: senha)
              .then((auth) {
            //tela principal
            Navigator.pushReplacementNamed(context, "/home");
          });
        }
      } else {
        print("Senha inválida");
      }
    } else {
      print("Email inválido");
    }
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo, // Cor de fundo para toda a tela
        width: larguraTela,
        height: alturaTela,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Adicione a imagem centralizada
                Image.asset(
                  'lib/imagens/login.png', // Substitua com o caminho da imagem
                  width: 100, // Defina o tamanho da imagem
                  height: 100,
                ),
                Container(
                  padding: EdgeInsets.all(40),
                  width: 500,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      //Caixa de texto nome
                      Visibility(
                        visible: _cadastroUsuario,
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            keyboardType: TextInputType.text,
                            controller: _controllerNome,
                            decoration: InputDecoration(
                                hintText: "Nome",
                                labelText: "Nome",
                                suffixIcon: Icon(Icons.person_outline)),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _controllerEmail,
                          decoration: InputDecoration(
                            hintText: "Email",
                            labelText: "Email",
                            suffixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: Colors.white,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _controllerSenha,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: "Senha",
                              labelText: "Senha",
                              suffixIcon: Icon(Icons.lock_outline)),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                PaletaCores.corFundo, // Cor de fundo do botão
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(_cadastroUsuario ? "Cadastro" : "Login",
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text("Login"),
                          Switch(
                            value: _cadastroUsuario,
                            onChanged: (bool valor) {
                              setState(() {
                                _cadastroUsuario = valor;
                              });
                            },
                          ),
                          Text("Cadastro"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
