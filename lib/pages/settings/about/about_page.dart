import 'package:f2fa/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<PackageInfo> _packageInfoFuture;
  static const _url = 'https://github.com/jenken827/f2fa';

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(al.apAppbarTitle)),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final packageInfo = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      height: 160,
                      width: 160,
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/icons/f2fa-216x216.png'),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '${al.apVersionLabel} ${packageInfo.version} (${packageInfo.buildNumber})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    al.apDescTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(al.apDescContent),
                  const SizedBox(height: 20),
                  Text(
                    al.apFeatureTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(al.apFeature1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(al.apFeature2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(al.apFeature3),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    al.apOpenSourceTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(al.apOpenSourceContent),
                  const SizedBox(height: 5),
                  Text(al.apOpenSourceTips),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(_url);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: const SelectableText(
                      _url,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load app info'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
