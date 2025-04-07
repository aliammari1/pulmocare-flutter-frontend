import 'package:flutter/material.dart';

class StyleConstants {
  // Couleurs principales
  static const primaryColor = Color(0xFF2196F3);
  static const secondaryColor = Color(0xFF64B5F6);
  static const accentColor = Color(0xFF1976D2);
  static const backgroundColor = Color(0xFFF5F5F5);

  // Couleurs pour les cartes et éléments
  static const cardColor = Colors.white;
  static const shadowColor = Color(0x1A000000);
  static const successColor = Color(0xFF4CAF50);
  static const errorColor = Color(0xFFF44336);
  static const warningColor = Color(0xFFFF9800);

  // Styles de texte
  static const titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static const subtitleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFF666666),
  );

  // Décorations
  static final cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: shadowColor,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static final buttonDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryColor, accentColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withAlpha((0.3 * 255).toInt()),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Icônes
  static const double iconSize = 24.0;
  static const ordonnanceIcon = Icons.medical_information;
  static const patientIcon = Icons.person;
  static const medecinIcon = Icons.medical_services;
  static const searchIcon = Icons.search;
  static const addIcon = Icons.add_circle;
  static const saveIcon = Icons.save;
  static const printIcon = Icons.print;
  static const emailIcon = Icons.email;
  static const deleteIcon = Icons.delete;

  // Ajout d'icônes spécifiques
  static const medecinIdIcon = Icons.medical_services;
  static const cliniqueIcon = Icons.local_hospital;
  static const specialiteIcon = Icons.psychology;
  static const laboratoryIcon = Icons.science;
  static const medicamentIcon = Icons.medication;
  static const dateIcon = Icons.calendar_today;

  // Styles spécifiques pour les champs
  static final textFieldDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((0.1 * 255).toInt()),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
