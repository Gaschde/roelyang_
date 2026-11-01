import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'theme.dart';

class _Topic {
  const _Topic(this.icon, this.title, this.summary, this.body);

  final IconData icon;
  final String title;
  final String summary;
  final String body;
}

const _placeholderNote =
    'Prototype placeholder. Replace this with reviewed content and real '
    'citations before any release.';

const _topics = [
  _Topic(
    Icons.history_edu,
    'History & origins',
    'Where the instrument comes from.',
    'The dranyen (sgra-snyan) is a traditional Tibetan lute with a history of '
        'many centuries.',
  ),
  _Topic(
    Icons.music_note,
    'The instrument',
    'Six strings in three courses.',
    'The lute is fretless and has six strings arranged in three double '
        'courses, tuned La, Re and So. In this tuning La is B2, Re is E3 and '
        'So is A2 at A = 440 Hz.',
  ),
  _Topic(
    Icons.format_list_numbered,
    'Notation',
    'Solfege and the numbers 1–7.',
    'Do Re Mi Fa So La Thi are written as the numbers 1 to 7. In D major they '
        'are the notes D E F♯ G A B C♯.',
  ),
  _Topic(
    Icons.library_music,
    'Music & genres',
    'Styles to add later.',
    'This section is still empty in the prototype.',
  ),
  _Topic(
    Icons.menu_book,
    'Sources',
    'No reviewed sources yet.',
    'This prototype does not cite any scholarship yet.',
  ),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              'A short offline guide. $_placeholderNote',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ),
          for (final topic in _topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Icon(topic.icon, color: AppColors.gold),
                  title: Text(topic.title),
                  subtitle: Text(
                    topic.summary,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.muted,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _TopicScreen(topic),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicScreen extends StatelessWidget {
  const _TopicScreen(this.topic);

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(topic.body, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 22),
          const Text(
            _placeholderNote,
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const _Section(
            'What this is',
            'Roelyang Prototyp is an experimental tuner and practice tool for '
                'the Tibetan lute. It is an independent prototype and is not '
                'affiliated with any other app or organisation.',
          ),
          const _Section(
            'Tuning',
            'Tap Start and allow the microphone, then pluck an open string. '
                'The tuner finds the note by itself. Choose La, Re or So to '
                'lock onto one course. Turn the peg until the needle is centred '
                'and the note turns green.',
          ),
          const _Section(
            'Sounds',
            'The Play screen uses synthesised placeholder sounds, not '
                'recordings of a real instrument.',
          ),
          const _Section(
            'Privacy',
            'The microphone is only used to measure pitch on your device. '
                'Audio is not saved or sent anywhere, and the app has no '
                'accounts, ads or tracking.',
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return Text(
                info == null
                    ? ''
                    : 'Version ${info.version} (${info.buildNumber})',
                style: const TextStyle(color: AppColors.muted),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
