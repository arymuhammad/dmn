from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


# ============================================================
# PROJECT
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

LIB_DIR = ROOT / "lib"
I18N_DIR = ROOT / "tools" / "i18n"

SCANNER_FILE = I18N_DIR / "ast_scanner.dart"

STRINGS_FILE = I18N_DIR / "strings.json"
TRANSLATIONS_FILE = I18N_DIR / "translations.json"

TRANSLATION_DIR = LIB_DIR / "data" / "translations"

BACKUP_DIR = I18N_DIR / "backup"


# ============================================================
# LANGUAGES
# ============================================================

SOURCE_LOCALE = "en_US"

TARGET_LOCALES = [
    "en_US",
    "id_ID",
    "ja_JP",
    "ko_KR",
    "hi_IN",
    "ms_MY",
]

LANGUAGE_CODES = {
    "en_US": "en",
    "id_ID": "id",
    "ja_JP": "ja",
    "ko_KR": "ko",
    "hi_IN": "hi",
    "ms_MY": "ms",
}

LANGUAGE_NAMES = {
    "en_US": "English",
    "id_ID": "Indonesian",
    "ja_JP": "Japanese",
    "ko_KR": "Korean",
    "hi_IN": "Hindi",
    "ms_MY": "Malay",
}


# ============================================================
# IGNORE
# ============================================================

IGNORE_EXACT = {
    "",
    "true",
    "false",
    "null",
    "none",
    "undefined",
}


IGNORE_PREFIXES = (
    "http://",
    "https://",
    "ftp://",
    "package:",
    "dart:",
    "assets/",
    "asset/",
    "file://",
    "data:",
    "mailto:",
    "tel:",
)


IGNORE_EXTENSIONS = (
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".gif",
    ".svg",
    ".ico",
    ".mp3",
    ".wav",
    ".aac",
    ".mp4",
    ".mkv",
    ".mov",
    ".avi",
    ".m3u8",
    ".ts",
    ".vtt",
    ".srt",
    ".json",
    ".xml",
    ".yaml",
    ".yml",
    ".dart",
    ".db",
    ".sqlite",
)


# Route seperti:
# /login
# /home
# /detail/123
IGNORE_ROUTE_PREFIXES = (
    "/",
)


TECHNICAL_IDENTIFIER_PATTERN = re.compile(
    r"^[A-Za-z_][A-Za-z0-9_]*$"
)


CAMEL_CASE_PATTERN = re.compile(
    r"^[a-z][A-Za-z0-9_]*$"
)


TRANSLATION_KEY_PATTERN = re.compile(
    r"^[a-z][a-z0-9_]{1,69}$"
)


# ============================================================
# UI PARAMETER
# ============================================================

UI_PARAMETER_NAMES = {
    "text",
    "title",
    "subtitle",
    "label",
    "message",
    "header",
    "body",
    "caption",
    "hint",
    "hintText",
    "helperText",
    "errorText",
    "labelText",
    "prefixText",
    "suffixText",
    "titleText",
    "contentText",
    "confirmText",
    "cancelText",
    "buttonText",
    "actionText",
    "primaryText",
    "secondaryText",
    "tooltip",
    "tooltipMessage",
    "semanticLabel",
    "snackBarMessage",
    "successMessage",
    "errorMessage",
    "warningMessage",
    "infoMessage",
    "emptyMessage",
    "loadingMessage",
    "dialogTitle",
    "dialogMessage",
}


CONDITIONAL_UI_PARAMETERS = {
    "description",
    "content",
    "placeholder",
    "value",
}


UI_METHODS = {
    "showSnackBar",
    "showDialog",
    "showGeneralDialog",
    "showModalBottomSheet",
    "showBottomSheet",
    "showCupertinoDialog",
    "showCupertinoModalPopup",
    "showMenu",
    "showDatePicker",
    "showTimePicker",
    "showSearch",
    "snackbar",
    "dialog",
    "bottomSheet",
    "customDialog",
}


# ============================================================
# LOG
# ============================================================

def log(message: str) -> None:
    print(f"[i18n] {message}")


# ============================================================
# DIRECTORIES
# ============================================================

def ensure_directories() -> None:
    I18N_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    TRANSLATION_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    BACKUP_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )


# ============================================================
# COMMAND RUNNER
# ============================================================

def run_command(
    command: list[str],
    cwd: Path | None = None,
) -> str:

    try:
        result = subprocess.run(
            command,
            cwd=str(cwd or ROOT),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
        )

    except FileNotFoundError as exc:
        raise RuntimeError(
            "Command tidak ditemukan:\n"
            f"{command[0]}"
        ) from exc

    if result.returncode != 0:
        print(result.stdout)

        raise RuntimeError(
            "Command gagal:\n"
            + " ".join(command)
        )

    return result.stdout


# ============================================================
# DART DETECTION
# ============================================================

def find_dart() -> str | None:

    dart = shutil.which("dart")

    if dart:
        return dart

    flutter = shutil.which("flutter")

    if flutter:
        flutter_path = Path(flutter).resolve()

        candidates = [
            flutter_path.parent
            / "dart-sdk"
            / "bin"
            / (
                "dart.bat"
                if os.name == "nt"
                else "dart"
            ),

            flutter_path.parent
            / "cache"
            / "dart-sdk"
            / "bin"
            / (
                "dart.bat"
                if os.name == "nt"
                else "dart"
            ),
        ]

        for candidate in candidates:
            if candidate.exists():
                return str(candidate)

    if os.name == "nt":

        candidates = [
            Path(r"C:\flutter\bin\dart.bat"),

            Path(
                r"C:\flutter\bin\cache"
                r"\dart-sdk\bin\dart.exe"
            ),

            Path(r"C:\src\flutter\bin\dart.bat"),

            Path(
                r"C:\src\flutter\bin\cache"
                r"\dart-sdk\bin\dart.exe"
            ),
        ]

        for candidate in candidates:
            if candidate.exists():
                return str(candidate)

    return None


def check_dart() -> str:

    dart = find_dart()

    if dart is None:
        raise RuntimeError(
            "Dart/Flutter tidak ditemukan.\n\n"
            "Pastikan Flutter sudah masuk PATH.\n\n"
            "Contoh:\n"
            r"C:\flutter\bin\dart.bat"
        )

    log(f"Dart: {dart}")

    return dart


# ============================================================
# PROJECT VALIDATION
# ============================================================

def validate_project() -> None:

    pubspec = ROOT / "pubspec.yaml"

    if not pubspec.exists():
        raise RuntimeError(
            "pubspec.yaml tidak ditemukan.\n\n"
            f"Project root:\n{ROOT}"
        )

    if not LIB_DIR.exists():
        raise RuntimeError(
            "Folder lib tidak ditemukan.\n\n"
            f"{LIB_DIR}"
        )


# ============================================================
# ANALYZER
# ============================================================

def ensure_analyzer(
    dart: str,
) -> None:

    pubspec = ROOT / "pubspec.yaml"

    content = pubspec.read_text(
        encoding="utf-8"
    )

    if re.search(
        r"^\s*analyzer\s*:",
        content,
        re.MULTILINE,
    ):
        return

    log("Package analyzer belum ada.")
    log("Menambahkan analyzer...")

    run_command(
        [
            dart,
            "pub",
            "add",
            "--dev",
            "analyzer",
        ],
        cwd=ROOT,
    )


# ============================================================
# ARGOS
# ============================================================

def import_argos() -> tuple[Any, Any]:

    try:
        import argostranslate.package as argos_package
        import argostranslate.translate as argos_translate

        return (
            argos_package,
            argos_translate,
        )

    except ImportError:

        log(
            "Argos Translate belum terinstall."
        )

        log(
            "Installing argostranslate..."
        )

        run_command(
            [
                sys.executable,
                "-m",
                "pip",
                "install",
                "argostranslate",
            ]
        )

        import argostranslate.package as argos_package
        import argostranslate.translate as argos_translate

        return (
            argos_package,
            argos_translate,
        )


# ============================================================
# ARGOS MODELS
# ============================================================

def ensure_argos_models() -> None:

    (
        argos_package,
        argos_translate,
    ) = import_argos()

    source_code = LANGUAGE_CODES[
        SOURCE_LOCALE
    ]

    try:
        argos_translate.load_installed_languages()
    except Exception:
        pass

    for locale in TARGET_LOCALES:

        target_code = LANGUAGE_CODES[
            locale
        ]

        if source_code == target_code:
            continue

        try:
            translation = (
                argos_translate
                .get_translation_from_codes(
                    source_code,
                    target_code,
                )
            )
        except Exception:
            translation = None

        if translation is not None:

            log(
                f"Model OK: "
                f"{source_code} -> "
                f"{target_code}"
            )

            continue

        log(
            f"Installing model: "
            f"{source_code} -> "
            f"{target_code}"
        )

        installed = False

        try:
            result = (
                argos_package
                .install_package_for_language_pair(
                    source_code,
                    target_code,
                )
            )

            if result:
                installed = True

        except Exception:
            installed = False

        if not installed:

            try:

                argos_package.update_package_index()

                packages = (
                    argos_package
                    .get_available_packages()
                )

                package = next(
                    (
                        item
                        for item in packages
                        if (
                            item.from_code
                            == source_code
                            and
                            item.to_code
                            == target_code
                        )
                    ),
                    None,
                )

                if package is None:
                    raise RuntimeError(
                        "Model tidak ditemukan."
                    )

                download_path = package.download()

                argos_package.install_from_path(
                    download_path
                )

            except Exception as exc:

                raise RuntimeError(
                    "Model Argos tidak tersedia:\n\n"
                    f"{source_code} -> "
                    f"{target_code}\n\n"
                    f"{exc}"
                ) from exc

        try:
            argos_translate.load_installed_languages()
        except Exception:
            pass

        try:
            translation = (
                argos_translate
                .get_translation_from_codes(
                    source_code,
                    target_code,
                )
            )
        except Exception:
            translation = None

        if translation is None:

            raise RuntimeError(
                "Model Argos gagal diaktifkan:\n\n"
                f"{source_code} -> "
                f"{target_code}"
            )


# ============================================================
# STRING FILTER
# ============================================================

def looks_like_translation_key(
    text: str,
) -> bool:

    value = text.strip()

    if not value:
        return False

    if not TRANSLATION_KEY_PATTERN.fullmatch(
        value
    ):
        return False

    return "_" in value


def contains_human_language(
    value: str,
) -> bool:

    return bool(
        re.search(
            r"[A-Za-zÀ-ÿ"
            r"\u0100-\u024f"
            r"\u3040-\u30ff"
            r"\u3400-\u4dbf"
            r"\u4e00-\u9fff"
            r"\uac00-\ud7af"
            r"\u0900-\u097f]",
            value,
        )
    )


def is_probably_ui_text(
    text: str,
) -> bool:

    value = text.strip()

    if not value:
        return False

    if value in IGNORE_EXACT:
        return False

    if len(value) > 500:
        return False

    lower = value.lower()

    if any(
        lower.startswith(prefix)
        for prefix in IGNORE_PREFIXES
    ):
        return False

    if any(
        lower.endswith(extension)
        for extension in IGNORE_EXTENSIONS
    ):
        return False

    if any(
        value.startswith(prefix)
        for prefix in IGNORE_ROUTE_PREFIXES
    ):
        return False

    # Hanya angka/simbol.
    if re.fullmatch(
        r"[\d\s.,:+\-/%$€¥₹₩]+",
        value,
    ):
        return False

    # Translation key yang sudah ada.
    if looks_like_translation_key(value):
        return False

    # SQL / query teknis.
    lower_value = value.lower()

    technical_fragments = (
        "select ",
        "insert into ",
        "update ",
        "delete from ",
        "create table ",
        "alter table ",
        "drop table ",
        " where ",
        " from ",
    )

    if any(
        fragment in lower_value
        for fragment in technical_fragments
    ):
        return False

    # Human language wajib ada.
    if not contains_human_language(value):
        return False

    # String satu kata yang jelas merupakan identifier.
    if (
        " " not in value
        and "\n" not in value
        and "\t" not in value
        and TECHNICAL_IDENTIFIER_PATTERN.fullmatch(value)
    ):

        technical_suffixes = (
            "Controller",
            "View",
            "Widget",
            "Model",
            "Service",
            "Repository",
            "Provider",
            "Response",
            "Request",
            "Entity",
            "State",
            "Binding",
            "Page",
            "Screen",
        )

        if value.endswith(
            technical_suffixes
        ):
            return False

        # camelCase teknis
        if CAMEL_CASE_PATTERN.fullmatch(
            value
        ) and any(
            char.isupper()
            for char in value[1:]
        ):
            return False

    return True


# ============================================================
# KEY
# ============================================================

def normalize_key(
    text: str,
) -> str:

    value = text.strip().lower()

    # Hilangkan interpolation.
    value = re.sub(
        r"\$\{[^}]+\}",
        "",
        value,
    )

    value = re.sub(
        r"\$[A-Za-z_][A-Za-z0-9_]*",
        "",
        value,
    )

    value = re.sub(
        r"[^a-zA-Z0-9]+",
        "_",
        value,
    )

    value = re.sub(
        r"_+",
        "_",
        value,
    )

    value = value.strip("_")

    if not value:
        value = "text"

    if value[0].isdigit():
        value = "text_" + value

    return value[:60]


def make_unique_key(
    text: str,
    existing: dict[str, str],
) -> str:

    base = normalize_key(text)

    if (
        base not in existing
        or existing[base] == text
    ):
        return base

    digest = hashlib.sha1(
        text.encode("utf-8")
    ).hexdigest()[:8]

    return f"{base}_{digest}"[:69]


# ============================================================
# AST SCAN
# ============================================================

def ast_scan(
    dart: str,
) -> dict[str, dict]:

    ensure_analyzer(dart)

    if not SCANNER_FILE.exists():
        raise RuntimeError(
            "File scanner tidak ditemukan:\n"
            f"{SCANNER_FILE}"
        )

    dart_files: list[Path] = []

    # ========================================================
    # PENTING:
    # SCAN SELURUH LIB
    # ========================================================

    for path in LIB_DIR.rglob("*.dart"):

        normalized = str(
            path
        ).replace(
            "\\",
            "/",
        ).lower()

        # Jangan scan hasil translation.
        if (
            "/data/translations/"
            in normalized
        ):
            continue

        # Jangan scan generated file.
        if (
            ".g.dart"
            in path.name
            or ".freezed.dart"
            in path.name
        ):
            continue

        dart_files.append(path)

    if not dart_files:
        return {}

    log(
        f"Scanning {len(dart_files)} Dart files..."
    )

    output = run_command(
        [
            dart,
            "run",
            str(SCANNER_FILE),
            *[
                str(path)
                for path in dart_files
            ],
        ],
        cwd=ROOT,
    )

    results: dict[str, dict] = {}

    existing: dict[str, str] = {}

    for raw_line in output.splitlines():

        parts = raw_line.split(
            "\t",
            6,
        )

        if len(parts) != 7:
            continue

        (
            path,
            offset,
            end,
            line_number,
            end_line,
            text,
            const_ranges,
        ) = parts

        try:

            offset_i = int(offset)
            end_i = int(end)
            line_i = int(line_number)
            end_line_i = int(end_line)

        except ValueError:
            continue

        if not is_probably_ui_text(
            text
        ):
            continue

        source_text = text.strip()

        key = make_unique_key(
            source_text,
            existing,
        )

        existing.setdefault(
            key,
            source_text,
        )

        absolute_path = Path(path)

        try:

            relative_path = (
                absolute_path
                .resolve()
                .relative_to(
                    ROOT.resolve()
                )
            )

        except ValueError:

            relative_path = (
                absolute_path
            )

        relative_string = str(
            relative_path
        ).replace(
            "\\",
            "/",
        )

        occurrence = {
            "file": relative_string,
            "offset": offset_i,
            "end": end_i,
            "line": line_i,
            "endLine": end_line_i,
            "constRanges": const_ranges,
        }

        # ====================================================
        # STRING SAMA:
        # GUNAKAN KEY YANG SAMA.
        # ====================================================

        if key not in results:

            results[key] = {
                "key": key,
                "text": source_text,
                "occurrences": [
                    occurrence
                ],
            }

        else:

            results[key][
                "occurrences"
            ].append(
                occurrence
            )

    return results


# ============================================================
# SAVE SCAN
# ============================================================

def save_scan(
    results: dict[str, dict],
) -> None:

    total_occurrences = sum(
        len(item.get("occurrences", []))
        for item in results.values()
    )

    STRINGS_FILE.write_text(
        json.dumps(
            {
                "sourceLocale": SOURCE_LOCALE,
                "targets": TARGET_LOCALES,
                "strings": results,
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    log(
        f"Unique UI strings: "
        f"{len(results)}"
    )

    log(
        f"Total occurrences: "
        f"{total_occurrences}"
    )

    log(
        f"Saved: {STRINGS_FILE}"
    )


# ============================================================
# TRANSLATION CACHE
# ============================================================

def load_translation_cache() -> dict:

    if not TRANSLATIONS_FILE.exists():
        return {}

    try:

        return json.loads(
            TRANSLATIONS_FILE.read_text(
                encoding="utf-8"
            )
        )

    except Exception:

        return {}


def save_translation_cache(
    cache: dict,
) -> None:

    TRANSLATIONS_FILE.write_text(
        json.dumps(
            cache,
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )


# ============================================================
# ARGOS TRANSLATE
# ============================================================

def translate_text(
    text: str,
    source_code: str,
    target_code: str,
) -> str:

    if source_code == target_code:
        return text

    (
        _argos_package,
        argos_translate,
    ) = import_argos()

    try:

        translated = (
            argos_translate.translate(
                text,
                source_code,
                target_code,
            )
        )

    except Exception:

        translation = (
            argos_translate
            .get_translation_from_codes(
                source_code,
                target_code,
            )
        )

        if translation is None:

            raise RuntimeError(
                "Argos tidak punya model:\n"
                f"{source_code} -> "
                f"{target_code}"
            )

        translated = (
            translation.translate(text)
        )

    if not translated:
        return text

    return translated


# ============================================================
# TRANSLATE ALL
# ============================================================

def translate_all(
    results: dict[str, dict],
) -> dict[str, dict[str, str]]:

    ensure_argos_models()

    cache = load_translation_cache()

    source_code = LANGUAGE_CODES[
        SOURCE_LOCALE
    ]

    items = list(
        results.values()
    )

    log(
        f"Translating "
        f"{len(items)} unique strings..."
    )

    for locale in TARGET_LOCALES:

        target_code = LANGUAGE_CODES[
            locale
        ]

        log(
            f"Language: "
            f"{locale} "
            f"({LANGUAGE_NAMES[locale]})"
        )

        locale_cache = cache.setdefault(
            locale,
            {},
        )

        total = len(items)

        for index, item in enumerate(
            items,
            start=1,
        ):

            text = item["text"]

            cache_key = hashlib.sha256(
                text.encode("utf-8")
            ).hexdigest()

            if cache_key in locale_cache:
                continue

            if locale == SOURCE_LOCALE:

                translated = text

            else:

                translated = translate_text(
                    text,
                    source_code,
                    target_code,
                )

            locale_cache[
                cache_key
            ] = {
                "source": text,
                "translated": translated,
            }

            save_translation_cache(
                cache
            )

            print(
                f"\r[i18n] "
                f"{locale}: "
                f"{index}/{total}",
                end="",
                flush=True,
            )

        print()

    translations: dict[
        str,
        dict[str, str],
    ] = {}

    for locale in TARGET_LOCALES:

        translations[locale] = {}

        locale_cache = cache.get(
            locale,
            {},
        )

        for item in items:

            key = item["key"]
            source = item["text"]

            cache_key = hashlib.sha256(
                source.encode("utf-8")
            ).hexdigest()

            cached = locale_cache.get(
                cache_key
            )

            if cached is None:

                raise RuntimeError(
                    "Translation cache "
                    "tidak lengkap:\n\n"
                    f"Locale: {locale}\n"
                    f"Text: {source}"
                )

            translations[
                locale
            ][key] = cached[
                "translated"
            ]

    return translations


# ============================================================
# DART ESCAPE
# ============================================================

def dart_escape(
    value: str,
) -> str:

    return (
        value
        .replace(
            "\\",
            "\\\\",
        )
        .replace(
            "'",
            "\\'",
        )
        .replace(
            "\r",
            "\\r",
        )
        .replace(
            "\n",
            "\\n",
        )
    )


# ============================================================
# DART IDENTIFIER
# ============================================================

def dart_identifier(
    locale: str,
) -> str:

    language, country = locale.split(
        "_",
        1,
    )

    return (
        language.lower()
        + country.upper()
    )


# ============================================================
# GENERATE LOCALE
# ============================================================

def generate_locale_file(
    locale: str,
    values: dict[str, str],
) -> None:

    identifier = dart_identifier(
        locale
    )

    output = (
        TRANSLATION_DIR
        / f"{locale}.dart"
    )

    lines = [
        "// GENERATED FILE - DO NOT EDIT",
        "// Generated by tools/i18n/i18n.py",
        "",
        f"const Map<String, String> "
        f"{identifier} = {{",
    ]

    for key in sorted(values):

        value = dart_escape(
            values[key]
        )

        lines.append(
            f"  '{key}': '{value}',"
        )

    lines.extend(
        [
            "};",
            "",
        ]
    )

    output.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )

    log(
        f"Generated: {output}"
    )


def generate_all_locales(
    translations: dict,
) -> None:

    for locale in TARGET_LOCALES:

        generate_locale_file(
            locale,
            translations.get(
                locale,
                {},
            ),
        )


# ============================================================
# GETX IMPORT
# ============================================================

def add_get_import(
    source: str,
) -> str:

    if re.search(
        r"""import\s+['"]package:get/get\.dart['"]\s*;""",
        source,
    ):
        return source

    imports = list(
        re.finditer(
            r"""^import\s+['"][^'"]+['"]\s*;\s*$""",
            source,
            re.MULTILINE,
        )
    )

    import_line = (
        "import 'package:get/get.dart';"
    )

    if imports:

        last = imports[-1]

        return (
            source[:last.end()]
            + "\n"
            + import_line
            + source[last.end():]
        )

    return (
        import_line
        + "\n\n"
        + source
    )


# ============================================================
# CONST RANGES
# ============================================================

def parse_const_ranges(
    value: str,
) -> list[tuple[int, int]]:

    result: list[
        tuple[int, int]
    ] = []

    if not value or value == "-":
        return result

    for item in value.split(";"):

        if not item:
            continue

        try:

            start, end = item.split(
                ":",
                1,
            )

            result.append(
                (
                    int(start),
                    int(end),
                )
            )

        except ValueError:
            continue

    return result


# ============================================================
# STRING QUOTE
# ============================================================

def extract_quote(
    original: str,
) -> str | None:

    if original.startswith(
        ("'''", '"""')
    ):
        return original[:3]

    if original.startswith(
        ("'", '"')
    ):
        return original[:1]

    return None


# ============================================================
# BACKUP
# ============================================================

def backup_file(
    path: Path,
) -> None:

    try:

        relative = path.resolve().relative_to(
            ROOT.resolve()
        )

    except ValueError:

        relative = Path(
            path.name
        )

    destination = (
        BACKUP_DIR
        / relative
    )

    destination.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    shutil.copy2(
        path,
        destination,
    )


# ============================================================
# APPLY ONE FILE
# ============================================================

def apply_file_replacements(
    path: Path,
    items: list[dict],
) -> tuple[int, int, bool]:

    source = path.read_text(
        encoding="utf-8"
    )

    original_source = source

    edits: list[
        tuple[int, int, str, str]
    ] = []

    replacement_count = 0
    const_count = 0

    # ========================================================
    # STRING EDITS
    # ========================================================

    for item in items:

        start = item["offset"]
        end = item["end"]

        if (
            start < 0
            or end <= start
            or end > len(source)
        ):
            continue

        original = source[
            start:end
        ]

        quote = extract_quote(
            original
        )

        if quote is None:
            continue

        # Sudah .tr
        after = source[end:]

        if re.match(
            r"\s*\.tr\b",
            after,
        ):
            continue

        key = item["key"]

        replacement = (
            quote
            + key
            + quote
            + ".tr"
        )

        edits.append(
            (
                start,
                end,
                replacement,
                "string",
            )
        )

        replacement_count += 1

        # ====================================================
        # CONST
        # ====================================================

        for (
            const_start,
            const_end,
        ) in parse_const_ranges(
            item.get(
                "constRanges",
                "",
            )
        ):

            if (
                const_start < 0
                or const_end <= const_start
                or const_end > len(source)
            ):
                continue

            token = source[
                const_start:const_end
            ]

            if token == "const":

                edits.append(
                    (
                        const_start,
                        const_end,
                        "",
                        "const",
                    )
                )

                const_count += 1

    if not edits:
        return (
            0,
            0,
            False,
        )

    # ========================================================
    # REMOVE DUPLICATE EDITS
    # ========================================================

    unique_edits = []

    seen = set()

    for edit in edits:

        identity = (
            edit[0],
            edit[1],
            edit[2],
            edit[3],
        )

        if identity in seen:
            continue

        seen.add(identity)

        unique_edits.append(
            edit
        )

    # ========================================================
    # SORT RIGHT -> LEFT
    # ========================================================

    unique_edits.sort(
        key=lambda item: (
            item[0],
            item[1],
        ),
        reverse=True,
    )

    changed = False

    last_start = len(source) + 1

    for (
        start,
        end,
        replacement,
        edit_type,
    ) in unique_edits:

        # Overlap prevention.
        if end > last_start:
            continue

        source = (
            source[:start]
            + replacement
            + source[end:]
        )

        last_start = start

        changed = True

    if not changed:
        return (
            0,
            0,
            False,
        )

    # ========================================================
    # BACKUP
    # ========================================================

    if source != original_source:

        backup_file(path)

        source = add_get_import(
            source
        )

        path.write_text(
            source,
            encoding="utf-8",
        )

    return (
        replacement_count,
        const_count,
        True,
    )


# ============================================================
# APPLY .TR
# ============================================================

def apply_replacements(
    results: dict[str, dict],
) -> None:

    grouped: dict[
        str,
        list[dict],
    ] = {}

    # ========================================================
    # HASIL BARU:
    #
    # key -> occurrences[]
    # ========================================================

    for item in results.values():

        key = item["key"]

        for occurrence in item.get(
            "occurrences",
            [],
        ):

            occurrence_copy = dict(
                occurrence
            )

            occurrence_copy[
                "key"
            ] = key

            grouped.setdefault(
                occurrence["file"],
                [],
            ).append(
                occurrence_copy
            )

    changed_files = 0
    changed_strings = 0
    removed_consts = 0

    for (
        relative_path,
        items,
    ) in grouped.items():

        path = ROOT / relative_path

        if not path.exists():

            log(
                "WARNING: File tidak ditemukan: "
                f"{relative_path}"
            )

            continue

        (
            strings_count,
            const_count,
            changed,
        ) = apply_file_replacements(
            path,
            items,
        )

        if not changed:
            continue

        changed_files += 1
        changed_strings += strings_count
        removed_consts += const_count

        log(
            f"Updated: {relative_path}"
        )

    log(
        f"Files changed: "
        f"{changed_files}"
    )

    log(
        f"Strings replaced: "
        f"{changed_strings}"
    )

    log(
        f"const removed: "
        f"{removed_consts}"
    )


# ============================================================
# LOAD STRINGS
# ============================================================

def load_strings() -> dict[str, dict]:

    if not STRINGS_FILE.exists():

        raise RuntimeError(
            "strings.json belum ada.\n\n"
            "Jalankan:\n\n"
            "python tools/i18n/i18n.py scan"
        )

    data = json.loads(
        STRINGS_FILE.read_text(
            encoding="utf-8"
        )
    )

    return data.get(
        "strings",
        {},
    )


# ============================================================
# COMMAND SCAN
# ============================================================

def command_scan(
    dart: str,
) -> None:

    results = ast_scan(
        dart
    )

    save_scan(
        results
    )


# ============================================================
# COMMAND TRANSLATE
# ============================================================

def command_translate() -> None:

    results = load_strings()

    translations = translate_all(
        results
    )

    generate_all_locales(
        translations
    )


# ============================================================
# COMMAND FIX
# ============================================================

def command_fix() -> None:

    results = load_strings()

    apply_replacements(
        results
    )


# ============================================================
# COMMAND ALL
# ============================================================

def command_all(
    dart: str,
) -> None:

    print()
    print("=" * 70)
    print("DMN_PLAY OFFLINE I18N")
    print("=" * 70)
    print()

    # --------------------------------------------------------
    # STEP 1
    # --------------------------------------------------------

    log(
        "STEP 1/4 - Scan seluruh lib/**/*.dart"
    )

    results = ast_scan(
        dart
    )

    save_scan(
        results
    )

    print()

    # --------------------------------------------------------
    # STEP 2
    # --------------------------------------------------------

    log(
        "STEP 2/4 - Argos translation"
    )

    translations = translate_all(
        results
    )

    print()

    # --------------------------------------------------------
    # STEP 3
    # --------------------------------------------------------

    log(
        "STEP 3/4 - Generate locale files"
    )

    generate_all_locales(
        translations
    )

    print()

    # --------------------------------------------------------
    # STEP 4
    # --------------------------------------------------------

    log(
        "STEP 4/4 - Apply .tr"
    )

    apply_replacements(
        results
    )

    print()
    print("=" * 70)
    print("DMN_PLAY I18N SELESAI")
    print("=" * 70)
    print()

    print(
        f"Unique strings : "
        f"{len(results)}"
    )

    total_occurrences = sum(
        len(
            item.get(
                "occurrences",
                [],
            )
        )
        for item in results.values()
    )

    print(
        f"Occurrences    : "
        f"{total_occurrences}"
    )

    print(
        "Locales        : "
        + ", ".join(
            TARGET_LOCALES
        )
    )

    print()

    print("Generated:")

    for locale in TARGET_LOCALES:

        print(
            "  lib/data/translations/"
            f"{locale}.dart"
        )

    print()

    print(
        "Backup:"
    )

    print(
        f"  {BACKUP_DIR}"
    )

    print()

    print(
        "Selanjutnya:"
    )

    print(
        "  flutter analyze"
    )

    print(
        "  flutter run"
    )

    print()


# ============================================================
# HELP
# ============================================================

def print_help() -> None:

    print(
        """
DMN_PLAY I18N

ONE COMMAND:

    python tools/i18n/i18n.py all


COMMANDS:

    scan
        Scan seluruh hardcoded human-readable
        string dari lib/**/*.dart.

    translate
        Translate strings.json dengan Argos.

    fix
        Apply .tr ke source Dart.

    all
        Scan + Translate + Generate + Apply .tr.


TARGET:

    en_US
    id_ID
    ja_JP
    ko_KR
    hi_IN
    ms_MY


TRANSLATOR:

    Argos Translate


IMPORTANT:

    Scanner sekarang membaca SELURUH:

        lib/**/*.dart

    BUKAN hanya:

        views/
        widgets/
        screens/
        pages/


    Folder translation hasil generate
    tidak ikut discan.
"""
    )


# ============================================================
# MAIN
# ============================================================

def main() -> None:

    ensure_directories()

    command = (
        sys.argv[1].lower()
        if len(sys.argv) > 1
        else "all"
    )

    try:

        validate_project()

        # ----------------------------------------------------
        # command translate/fix tidak membutuhkan Dart.
        # ----------------------------------------------------

        if command in {
            "scan",
            "all",
        }:

            dart = check_dart()

        else:

            dart = None

        # ----------------------------------------------------
        # COMMAND
        # ----------------------------------------------------

        if command == "scan":

            assert dart is not None

            command_scan(
                dart
            )

        elif command == "translate":

            command_translate()

        elif command == "fix":

            command_fix()

        elif command == "all":

            assert dart is not None

            command_all(
                dart
            )

        elif command in {
            "help",
            "-h",
            "--help",
        }:

            print_help()

        else:

            print_help()

            sys.exit(1)

    except KeyboardInterrupt:

        print()
        print("Dibatalkan.")
        sys.exit(1)

    except Exception as exc:

        print()
        print("=" * 70)
        print("ERROR")
        print("=" * 70)
        print()
        print(str(exc))
        print()

        sys.exit(1)


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":
    main()