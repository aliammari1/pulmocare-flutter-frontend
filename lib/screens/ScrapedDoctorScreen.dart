import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medapp/config.dart';

//class ScrapedDoctorScreen extends StatefulWidget {

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String profileUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.profileUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      name: json['name'],
      specialty: json['specialty'],
      location: json['location'],
      profileUrl: json['profile_url'],
    );
  }
}

class ScrapedDoctorScreen extends StatefulWidget {
  const ScrapedDoctorScreen({super.key});

  @override
  _ScrapedDoctorScreenState createState() => _ScrapedDoctorScreenState();
}

class _ScrapedDoctorScreenState extends State<ScrapedDoctorScreen> {
  late Future<List<Doctor>> futureDoctors;
  final _apiUrl = Config.apiBaseUrl;
  Future<List<Doctor>> fetchDoctors() async {
    final response = await http.get(Uri.parse('$_apiUrl/scrape_doctors'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((doctor) => Doctor.fromJson(doctor)).toList();
    } else {
      throw Exception('Erreur lors du chargement des médecins');
    }
  }

  @override
  void initState() {
    super.initState();
    futureDoctors = fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Médecins'),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: futureDoctors,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Doctor> doctors = snapshot.data!;
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(doctors[index].name),
                  subtitle: Text(
                      '${doctors[index].specialty} - ${doctors[index].location}'),
                  onTap: () {
                    // Naviguer vers la page de détail du médecin
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
