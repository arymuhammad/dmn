import os
import re
import json
import hashlib

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB_DIR = os.path.join(PROJECT_ROOT, "lib")
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "tools", "i18n")

OUTPUT_FILE = os.path.join(OUTPUT_DIR, "strings.json")

os.makedirs(OUTPUT_DIR, exist_ok=True)


# ============================================================
# Widget / property yang memang biasanya berisi teks UI
# ============================================================

UI_PATTERNS = [
    r'\bText\s*\(\s*[\'"](.+?)[\'"]',
    r'\bTextSpan\s*\(\s*[\'"](.+?)[\'"]',
    r'\bRichText\s*\(\s*.*?text:\s*[\'"](.+?)[\'"]',

    r'\btitle:\s*[\'"](.+?)[\'"]',
    r'\bsubtitle:\s*[\'"](.+?)[\'"]',
    r'\blabel:\s*[\'"](.+?)[\'"]',
    r'\bhintText:\s*[\'"](.+?)[\'"]',
    r'\bhelperText:\s*[\'"](.+?)[\'"]',
    r'\berrorText:\s*[\'"](.+?)[\'"]',
    r'\btooltip:\s*[\'"](.+?)[\'"]',

    r'\bsemanticLabel:\s*[\'"](.+?)[\'"]',
    r'\bmessage:\s*[\'"](.+?)[\'"]',
    r'\bmiddleText:\s*[\'"](.+?)[\'"]',

    r'\bemptyText:\s*[\'"](.+?)[\'"]',
    r'\bbuttonText:\s*[\'"](.+?)[\'"]',

    r'\blabelText:\s*[\'"](.+?)[\'"]',
    r'\bprefixText:\s*[\'"](.+?)[\'"]',
    r'\bsuffixText:\s*[\'"](.+?)[\'"]',

    r'\bTextButton\s*\(\s*.*?Text\s*\(\s*[\'"](.+?)[\'"]',
    r'\bElevatedButton\s*\(\s*.*?Text\s*\(\s*[\'"](.+?)[\'"]',
    r'\bOutlinedButton\s*\(\s*.*?Text\s*\(\s*[\'"](.+?)[\'"]',
]


# ============================================================
# String yang jelas bukan UI
# ============================================================

IGNORE_EXACT = {
    "true",
    "false",
    "null",
    "Auto",
    "VIP",
}

IGNORE_CONTAINS = [
    "http://",
    "https://",
    "www.",
    "assets/",
    "package:",
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".mp4",
    ".m3u8",
    ".vtt",
    ".json",
    ".dart",
    "Colors.",
    "Icons.",
]


def is_valid_ui_text(text):
    text = text.strip()

    if not text:
        return False

    if text in IGNORE_EXACT:
        return False

    if len(text) < 2:
        return False

    if len(text) > 200:
        return False

    for item in IGNORE_CONTAINS:
        if item.lower() in text.lower():
            return False

    # Jangan ambil angka / kode
    if re.fullmatch(r"[\d\s.,:/_\-+]+", text):
        return False

    # Jangan ambil variable interpolation murni
    if text.startswith("$"):
        return False

    # Harus memiliki minimal satu huruf
    if not re.search(r"[A-Za-zÀ-ÿ\u3040-\u30ff\u4e00-\u9fff\uac00-\ud7af]", text):
        return False

    return True


def make_key(text):
    """
    Contoh:

    "Account Settings"
        -> account_settings

    "Watch Now!"
        -> watch_now
    """

    value = text.lower().strip()

    value = re.sub(r"[^\w\s]", "", value)
    value = re.sub(r"\s+", "_", value)

    value = value[:60].strip("_")

    if not value:
        value = "text"

    return value


def unique_key(text, existing):
    base = make_key(text)

    if base not in existing:
        return base

    if existing[base] == text:
        return base

    digest = hashlib.md5(text.encode()).hexdigest()[:6]

    return f"{base}_{digest}"


def remove_comments(code):
    # Remove block comments
    code = re.sub(
        r"/\*.*?\*/",
        "",
        code,
        flags=re.DOTALL
    )

    # Remove line comments
    code = re.sub(
        r"//.*",
        "",
        code
    )

    return code


def scan_file(path):
    with open(path, "r", encoding="utf-8") as f:
        code = f.read()

    code = remove_comments(code)

    found = []

    # ========================================================
    # Hanya scan pola yang berkaitan dengan UI
    # ========================================================

    for pattern in UI_PATTERNS:
        matches = re.findall(
            pattern,
            code,
            flags=re.DOTALL
        )

        for text in matches:
            if is_valid_ui_text(text):
                found.append(text)

    # ========================================================
    # Cari Text('...')
    # ========================================================

    return found


def main():

    translations = {}

    files_scanned = 0

    for root, dirs, files in os.walk(LIB_DIR):

        # Jangan scan generated / cache
        dirs[:] = [
            d for d in dirs
            if d not in {
                ".dart_tool",
                "build",
                ".git",
            }
        ]

        for filename in files:

            if not filename.endswith(".dart"):
                continue

            path = os.path.join(root, filename)

            # Jangan scan file translation
            if "translations" in path.replace("\\", "/"):
                continue

            files_scanned += 1

            try:
                texts = scan_file(path)

                for text in texts:

                    if text in translations.values():
                        continue

                    key = unique_key(
                        text,
                        translations
                    )

                    translations[key] = text

            except Exception as e:

                print(
                    f"[ERROR] {path}: {e}"
                )

    # Sort
    translations = dict(
        sorted(
            translations.items(),
            key=lambda x: x[0]
        )
    )

    with open(
        OUTPUT_FILE,
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            translations,
            f,
            ensure_ascii=False,
            indent=2
        )

    print()
    print("=" * 60)
    print("i18n scanner selesai")
    print("=" * 60)
    print(f"Files scanned : {files_scanned}")
    print(f"UI strings    : {len(translations)}")
    print()
    print(f"Output:")
    print(OUTPUT_FILE)
    print()


if __name__ == "__main__":
    main()