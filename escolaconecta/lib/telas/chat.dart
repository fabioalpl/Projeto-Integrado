import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Whats Escolar"),
          backgroundColor: Colors.purple[100],
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            SizedBox(
              width: 3.0,
            ),
            IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, "/login");
                },
                icon: Icon(Icons.logout)),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Conversas",
              ),
              Tab(
                text: "Contatos",
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              Center(
                child: Text("Conversas"),
              ),
              Center(
                child: Text("Contatos"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
