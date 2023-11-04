import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escolaconecta/modelos/usuario.dart';
import 'package:escolaconecta/uteis/paleta_cores.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  final TextEditingController _controllerPerfil = TextEditingController();
  bool _cadastroUsuario = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _arquivoImagemSelecionado;
  String? dropdownValue = 'Selecione';

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  void _verificarUsuarioLogado() async {
    final User? usuarioLogado = await _auth.currentUser;

    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  Future<void> _selecionarImagem() async {
    final FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (resultado != null) {
      setState(() {
        _arquivoImagemSelecionado = resultado.files.single.bytes;
      });
    }
  }

  Future<void> _uploadImagem(Usuario usuario) async {
    final Uint8List? arquivoSelecionado = _arquivoImagemSelecionado;
    if (arquivoSelecionado != null) {
      final imagemPerfilRef =
          _storage.ref("imagens/perfil/${usuario.idUsuario}.jpg");
      final uploadTask = imagemPerfilRef.putData(arquivoSelecionado);

      await uploadTask.whenComplete(() async {
        final urlImagem = await uploadTask.snapshot.ref.getDownloadURL();
        usuario.urlImagem = urlImagem;
        usuario.perfil = _controllerPerfil.text;

        final usuariosRef = _firestore.collection("usuarios");
        await usuariosRef.doc(usuario.idUsuario).set(usuario.toMap());
        Navigator.pushReplacementNamed(context, "/home");
      });
    }
  }

  Future<void> _validarCampos() async {
    final nome = _controllerNome.text;
    final email = _controllerEmail.text;
    final senha = _controllerSenha.text;

    if (email.isEmpty || !email.contains("@")) {
      print("Email inválido");
      return;
    }

    if (senha.isEmpty || senha.length <= 3) {
      print("Senha inválida");
      return;
    }

    if (_cadastroUsuario) {
      if (nome.isEmpty || nome.length < 3) {
        print("Nome inválido, digite ao menos 3 caracteres");
        return;
      }

      try {
        final auth = await _auth.createUserWithEmailAndPassword(
            email: email, password: senha);
        final idUsuario = auth.user?.uid;
        if (idUsuario != null) {
          final usuario = Usuario(idUsuario, nome, email);
          await _uploadImagem(usuario);
          print("Usuário cadastrado: $idUsuario");
        }
      } catch (e) {
        print("Erro ao criar usuário: $e");
      }
    } else {
      try {
        final auth = await _auth.signInWithEmailAndPassword(
            email: email, password: senha);
        Navigator.pushReplacementNamed(context, "/home");
      } catch (e) {
        print("Erro ao fazer login: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alturaTela = MediaQuery.of(context).size.height;
    final larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        width: larguraTela,
        height: alturaTela,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _cadastroUsuario
                    ? _buildImageWidget()
                    : _buildCircularImageWidget(),
                const SizedBox(height: 8),
                Visibility(
                  visible: _cadastroUsuario,
                  child: OutlinedButton(
                    onPressed: _selecionarImagem,
                    child: const Text("Selecionar foto"),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(40),
                  width: 500,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Visibility(
                        visible: _cadastroUsuario,
                        child: _buildTextField("Nome", _controllerNome),
                      ),
                      SizedBox(height: 10),
                      _buildTextField("Email", _controllerEmail),
                      SizedBox(height: 10),
                      _buildTextField("Senha", _controllerSenha,
                          isPassword: true),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: _cadastroUsuario,
                        child:
                            _buildComboBox(dropdownValue!, _controllerPerfil),
                      ),
                      SizedBox(height: 20),
                      _buildSubmitButton(),
                      Row(
                        children: [
                          const Text("Login"),
                          Switch(
                            value: _cadastroUsuario,
                            onChanged: (bool valor) {
                              setState(() {
                                _cadastroUsuario = valor;
                              });
                            },
                          ),
                          const Text("Cadastro"),
                        ],
                      ),
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

  Widget _buildImageWidget() {
    return ClipOval(
      child: _arquivoImagemSelecionado != null
          ? Image.memory(
              _arquivoImagemSelecionado!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            )
          : Image.asset(
              "lib/imagens/perfil.png",
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildCircularImageWidget() {
    return Image.asset(
      'lib/imagens/login.png',
      width: 100,
      height: 100,
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      color: Colors.white,
      child: TextField(
        keyboardType: TextInputType.text,
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon:
              Icon(isPassword ? Icons.lock_outline : Icons.mail_outline),
        ),
      ),
    );
  }

  Widget _buildComboBox(
    String dropdownValue,
    TextEditingController controller,
  ) {
    List<String> list = ['Educador', 'Responsável'];
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: DropdownMenu<String>(
        controller: controller,
        enableFilter: true,
        selectedTrailingIcon: const Icon(Icons.search),
        label: const Text('Você é?'),
        dropdownMenuEntries:
            list.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onSelected: (String? value) {
          setState(() {
            dropdownValue = value!;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validarCampos,
        style: ElevatedButton.styleFrom(
          backgroundColor: PaletaCores.corFundo,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(_cadastroUsuario ? "Cadastro" : "Login",
              style: const TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}
