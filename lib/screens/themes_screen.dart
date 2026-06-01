import 'package:flutter/material.dart';

import '../data/themes.dart';
import '../services/store.dart';

const _purple = Color(0xFF7B1FA2);

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  @override
  Widget build(BuildContext context) {
    final sel = Store.themeIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text('Teme (${kThemes.length})'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: kThemes.length,
          itemBuilder: (ctx, i) {
            final t = kThemes[i];
            final selected = i == sel;
            return GestureDetector(
              onTap: () async {
                await Store.setThemeIndex(i);
                if (!mounted) return;
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? _purple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: selected ? _purple : Colors.black12, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.preview, style: const TextStyle(fontSize: 38)),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        t.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.check_circle,
                            color: Colors.white, size: 18),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
