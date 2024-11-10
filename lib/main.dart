import 'package:flutter/material.dart';
import '../admin/login_admin.dart';  // Importa la página de login para administrativos
import '../student/student_login.dart';  // Importa la página de login para estudiantes
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../profesor/login_profesor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        '/login': (context) => LoginAdmin(),
        '/student_login': (context) => StudentLoginPage(),
        '/login_teacher': (context)=> LoginProfesor(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://idiomas.uabjo.mx/media/23/images/xlogo.png.pagespeed.ic.7-6gNgCr4I.webp',
                height: size.height * 0.2,
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/student_login');  // Redirige al login de estudiantes
                  },
                  child: Text('Estudiante'),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context,'/login_teacher');
                  },
                  child: Text('Profesor'),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Administrativo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
