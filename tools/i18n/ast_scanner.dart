import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// ============================================================
/// CONFIG
/// ============================================================

const Set<String> ignoredDirectories = {
  '.dart_tool',
  'build',
  'generated',
};

/// String yang jelas bukan teks UI.
const Set<String> ignoredExact = {
  '',
  'true',
  'false',
  'null',
};

const List<String> ignoredPrefixes = [
  'http://',
  'https://',
  'package:',
  'dart:',
  'asset:',
  'assets/',
  'asset/',
  'file://',
  'content://',
  'data:',
  'ftp://',
];

const List<String> ignoredExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
  '.gif',
  '.svg',
  '.mp4',
  '.mkv',
  '.mov',
  '.avi',
  '.m3u8',
  '.ts',
  '.vtt',
  '.json',
  '.xml',
  '.yaml',
  '.yml',
  '.dart',
  '.ttf',
  '.otf',
];

/// Route Flutter / API yang diawali slash.
bool looksLikeRoute(String value) {
  final text = value.trim();

  if (text.startsWith('/')) {
    return true;
  }

  if (text.startsWith('://')) {
    return true;
  }

  return false;
}

/// ============================================================
/// PATH
/// ============================================================

String normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

bool isIgnoredPath(String path) {
  final normalized = normalizePath(path).toLowerCase();

  for (final directory in ignoredDirectories) {
    if (normalized.contains('/$directory/')) {
      return true;
    }
  }

  return false;
}

/// ============================================================
/// STRING FILTER
/// ============================================================

bool looksLikeTranslationKey(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return false;
  }

  // translation key normal:
  // home_title
  // login_button
  // account_settings
  //
  // Tapi single word seperti:
  // home
  // login
  // search
  //
  // tetap dianggap teks.
  return RegExp(
    r'^[a-z][a-z0-9_]{2,69}$',
  ).hasMatch(text) &&
      text.contains('_');
}

bool looksLikeTechnicalIdentifier(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return false;
  }

  // camelCase / PascalCase technical identifier.
  if (RegExp(
    r'^[A-Za-z_][A-Za-z0-9_]*$',
  ).hasMatch(text)) {
    if (text.contains(RegExp(r'[A-Z]')) &&
        !text.contains(' ')) {
      return true;
    }

    // CONSTANT_CASE
    if (RegExp(
      r'^[A-Z][A-Z0-9_]+$',
    ).hasMatch(text)) {
      return true;
    }
  }

  return false;
}

bool isHumanText(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return false;
  }

  if (ignoredExact.contains(text.toLowerCase())) {
    return false;
  }

  if (text.length > 500) {
    return false;
  }

  final lower = text.toLowerCase();

  for (final prefix in ignoredPrefixes) {
    if (lower.startsWith(prefix)) {
      return false;
    }
  }

  for (final extension in ignoredExtensions) {
    if (lower.endsWith(extension)) {
      return false;
    }
  }

  if (looksLikeRoute(text)) {
    return false;
  }

  // UUID / hash / token panjang.
  if (RegExp(
    r'^[a-f0-9]{24,}$',
    caseSensitive: false,
  ).hasMatch(text)) {
    return false;
  }

  // Hanya angka / simbol.
  if (RegExp(
    r'^[\d\s.,:+\-/%$€¥₹#@*_(){}\[\]<>|=]+$',
  ).hasMatch(text)) {
    return false;
  }

  // Translation key jangan dipindai lagi.
  if (looksLikeTranslationKey(text)) {
    return false;
  }

  // Jangan ambil nama class/function/variable.
  if (looksLikeTechnicalIdentifier(text)) {
    return false;
  }

  // Harus punya karakter alfabet manusia.
  final hasHumanLanguage = RegExp(
    r'[A-Za-zÀ-ÿ'
    r'\u3040-\u30ff'
    r'\u3400-\u4dbf'
    r'\u4e00-\u9fff'
    r'\uac00-\ud7af'
    r'\u0900-\u097f]',
  ).hasMatch(text);

  if (!hasHumanLanguage) {
    return false;
  }

  return true;
}

/// ============================================================
/// ALREADY .TR
/// ============================================================

bool isAlreadyTranslated(AstNode node) {
  AstNode? current = node.parent;

  while (current != null) {
    if (current is MethodInvocation) {
      if (current.methodName.name == 'tr') {
        return true;
      }

      // Kita sudah keluar dari expression pemanggil.
      if (current.argumentList.arguments.contains(node)) {
        return false;
      }
    }

    if (current is InstanceCreationExpression) {
      return false;
    }

    if (current is MethodDeclaration ||
        current is FunctionDeclaration ||
        current is ClassDeclaration) {
      break;
    }

    current = current.parent;
  }

  return false;
}

/// ============================================================
/// CONST RANGES
/// ============================================================

String encodeConstRanges(AstNode node) {
  final ranges = <String>[];

  AstNode? current = node.parent;

  while (current != null) {
    if (current is InstanceCreationExpression) {
      final keyword = current.keyword;

      if (keyword != null && keyword.lexeme == 'const') {
        ranges.add(
          '${keyword.offset}:${keyword.end}',
        );
      }
    }

    current = current.parent;
  }

  return ranges.join(';');
}

/// ============================================================
/// EMIT
/// ============================================================

void emitNode({
  required String path,
  required CompilationUnit unit,
  required String value,
  required int offset,
  required int end,
  required AstNode node,
}) {
  final text = value.trim();

  if (!isHumanText(text)) {
    return;
  }

  if (isAlreadyTranslated(node)) {
    return;
  }

  final line =
      unit.lineInfo.getLocation(offset).lineNumber;

  final endLine =
      unit.lineInfo.getLocation(end).lineNumber;

  final constRanges =
      encodeConstRanges(node);

  stdout.writeln(
    [
      path,
      offset,
      end,
      line,
      endLine,
      value
          .replaceAll('\t', ' ')
          .replaceAll('\r', r'\r')
          .replaceAll('\n', r'\n'),
      constRanges,
    ].join('\t'),
  );
}

/// ============================================================
/// VISITOR
/// ============================================================

class StringVisitor extends RecursiveAstVisitor<void> {
  final String path;
  final CompilationUnit unit;

  StringVisitor({
    required this.path,
    required this.unit,
  });

  @override
  void visitSimpleStringLiteral(
    SimpleStringLiteral node,
  ) {
    emitNode(
      path: path,
      unit: unit,
      value: node.value,
      offset: node.offset,
      end: node.end,
      node: node,
    );

    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitAdjacentStrings(
    AdjacentStrings node,
  ) {
    final value = node.strings
        .map(
          (item) => item.stringValue ?? '',
        )
        .join();

    emitNode(
      path: path,
      unit: unit,
      value: value,
      offset: node.offset,
      end: node.end,
      node: node,
    );

    super.visitAdjacentStrings(node);
  }
}

/// ============================================================
/// SCAN FILE
/// ============================================================

void scanFile(String path) {
  final file = File(path);

  if (!file.existsSync()) {
    stderr.writeln(
      'ERROR\t$path\tFile tidak ditemukan',
    );
    return;
  }

  final normalized = normalizePath(path);

  if (isIgnoredPath(normalized)) {
    return;
  }

  final source = file.readAsStringSync();

  final result = parseString(
    content: source,
    path: path,
    throwIfDiagnostics: false,
  );

  result.unit.accept(
    StringVisitor(
      path: path,
      unit: result.unit,
    ),
  );
}

/// ============================================================
/// MAIN
/// ============================================================

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'ERROR\tTidak ada file Dart',
    );

    exitCode = 1;
    return;
  }

  for (final path in args) {
    try {
      scanFile(path);
    } catch (error, stack) {
      stderr.writeln(
        'ERROR\t$path\t$error',
      );

      stderr.writeln(stack);
    }
  }
}