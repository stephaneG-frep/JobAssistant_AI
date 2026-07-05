import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../services/file_import_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _summary;
  late final TextEditingController _skills;
  late final TextEditingController _experiences;
  late final TextEditingController _preferences;
  late final TextEditingController _constraints;
  late final TextEditingController _cv;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: profile.fullName);
    _summary = TextEditingController(text: profile.professionalSummary);
    _skills = TextEditingController(text: profile.skills);
    _experiences = TextEditingController(text: profile.experiences);
    _preferences = TextEditingController(text: profile.preferences);
    _constraints = TextEditingController(text: profile.constraints);
    _cv = TextEditingController(text: profile.defaultCv);
  }

  @override
  void dispose() {
    _name.dispose();
    _summary.dispose();
    _skills.dispose();
    _experiences.dispose();
    _preferences.dispose();
    _constraints.dispose();
    _cv.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<ProfileProvider>().save(
          UserProfile(
            fullName: _name.text,
            professionalSummary: _summary.text,
            skills: _skills.text,
            experiences: _experiences.text,
            preferences: _preferences.text,
            constraints: _constraints.text,
            defaultCv: _cv.text,
          ),
        );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil local enregistré.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil local')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom')),
          const SizedBox(height: 12),
          TextField(controller: _summary, minLines: 3, maxLines: null, decoration: const InputDecoration(labelText: 'Résumé professionnel')),
          const SizedBox(height: 12),
          TextField(controller: _skills, minLines: 3, maxLines: null, decoration: const InputDecoration(labelText: 'Compétences')),
          const SizedBox(height: 12),
          TextField(controller: _experiences, minLines: 4, maxLines: null, decoration: const InputDecoration(labelText: 'Expériences réelles')),
          const SizedBox(height: 12),
          TextField(controller: _preferences, minLines: 2, maxLines: null, decoration: const InputDecoration(labelText: 'Préférences de poste')),
          const SizedBox(height: 12),
          TextField(controller: _constraints, minLines: 2, maxLines: null, decoration: const InputDecoration(labelText: 'Contraintes')),
          const SizedBox(height: 12),
          TextField(controller: _cv, minLines: 6, maxLines: null, decoration: const InputDecoration(labelText: 'CV par défaut')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () async {
                final text = await FileImportService().pickTextFile();
                if (text != null) setState(() => _cv.text = text);
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer CV PDF/DOCX/TXT'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Enregistrer le profil')),
        ],
      ),
    );
  }
}
