import 'dart:io';

void main() {
  final libDirectory = Directory('lib');

  if (!libDirectory.existsSync()) {
    print('❌ Folder lib tidak ditemukan.');
    print('Jalankan script dari root project Flutter.');
    exit(1);
  }

  final strings = <String>{};

  final files = libDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in files) {
    final content = file.readAsStringSync();

    // Cari string dengan single quote:
    // 'Trending'
    final singleQuoteRegex = RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'");

    for (final match in singleQuoteRegex.allMatches(content)) {
      final value = match.group(1);

      if (value == null || value.trim().isEmpty) {
        continue;
      }

      _addIfText(strings, value);
    }

    // Cari string dengan double quote:
    // "Trending"
    final doubleQuoteRegex = RegExp(r'"([^"\\]*(?:\\.[^"\\]*)*)"');

    for (final match in doubleQuoteRegex.allMatches(content)) {
      final value = match.group(1);

      if (value == null || value.trim().isEmpty) {
        continue;
      }

      _addIfText(strings, value);
    }
  }

  final sorted = strings.toList()..sort();

  print('');
  print('========================================');
  print(' FOUND ${sorted.length} TEXT STRINGS');
  print('========================================');
  print('');

  for (final text in sorted) {
    print(text);
  }

  print('');
  print('========================================');

  final output = File('translation_strings.txt');

  output.writeAsStringSync(
    sorted.join('\n'),
  );

  print('✅ Hasil disimpan ke: translation_strings.txt');
}

void _addIfText(
  Set<String> strings,
  String value,
) {
  final text = value.trim();

  // Abaikan URL
  if (text.startsWith('http://') ||
      text.startsWith('https://')) {
    return;
  }

  // Abaikan path/file
  if (text.contains('/') && text.contains('.')) {
    return;
  }

  // Abaikan package/import
  if (text.startsWith('package:')) {
    return;
  }

  // Abaikan angka saja
  if (RegExp(r'^[0-9.]+$').hasMatch(text)) {
    return;
  }

  // Harus mengandung minimal satu huruf
  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(text)) {
    return;
  }

  strings.add(text);
}

