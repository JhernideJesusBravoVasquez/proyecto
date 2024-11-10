import 'package:residencia/admin/avance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Importa Firebase Auth
import 'login_admin.dart';  // Importa la página de login
import 'profile_admin.dart';
import '../../generales/actividades.dart';
import 'gestionar_usuarios.dart';
import 'gestionar_activities.dart';
import 'solicitudes_constancias.dart';
import '../../generales/seleccionar_actividad.dart';

class HomeAdmin extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Instancia de Firebase Auth
  final String adminName;
  final String adminId;
  final String adminFirstLastname;
  final String adminSecondLastname;
  final String adminEmail;
  final String adminPhone;

  HomeAdmin ({
    required this.adminName, 
    required this.adminId, 
    required this.adminFirstLastname, 
    required this.adminSecondLastname,
    required this.adminEmail,
    required this.adminPhone});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),  // Muestra el nombre en el AppBar
        automaticallyImplyLeading: false,  // Elimina el botón de "Back"
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget> [
            Text(
              '¡Bienvenido!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),  // Espacio entre el texto y el botón

            //Botón para gestionar perfil
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (
                      context) => ProfileAdmin(
                        adminName: adminName,
                        adminId: adminId, 
                        adminFirstLastname: adminFirstLastname, 
                        adminSecondLastname: adminSecondLastname, 
                        adminEmail: adminEmail, 
                        adminPhone: adminPhone
                        )),
                );
              },
              child: Text('Perfil'),
            ),
            SizedBox(height: 10,),

            //boton para gestionar ver actividades
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Actividades()),
                );
              }, child: Text('Actividades')
            ),
            SizedBox(height: 10,),

            // Botón para agregar estudiante
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GestionarUsuarios()),
                );
              },
              child: Text('Gestionar usuarios'),
            ),
            SizedBox(height: 10,),

            //Botón para gestionar actividades
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> GestionarActivities(
                    adminId: adminId,
                  )), 
                );
              },child: Text('Gestionar actividades'),
            ),
            SizedBox(height: 10,),

            //Boton para registrar estudiantes en las actividades
            ElevatedButton(
              onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>SeleccionarActividad())
                );
              },child: Text('Registrar'),
            ),
            SizedBox(height: 10,),

            //Bonton para ver avance
            ElevatedButton(
              onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>Avance())
                );
              },child: Text('Avance'),
            ),
            SizedBox(height: 10,),

            //boton para ver solicitudes de constancias
            ElevatedButton(
              onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>VerSolicitudesConstancia())
                );
              },child: Text('Solicitudes'),
            ),
            SizedBox(height: 10,),

            // Botón de cerrar sesión
            ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context);  // Muestra la alerta de confirmación
              },
              child: Text('Cerrar Sesión'),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  // Método para mostrar una alerta de confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el cuadro de diálogo
              },
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                _signOut(context);  // Llama al método para cerrar sesión
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión y redirigir al login
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();  // Cierra la sesión en Firebase
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginAdmin()),  // Redirige al login
      (Route<dynamic> route) => false,  // Elimina todas las rutas anteriores
    );
  }
}
