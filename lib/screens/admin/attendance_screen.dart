import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/group_model.dart';
import '../../models/student_profile.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  final String? forcedGroupId;

  const AttendanceScreen({
    super.key,
    this.forcedGroupId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  FormationGroup? _group;
  DateTime _date = DateTime.now();
  Map<String, String> _status = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth = context.read<AuthService>();

    final uid = auth.user?.uid;
    final role = auth.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Présences'),
      ),
      body: uid == null
          ? const Center(
              child: Text('Session introuvable.'),
            )
          : StreamBuilder<List<FormationGroup>>(
              stream: service.watchGroupes(),
              builder: (context, groupsSnap) {
                if (groupsSnap.hasError) {
                  return Center(
                    child: Text('Erreur : ${groupsSnap.error}'),
                  );
                }

                if (groupsSnap.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var groups = groupsSnap.data ?? [];

                // Un formateur ne voit que ses propres groupes.
                if (role == UserRole.formateur) {
                  groups = groups
                      .where((g) => g.formateurUid == uid)
                      .toList();
                }

                // Si un groupe est imposé, on limite la liste à celui-ci.
                if (widget.forcedGroupId != null) {
                  groups = groups
                      .where((g) => g.id == widget.forcedGroupId)
                      .toList();
                }

                if (groups.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun groupe disponible pour prendre les présences.',
                    ),
                  );
                }

                _group ??= groups.first;

                if (!groups.any((g) => g.id == _group!.id)) {
                  _group = groups.first;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<FormationGroup>(
                              initialValue: _group,
                              decoration: const InputDecoration(
                                labelText: 'Groupe',
                              ),
                              items: groups
                                  .map(
                                    (g) => DropdownMenuItem<FormationGroup>(
                                      value: g,
                                      child: Text(g.nom),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (g) {
                                setState(() {
                                  _group = g;
                                  _status = {};
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            tooltip: 'Changer la date',
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2035),
                                initialDate: _date,
                              );

                              if (picked != null) {
                                setState(() {
                                  _date = picked;
                                  _status = {};
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatDate(_date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<StudentProfile>>(
                        stream: service.watchEtudiantsDuGroupe(
                          _group!.id,
                        ),
                        builder: (context, studentsSnap) {
                          if (studentsSnap.hasError) {
                            return Center(
                              child: Text(
                                'Erreur : ${studentsSnap.error}',
                              ),
                            );
                          }

                          if (studentsSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final students = studentsSnap.data ?? [];

                          if (students.isEmpty) {
                            return const Center(
                              child: Text(
                                'Aucun étudiant dans ce groupe.',
                              ),
                            );
                          }

                          return FutureBuilder<Map<String, String>>(
                            future: service.getPresences(
                              _group!.id,
                              _date,
                            ),
                            builder: (context, savedSnap) {
                              if (savedSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final saved = savedSnap.data ?? {};

                              if (_status.isEmpty && saved.isNotEmpty) {
                                _status = Map<String, String>.from(saved);
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  90,
                                ),
                                itemCount: students.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final student = students[i];

                                  final current =
                                      _status[student.uid] ?? 'present';

                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          _initials(
                                            student.nomComplet,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        student.nomComplet.isEmpty
                                            ? 'Étudiant'
                                            : student.nomComplet,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        current == 'present'
                                            ? 'Présent'
                                            : current == 'retard'
                                                ? 'Retard'
                                                : 'Absent',
                                      ),
                                      trailing: SegmentedButton<String>(
                                        segments: const [
                                          ButtonSegment<String>(
                                            value: 'present',
                                            label: Text('P'),
                                            icon: Icon(
                                              Icons.check,
                                            ),
                                          ),
                                          ButtonSegment<String>(
                                            value: 'retard',
                                            label: Text('R'),
                                            icon: Icon(
                                              Icons.schedule,
                                            ),
                                          ),
                                          ButtonSegment<String>(
                                            value: 'absent',
                                            label: Text('A'),
                                            icon: Icon(
                                              Icons.close,
                                            ),
                                          ),
                                        ],
                                        selected: {current},
                                        onSelectionChanged: (values) {
                                          setState(() {
                                            _status[student.uid] =
                                                values.first;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving || _group == null
            ? null
            : () async {
                setState(() {
                  _saving = true;
                });

                try {
                  final students =
                      await service.getEtudiantsDuGroupeOnce(
                    _group!.id,
                  );

                  final values = {
                    for (final student in students)
                      student.uid:
                          (_status[student.uid] ?? 'present'),
                  };

                  await service.enregistrerPresences(
                    _group!,
                    _date,
                    values,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Présences enregistrées ✓',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Impossible d’enregistrer : $e',
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _saving = false;
                    });
                  }
                }
              },
        icon: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _saving ? 'Enregistrement...' : 'Enregistrer',
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((element) => element.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}