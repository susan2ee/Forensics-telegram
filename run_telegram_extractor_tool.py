import subprocess
import sys
from pathlib import Path

def run_memory_filter(original_dump):
    print(f"[+] Starting Telegram memory filtering: {original_dump}")

    memory_extractor = "telegram_memory_extractor.py"
    result = subprocess.run(["python", memory_extractor, original_dump], text=True)

    if result.returncode != 0:
        print("[!] Memory filtering returned a non-zero exit code. Proceeding with fallback if available.")

    output_dir = Path("telegram_ultimate_output")
    filtered_files = list(output_dir.glob("filtered_renderer_*.dmp"))

    if filtered_files:
        selected_file = filtered_files[0]
        print(f"[+] Filtered memory dump found: {selected_file.name}")
        return selected_file

    fallback_files = list(output_dir.glob("renderer_*.dmp"))
    if fallback_files:
        selected_file = fallback_files[0]
        print(f"[!] Filtered dump not found. Using unfiltered renderer dump: {selected_file.name}")
        return selected_file

    print("[!] No memory dump available for analysis.")
    return None

def run_message_extractor_aVersion(filtered_dump: Path) -> None:
    print(f"[+] Running Telegram message extractor on: {filtered_dump}")

    # JSON file lives next to the dump, e.g. filtered_....json
    output_json = filtered_dump.with_suffix(".json")

    result = subprocess.run(
        ["python", "../MessageExtractor_aVersion/message_extractor_aVersion.py",
         str(filtered_dump), str(output_json)],
        text=True
    )

    if result.returncode != 0:
        print("[!] Message extraction failed.")
        sys.exit(1)

    print(f"[✓] Parsed messages saved to: {output_json}")

def run_message_extractor_kVersion(filtered_dump: Path) -> None:
    print(f"[+] Running Telegram message extractor on: {filtered_dump}")

    # JSON file lives next to the dump, e.g. filtered_....json
    output_json = filtered_dump.with_suffix(".json")

    result = subprocess.run(
        ["python", "../MessageExtractor_kVersion/message_extractor_kVersion.py",
         str(filtered_dump), str(output_json)],
        text=True
    )

    if result.returncode != 0:
        print("[!] Message extraction failed.")
        sys.exit(1)

    print(f"[✓] Parsed messages saved to: {output_json}")

def main():
    is_aVersion = False
    
    print("=" * 60)
    print("Telegram Memory Analysis Tool")
    print("=" * 60)
    
    if len(sys.argv) < 2:
        print("Usage: -m MessageExtractor.message_extractor <dump_file>")
        sys.exit(1)
    memory_path = sys.argv[1]

    if not Path(memory_path).exists():
        print(f"[!] File not found: {memory_path}")
        return
    
    answer = input("Select the Web Telegram version ('a'/'k'): ")

    if answer.lower() == 'a':
        is_aVersion = True
    elif answer.lower() == 'k':
        is_aVersion = False
    else:
        print("[i] Invalid or empty selection")
        sys.exit(1)
        
    filtered_dump = run_memory_filter(memory_path)
    if filtered_dump:
        if is_aVersion:
            run_message_extractor_aVersion(filtered_dump)
        else:
            run_message_extractor_kVersion(filtered_dump)

if __name__ == "__main__":
    main()
